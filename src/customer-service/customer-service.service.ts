import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { TicketStatus } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CsSummary,
  CsTicketDetail,
  CsTicketListItem,
  CustomerOrderFeedback,
  mapOrderStatus,
  toCustomerOrderFeedback,
  toTicketDetail,
  toTicketListItem,
} from './customer-service.mapper';
import { CustomerServiceRepository } from './customer-service.repository';
import {
  CreateMessageDto,
  TicketQueryDto,
  UpdateTicketDto,
} from './dto/customer-service.dto';
import {
  formatSubject,
  parseCategory,
  stripCategoryPrefix,
} from './utils/category.util';

@Injectable()
export class CustomerServiceService {
  constructor(private readonly repository: CustomerServiceRepository) {}

  async getSummary(): Promise<ApiSuccessResponse<CsSummary>> {
    const tickets = await this.repository.countSummary();

    const unreadMessages = tickets.filter(
      (ticket) =>
        ticket.status === TicketStatus.OPEN ||
        ticket.status === TicketStatus.IN_PROGRESS,
    ).length;

    const newComplaints = tickets.filter(
      (ticket) =>
        parseCategory(ticket.subject) === 'KOMPLAIN' &&
        ticket.status === TicketStatus.OPEN,
    ).length;

    const orderQuestions = tickets.filter((ticket) => {
      const category = parseCategory(ticket.subject);
      return (
        (category === 'TRACKING_ORDER' || category === 'ORDER_BARU') &&
        (ticket.status === TicketStatus.OPEN ||
          ticket.status === TicketStatus.IN_PROGRESS)
      );
    }).length;

    const completed = tickets.filter(
      (ticket) =>
        ticket.status === TicketStatus.RESOLVED ||
        ticket.status === TicketStatus.CLOSED,
    ).length;

    return {
      success: true,
      message: 'Customer service summary retrieved successfully',
      data: {
        unreadMessages,
        newComplaints,
        orderQuestions,
        completed,
      },
    };
  }

