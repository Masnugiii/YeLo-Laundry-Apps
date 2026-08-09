import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CustomerRepository } from '../customer/customer.repository';
import {
  API_NOTIFICATION_TYPES,
  NOTIFICATION_EVENTS,
} from '../notification/constants/notification.constants';
import { NotificationEventService } from '../notification/notification-event.service';
import { CancelOrderDto } from './dto/cancel-order.dto';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrderQueryDto } from './dto/order-query.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import {
  OrderDetail,
  OrderStatistics,
  PaginatedOrders,
  calculateItemSubtotal,
  toOrderDetail,
  toOrderListItem,
} from './order.mapper';
import { OrderAuditService } from './order-audit.service';
import { OrderRepository } from './order.repository';
import { OrderStatusTransitionService } from './order-status-transition.service';
import { decodeOrderNotes, encodeOrderNotes } from './utils/order-meta.util';
import { LoyaltyProcessorService } from '../loyalty/loyalty-processor.service';

const TERMINAL_STATUSES: OrderStatus[] = [
  OrderStatus.COMPLETED,
  OrderStatus.CANCELLED,
];

@Injectable()
export class OrderService {
  private readonly logger = new Logger(OrderService.name);

  constructor(
    private readonly orderRepository: OrderRepository,
    private readonly customerRepository: CustomerRepository,
    private readonly notificationEventService: NotificationEventService,
    private readonly loyaltyProcessor: LoyaltyProcessorService,
    private readonly orderStatusTransitionService: OrderStatusTransitionService,
    private readonly orderAuditService: OrderAuditService,
  ) {}

