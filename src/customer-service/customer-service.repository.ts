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
import { CsCategory, parseCategory } from './utils/category.util';

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
}