  async findAll(
    query: TicketQueryDto,
  ): Promise<
    ApiSuccessResponse<{
      items: CsTicketListItem[];
      meta: { page: number; limit: number; total: number; totalPages: number };
    }>
  > {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [records, total] = await this.repository.findMany(query);

    return {
      success: true,
      message: 'Customer service tickets retrieved successfully',
      data: {
        items: records.map((record) => toTicketListItem(record)),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async findOne(id: string): Promise<ApiSuccessResponse<CsTicketDetail>> {
    const ticket = await this.repository.findById(id);

    if (!ticket) {
      throw new NotFoundException('Customer service ticket not found');
    }

    const relatedOrder = await this.buildRelatedOrder(ticket);

    return {
      success: true,
      message: 'Customer service ticket retrieved successfully',
      data: toTicketDetail(ticket, relatedOrder),
    };
  }

  async update(
    id: string,
    dto: UpdateTicketDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<CsTicketDetail>> {
    const existing = await this.repository.findById(id);

    if (!existing) {
      throw new NotFoundException('Customer service ticket not found');
    }

    const currentCategory = parseCategory(existing.subject);
    const nextCategory = dto.category ?? currentCategory;
    const nextSubject = dto.subject
      ? formatSubject(nextCategory, dto.subject)
      : dto.category
        ? formatSubject(nextCategory, stripCategoryPrefix(existing.subject))
        : existing.subject;

    const closedStatuses: TicketStatus[] = [
      TicketStatus.RESOLVED,
      TicketStatus.CLOSED,
    ];
    const shouldClose =
      dto.status !== undefined && closedStatuses.includes(dto.status);

    const updated = await this.repository.updateTicket(id, {
      subject: nextSubject,
      status: dto.status,
      employee: dto.employeeId
        ? { connect: { id: dto.employeeId } }
        : undefined,
      closedAt: shouldClose ? new Date() : undefined,
      updatedAt: new Date(),
    });

    const relatedOrder = await this.buildRelatedOrder(updated);

    return {
      success: true,
      message: 'Customer service ticket updated successfully',
      data: toTicketDetail(updated, relatedOrder),
    };
  }

  async addMessage(
    id: string,
    dto: CreateMessageDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<CsTicketDetail>> {
    const existing = await this.repository.findById(id);

    if (!existing) {
      throw new NotFoundException('Customer service ticket not found');
    }

    if (
      existing.status === TicketStatus.CLOSED ||
      existing.status === TicketStatus.RESOLVED
    ) {
      throw new BadRequestException(
        'Cannot reply to a resolved or closed ticket',
      );
    }

    await this.repository.createMessage({
      ticketId: id,
      employeeId,
      message: dto.message,
    });

    return this.findOne(id);
  }

  async getOrderFeedback(
    customerId: string,
    orderId: string,
  ): Promise<ApiSuccessResponse<CustomerOrderFeedback>> {
    const ticket = await this.repository.findTicketByCustomerAndOrder(
      customerId,
      orderId,
    );

    return {
      success: true,
      message: 'Order feedback retrieved successfully',
      data: toCustomerOrderFeedback(orderId, ticket),
    };
  }

  async sendOrderFeedback(
    customerId: string,
    orderId: string,
    orderNumber: string,
    message: string,
  ): Promise<ApiSuccessResponse<CustomerOrderFeedback>> {
    const trimmed = message.trim();

    if (!trimmed) {
      throw new BadRequestException('Message is required');
    }

    await this.repository.createCustomerOrderFeedbackMessage({
      customerId,
      orderId,
      orderNumber,
      message: trimmed,
    });

    return this.getOrderFeedback(customerId, orderId);
  }

  async listCustomerTickets(customerId: string) {
    const tickets = await this.repository.listCustomerTickets(customerId);
    return {
      success: true,
      message: 'Support tickets retrieved successfully',
      data: tickets,
    };
  }

  async createCustomerTicket(
    customerId: string,
    category: string,
    subject: string,
    message: string,
  ) {
    const trimmedMessage = message.trim();
    const trimmedSubject = subject.trim();

    if (!trimmedMessage || !trimmedSubject) {
      throw new BadRequestException('Subject and message are required');
    }

    const ticketId = await this.repository.createGeneralTicket({
      customerId,
      category,
      subject: trimmedSubject,
      message: trimmedMessage,
    });

    const detail = await this.repository.getCustomerTicketDetail(
      ticketId,
      customerId,
    );

    return {
      success: true,
      message: 'Support ticket created successfully',
      data: detail,
    };
  }

  async getCustomerTicket(customerId: string, ticketId: string) {
    const detail = await this.repository.getCustomerTicketDetail(
      ticketId,
      customerId,
    );

    if (!detail) {
      throw new NotFoundException('Support ticket not found');
    }

    return {
      success: true,
      message: 'Support ticket retrieved successfully',
      data: detail,
    };
  }

  async sendCustomerTicketMessage(
    customerId: string,
    ticketId: string,
    message: string,
  ) {
    const trimmed = message.trim();

    if (!trimmed) {
      throw new BadRequestException('Message is required');
    }

    const created = await this.repository.addCustomerMessage({
      ticketId,
      customerId,
      message: trimmed,
    });

    if (!created) {
      throw new NotFoundException('Support ticket not found');
    }

    return this.getCustomerTicket(customerId, ticketId);
  }

  private async buildRelatedOrder(ticket: {
    customer: { id: string };
    orderId?: string | null;
  }) {
    const order = ticket.orderId
      ? await this.repository.findOrderSummaryById(ticket.orderId)
      : await this.repository.findLatestOrderSummary(ticket.customer.id);

    if (!order) {
      return null;
    }

    return {
      queueNumber: order.queueNumber,
      laundryService: order.laundryService,
      currentStatus: mapOrderStatus(order.orderStatus),
      estimatedCompletion: order.estimatedFinishDate?.toISOString() ?? null,
    };
  }
}
