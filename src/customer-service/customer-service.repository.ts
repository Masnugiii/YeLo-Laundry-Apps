import { Injectable } from '@nestjs/common';
import { Prisma, TicketStatus } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { TicketQueryDto } from './dto/customer-service.dto';
import {
  ticketDetailSelect,
  ticketListSelect,
  TicketDetailRecord,
  TicketListRecord,
} from './customer-service.select';
import { CS_CATEGORIES, CsCategory, formatSubject, parseCategory, stripCategoryPrefix } from './utils/category.util';

@Injectable()
export class CustomerServiceRepository {
  constructor(private readonly prisma: PrismaService) {}

  findMany(query: TicketQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildWhereClause(query);

    return this.prisma.$transaction([
      this.prisma.customerServiceTicket.findMany({
        where,
        skip,
        take: limit,
        orderBy: { updatedAt: 'desc' },
        select: ticketListSelect,
      }),
      this.prisma.customerServiceTicket.count({ where }),
    ]);
  }

  findById(id: string): Promise<TicketDetailRecord | null> {
    return this.prisma.customerServiceTicket.findFirst({
      where: { id, deletedAt: null },
      select: ticketDetailSelect,
    });
  }

  updateTicket(
    id: string,
    data: Prisma.CustomerServiceTicketUpdateInput,
  ) {
    return this.prisma.customerServiceTicket.update({
      where: { id },
      data,
      select: ticketDetailSelect,
    });
  }

  createMessage(data: {
    ticketId: string;
    employeeId: string;
    message: string;
  }) {
    return this.prisma.$transaction(async (tx) => {
      const created = await tx.customerServiceMessage.create({
        data: {
          ticketId: data.ticketId,
          senderType: 'EMPLOYEE',
          employeeId: data.employeeId,
          message: data.message,
        },
        select: {
          id: true,
          message: true,
          senderType: true,
          createdAt: true,
          employee: {
            select: {
              id: true,
              fullName: true,
            },
          },
        },
      });

      await tx.customerServiceTicket.update({
        where: { id: data.ticketId },
        data: {
          updatedAt: new Date(),
          status: TicketStatus.IN_PROGRESS,
        },
      });

      return created;
    });
  }

  countSummary() {
    return this.prisma.customerServiceTicket.findMany({
      where: { deletedAt: null },
      select: {
        status: true,
        subject: true,
      },
    });
  }

  async findLatestOrderSummary(customerId: string) {
    const order = await this.prisma.order.findFirst({
      where: {
        customerId,
        deletedAt: null,
      },
      orderBy: { orderDate: 'desc' },
      select: {
        queueNumber: true,
        orderStatus: true,
        estimatedFinishDate: true,
        items: {
          where: { deletedAt: null },
          take: 1,
          select: {
            service: {
              select: { serviceName: true },
            },
          },
        },
      },
    });

    if (!order) {
      return null;
    }

    return {
      queueNumber: order.queueNumber,
      orderStatus: order.orderStatus,
      estimatedFinishDate: order.estimatedFinishDate,
      laundryService: order.items[0]?.service.serviceName ?? 'Layanan Laundry',
    };
  }

  async findOrderSummaryById(orderId: string) {
    const order = await this.prisma.order.findFirst({
      where: {
        id: orderId,
        deletedAt: null,
      },
      select: {
        queueNumber: true,
        orderStatus: true,
        estimatedFinishDate: true,
        items: {
          where: { deletedAt: null },
          take: 1,
          select: {
            service: {
              select: { serviceName: true },
            },
          },
        },
      },
    });

    if (!order) {
      return null;
    }

    return {
      queueNumber: order.queueNumber,
      orderStatus: order.orderStatus,
      estimatedFinishDate: order.estimatedFinishDate,
      laundryService: order.items[0]?.service.serviceName ?? 'Layanan Laundry',
    };
  }

  private buildWhereClause(query: TicketQueryDto): Prisma.CustomerServiceTicketWhereInput {
    const where: Prisma.CustomerServiceTicketWhereInput = {
      deletedAt: null,
    };

    if (query.status) {
      where.status = query.status;
    }

    if (query.search?.trim()) {
      const search = query.search.trim();
      where.OR = [
        { subject: { contains: search, mode: 'insensitive' } },
        {
          customer: {
            OR: [
              { fullName: { contains: search, mode: 'insensitive' } },
              { phone: { contains: search, mode: 'insensitive' } },
            ],
          },
        },
      ];
    }

    if (query.category) {
      where.subject = {
        startsWith: `[CS:${query.category}]`,
        mode: 'insensitive',
      };
    }

    return where;
  }

  filterByCategory(
    tickets: Array<{ status: TicketStatus; subject: string }>,
    category: CsCategory,
  ) {
    return tickets.filter(
      (ticket) => parseCategory(ticket.subject) === category,
    );
  }

  findTicketByCustomerAndOrder(customerId: string, orderId: string) {
    return this.prisma.customerServiceTicket.findFirst({
      where: {
        customerId,
        orderId,
        deletedAt: null,
      },
      select: ticketDetailSelect,
    });
  }