  async findAll(
    query: OrderQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedOrders>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [orders, total] = await this.orderRepository.findMany(query);

    return {
      success: true,
      message: 'Orders retrieved successfully',
      data: {
        items: orders.map(toOrderListItem),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async exportOrders(query: OrderQueryDto): Promise<string> {
    const orders = await this.orderRepository.findManyForExport(query);
    const headers = [
      'Order Number',
      'Invoice Number',
      'Customer',
      'Phone',
      'Order Date',
      'Service',
      'Weight',
      'Items',
      'Subtotal',
      'Discount',
      'Tax',
      'Grand Total',
      'Payment Status',
      'Laundry Status',
      'Pickup Status',
      'Delivery Status',
      'Created By',
    ];

    const rows = orders.map((order) => {
      const item = toOrderListItem(order);
      return [
        item.orderNumber,
        item.invoiceNumber,
        item.customerName,
        item.customerPhone,
        item.orderDate.toISOString(),
        item.serviceSummary,
        String(item.totalWeight),
        String(item.itemCount),
        String(item.subtotal),
        String(item.discount),
        String(item.tax),
        String(item.grandTotal),
        item.paymentStatus,
        item.orderStatus,
        item.pickupStatus ?? '',
        item.deliveryStatus ?? '',
        item.createdBy.fullName,
      ];
    });

    return [
      headers.join(','),
      ...rows.map((row) =>
        row.map((value) => `"${String(value).replace(/"/g, '""')}"`).join(','),
      ),
    ].join('\n');
  }

  async getStatistics(): Promise<ApiSuccessResponse<OrderStatistics>> {
    const statistics = await this.orderRepository.getStatistics();

    return {
      success: true,
      message: 'Order statistics retrieved successfully',
      data: statistics,
    };
  }

  async findOne(id: string): Promise<ApiSuccessResponse<OrderDetail>> {
    const order = await this.orderRepository.findById(id);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    return {
      success: true,
      message: 'Order retrieved successfully',
      data: toOrderDetail(order),
    };
  }

  async create(
    dto: CreateOrderDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    const customer = await this.customerRepository.findById(dto.customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    if (!customer.isActive) {
      throw new BadRequestException('Customer is inactive');
    }

    await this.validateAddresses(dto.customerId, dto);

    const items = await this.buildOrderItems(dto.items);
    const notes = encodeOrderNotes(
      {
        discount: dto.discountAmount ?? 0,
        tax: dto.taxAmount ?? 0,
        serviceFee: dto.serviceFeeAmount ?? 0,
      },
      dto.notes,
    );

    const order = await this.orderRepository.createOrder({
      customerId: dto.customerId,
      estimatedFinishDate: dto.estimatedFinishDate,
      pickupRequired: dto.pickupRequired ?? false,
      deliveryRequired: dto.deliveryRequired ?? false,
      pickupAddressId: dto.pickupAddressId,
      deliveryAddressId: dto.deliveryAddressId,
      paymentMethod: dto.paymentMethod,
      notes,
      createdByEmployeeId: employeeId,
      items,
    });

    this.logger.log(`Order created: ${order.id} (${order.invoiceNumber})`);

    await this.orderAuditService.log({
      employeeId,
      action: 'order_created',
      referenceId: order.id,
      description: `Order ${order.invoiceNumber} created`,
    });

    await this.notificationEventService.publish({
      templateCode: NOTIFICATION_EVENTS.ORDER_CREATED,
      type: API_NOTIFICATION_TYPES.ORDER,
      eventKey: order.id,
      senderEmployeeId: employeeId,
      orderId: order.id,
      orderNumber: order.invoiceNumber,
      customerId: dto.customerId,
      customerName: customer.fullName,
      notifyRoles: ['OWNER', 'MANAGER', 'CASHIER'],
      notifyCustomer: true,
    });

    return {
      success: true,
      message: 'Order created successfully',
      data: toOrderDetail(order),
    };
  }

  async update(
    id: string,
    dto: UpdateOrderDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    const existing = await this.getEditableOrder(id);
    const decoded = decodeOrderNotes(existing.notes);

    if (dto.pickupAddressId || dto.deliveryAddressId) {
      await this.validateAddresses(existing.customerId, {
        pickupAddressId: dto.pickupAddressId,
        deliveryAddressId: dto.deliveryAddressId,
      });
    }

    if (dto.status !== undefined) {
      return this.updateStatus(
        id,
        { status: dto.status, notes: dto.statusNotes },
        employeeId,
      );
    }

    const order = await this.orderRepository.updateOrder(
      id,
      {
        ...(dto.estimatedFinishDate !== undefined && {
          estimatedFinishDate: dto.estimatedFinishDate,
        }),
        ...(dto.pickupRequired !== undefined && {
          pickupRequired: dto.pickupRequired,
        }),
        ...(dto.deliveryRequired !== undefined && {
          deliveryRequired: dto.deliveryRequired,
        }),
        ...(dto.pickupAddressId !== undefined && {
          pickupAddressId: dto.pickupAddressId,
        }),
        ...(dto.deliveryAddressId !== undefined && {
          deliveryAddressId: dto.deliveryAddressId,
        }),
        ...(dto.paymentMethod !== undefined && {
          paymentMethod: dto.paymentMethod,
        }),
        ...((dto.notes !== undefined ||
          dto.discountAmount !== undefined ||
          dto.taxAmount !== undefined ||
          dto.serviceFeeAmount !== undefined) && {
          notes: encodeOrderNotes(
            {
              discount:
                dto.discountAmount !== undefined
                  ? dto.discountAmount
                  : decoded.meta.discount,
              tax:
                dto.taxAmount !== undefined
                  ? dto.taxAmount
                  : decoded.meta.tax,
              serviceFee:
                dto.serviceFeeAmount !== undefined
                  ? dto.serviceFeeAmount
                  : decoded.meta.serviceFee,
            },
            dto.notes !== undefined ? dto.notes : decoded.notes,
          ),
        }),
      },
      employeeId,
    );

    return {
      success: true,
      message: 'Order updated successfully',
      data: toOrderDetail(order),
    };
  }

  async updateStatus(
    id: string,
    dto: UpdateOrderStatusDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    const existing = await this.getEditableOrder(id);

    this.orderStatusTransitionService.validateManualTransition(
      existing.orderStatus,
      dto.status,
    );

    if (
      dto.status === OrderStatus.COMPLETED &&
      existing.paymentStatus === 'UNPAID'
    ) {
      throw new UnprocessableEntityException(
        'Cannot complete an unpaid order',
      );
    }

    const order = await this.orderRepository.updateStatus(
      id,
      existing.orderStatus,
      dto.status,
      employeeId,
      dto.notes,
    );

    if (dto.status === OrderStatus.COMPLETED) {
      await this.loyaltyProcessor.processOrderCompleted(order.id, employeeId);
    }

    await this.orderAuditService.log({
      employeeId,
      action: 'status_transition',
      referenceId: order.id,
      description: `Order status ${existing.orderStatus} -> ${dto.status}`,
    });

    return {
      success: true,
      message: 'Order status updated successfully',
      data: toOrderDetail(order),
    };
  }

  async cancel(
    id: string,
    dto: CancelOrderDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    const existing = await this.orderRepository.findById(id);

    if (!existing) {
      throw new NotFoundException('Order not found');
    }

    if (existing.orderStatus === OrderStatus.COMPLETED) {
      throw new BadRequestException('Completed orders cannot be cancelled');
    }

    if (existing.orderStatus === OrderStatus.CANCELLED) {
      throw new BadRequestException('Order is already cancelled');
    }

    const order = await this.orderRepository.cancelOrder(
      id,
      existing.orderStatus,
      employeeId,
      dto.reason.trim(),
    );

    this.logger.log(`Order cancelled: ${order.id} (${order.invoiceNumber})`);

    await this.orderAuditService.log({
      employeeId,
      action: 'order_cancelled',
      referenceId: order.id,
      description: dto.reason.trim(),
    });

    await this.notificationEventService.publish({
      templateCode: NOTIFICATION_EVENTS.ORDER_CANCELLED,
      type: API_NOTIFICATION_TYPES.ORDER,
      eventKey: `${order.id}:cancelled`,
      senderEmployeeId: employeeId,
      orderId: order.id,
      orderNumber: order.invoiceNumber,
      customerId: existing.customerId,
      customerName: existing.customer.fullName,
      notifyRoles: ['OWNER', 'MANAGER', 'CASHIER'],
      notifyCustomer: true,
    });

    return {
      success: true,
      message: 'Order cancelled successfully',
      data: toOrderDetail(order),
    };
  }

  private async getEditableOrder(id: string) {
    const existing = await this.orderRepository.findById(id);

    if (!existing) {
      throw new NotFoundException('Order not found');
    }

    if (TERMINAL_STATUSES.includes(existing.orderStatus)) {
      throw new BadRequestException(
        'Cancelled or completed orders cannot be edited',
      );
    }

    return existing;
  }

  private async validateAddresses(
    customerId: string,
    dto: {
      pickupAddressId?: string;
      deliveryAddressId?: string;
    },
  ) {
    if (dto.pickupAddressId) {
      const address = await this.orderRepository.findCustomerAddress(
        customerId,
        dto.pickupAddressId,
      );

      if (!address) {
        throw new BadRequestException('Pickup address not found for customer');
      }
    }

    if (dto.deliveryAddressId) {
      const address = await this.orderRepository.findCustomerAddress(
        customerId,
        dto.deliveryAddressId,
      );

      if (!address) {
        throw new BadRequestException(
          'Delivery address not found for customer',
        );
      }
    }
  }

  private async buildOrderItems(items: CreateOrderDto['items']) {
    const builtItems = [];

    for (const item of items) {
      const service = await this.orderRepository.findActiveService(
        item.serviceId,
      );

      if (!service) {
        throw new BadRequestException(`Service not found: ${item.serviceId}`);
      }

      const price = await this.orderRepository.findActiveServicePrice(
        item.serviceId,
      );

      if (!price) {
        throw new BadRequestException(
          `Active price not found for service: ${service.serviceName}`,
        );
      }

      const unitPrice = Number(price.price);
      const quantity = item.quantity;
      const weight = item.weight ?? (service.weight ? quantity : undefined);

      if (quantity <= 0) {
        throw new BadRequestException('Quantity must be greater than zero');
      }

      if (weight !== undefined && weight <= 0) {
        throw new BadRequestException('Weight must be greater than zero');
      }

      builtItems.push({
        serviceId: item.serviceId,
        servicePriceId: price.id,
        quantity,
        weight,
        unitPrice,
        subtotal: calculateItemSubtotal(unitPrice, quantity),
        notes: item.notes,
      });
    }

    return builtItems;
  }
}