  async createCustomerOrderFeedbackMessage(params: {
    customerId: string;
    orderId: string;
    orderNumber: string;
    message: string;
  }) {
    return this.prisma.$transaction(async (tx) => {
      let ticket = await tx.customerServiceTicket.findFirst({
        where: {
          customerId: params.customerId,
          orderId: params.orderId,
          deletedAt: null,
        },
      });

      if (!ticket) {
        ticket = await tx.customerServiceTicket.create({
          data: {
            customerId: params.customerId,
            orderId: params.orderId,
            subject: `[CS:KOMPLAIN] Masukan pesanan ${params.orderNumber}`,
            status: TicketStatus.OPEN,
          },
        });
      }

      await tx.customerServiceMessage.create({
        data: {
          ticketId: ticket.id,
          senderType: 'CUSTOMER',
          customerId: params.customerId,
          message: params.message,
        },
      });

      await tx.customerServiceTicket.update({
        where: { id: ticket.id },
        data: {
          updatedAt: new Date(),
          status:
            ticket.status === TicketStatus.CLOSED ||
            ticket.status === TicketStatus.RESOLVED
              ? TicketStatus.OPEN
              : ticket.status,
        },
      });

      return ticket.id;
    });
  }

  async createGeneralTicket(params: {
    customerId: string;
    category: string;
    subject: string;
    message: string;
  }) {
    const category = this.normalizeCategory(params.category);
    const formattedSubject = formatSubject(category, params.subject);

    return this.prisma.$transaction(async (tx) => {
      const ticket = await tx.customerServiceTicket.create({
        data: {
          customerId: params.customerId,
          orderId: null,
          subject: formattedSubject,
          status: TicketStatus.OPEN,
        },
      });

      await tx.customerServiceMessage.create({
        data: {
          ticketId: ticket.id,
          senderType: 'CUSTOMER',
          customerId: params.customerId,
          message: params.message,
        },
      });

      return ticket.id;
    });
  }

  async listCustomerTickets(customerId: string) {
    const tickets = await this.prisma.customerServiceTicket.findMany({
      where: { customerId, deletedAt: null },
      orderBy: { updatedAt: 'desc' },
      include: {
        messages: {
          orderBy: { createdAt: 'asc' },
          take: 1,
        },
      },
    });

    return tickets.map((ticket) => ({
      id: ticket.id,
      category: parseCategory(ticket.subject),
      subject: stripCategoryPrefix(ticket.subject),
      status: ticket.status,
      createdAt: ticket.createdAt.toISOString(),
      updatedAt: ticket.updatedAt.toISOString(),
      lastMessage: ticket.messages[0]?.message ?? null,
    }));
  }

  async getCustomerTicketDetail(ticketId: string, customerId: string) {
    const ticket = await this.prisma.customerServiceTicket.findFirst({
      where: { id: ticketId, customerId, deletedAt: null },
      include: {
        messages: {
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!ticket) {
      return null;
    }

    return {
      id: ticket.id,
      category: parseCategory(ticket.subject),
      subject: stripCategoryPrefix(ticket.subject),
      status: ticket.status,
      createdAt: ticket.createdAt.toISOString(),
      updatedAt: ticket.updatedAt.toISOString(),
      messages: ticket.messages.map((message) => ({
        id: message.id,
        senderType: message.senderType,
        message: message.message,
        createdAt: message.createdAt.toISOString(),
      })),
    };
  }

  async addCustomerMessage(params: {
    ticketId: string;
    customerId: string;
    message: string;
  }) {
    const ticket = await this.prisma.customerServiceTicket.findFirst({
      where: {
        id: params.ticketId,
        customerId: params.customerId,
        deletedAt: null,
      },
    });

    if (!ticket) {
      return null;
    }

    return this.prisma.$transaction(async (tx) => {
      const created = await tx.customerServiceMessage.create({
        data: {
          ticketId: params.ticketId,
          senderType: 'CUSTOMER',
          customerId: params.customerId,
          message: params.message,
        },
      });

      await tx.customerServiceTicket.update({
        where: { id: params.ticketId },
        data: {
          updatedAt: new Date(),
          status:
            ticket.status === TicketStatus.CLOSED ||
            ticket.status === TicketStatus.RESOLVED
              ? TicketStatus.OPEN
              : ticket.status,
        },
      });

      return {
        id: created.id,
        senderType: created.senderType,
        message: created.message,
        createdAt: created.createdAt.toISOString(),
      };
    });
  }

  private normalizeCategory(value: string): CsCategory {
    const normalized = value.trim().toUpperCase().replace(/\s+/g, '_');
    const aliases: Record<string, CsCategory> = {
      KOMPLAIN_PELAYANAN: 'KOMPLAIN',
      KOMPLAIN_BAJU_RUSAK: 'KOMPLAIN',
      PERTANYAAN_APLIKASI: 'PERTANYAAN',
      FEEDBACK_POSITIF: 'LAINNYA',
      SARAN_MASUKAN: 'LAINNYA',
    };

    const mapped = aliases[normalized] ?? normalized;
    if (CS_CATEGORIES.includes(mapped as CsCategory)) {
      return mapped as CsCategory;
    }

    return 'LAINNYA';
  }
}
