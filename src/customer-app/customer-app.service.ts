import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { OrderStatus, PaymentStatus } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CustomerRepository } from '../customer/customer.repository';
import { CustomerWalletService } from '../customer/customer-wallet.service';
import { CustomerWalletTopUpService } from '../customer/customer-wallet-topup.service';
import { NotificationService } from '../notification/notification.service';
import { NotificationQueryDto } from '../notification/dto/notification.dto';
import {
  OrderDetail,
  PaginatedOrders,
  calculateItemSubtotal,
  toOrderDetail,
  toOrderListItem,
} from '../order/order.mapper';
import { OrderRepository } from '../order/order.repository';
import { PickupDeliveryService } from '../pickup-delivery/pickup-delivery.service';
import { PrismaService } from '../database/prisma/prisma.service';
import { CatalogService } from '../master-data/catalog.service';
import { PerfumeService } from '../master-data/perfume.service';
import { TaxService } from '../common/services/tax.service';
import { PaymentConfigService } from '../settings/config/payment-config.service';
import { VoucherService } from '../loyalty/voucher.service';
import { MissionService } from '../loyalty/mission.service';
import { RewardRedeemService } from '../loyalty/reward-redeem.service';
import { CustomerServiceService } from '../customer-service/customer-service.service';
import { PaymentService } from '../finance/payment.service';
import { PaymentRepository } from '../finance/payment.repository';
import { ApiPaymentMethod } from '../finance/dto/payment.dto';
import { encodeOrderNotes } from '../order/utils/order-meta.util';
import {
  API_NOTIFICATION_TYPES,
  NOTIFICATION_EVENTS,
} from '../notification/constants/notification.constants';
import { NotificationEventService } from '../notification/notification-event.service';
import {
  buildLaundryTracking,
  CustomerDashboardData,
  CustomerRewardSummary,
  PaginatedRewardHistory,
} from './customer-app.mapper';
import {
  CustomerCreateOrderDto,
  CustomerOrderQueryDto,
  CustomerPayOrderDto,
  CustomerPickupRequestDto,
  CustomerPromoQueryDto,
  CustomerPromoQuoteDto,
  CustomerRedeemRewardsDto,
  CustomerRewardQueryDto,
  CustomerWalletTopUpDto,
  CreateSupportTicketDto,
  SendSupportMessageDto,
} from './dto/customer-app.dto';

const ACTIVE_STATUSES: OrderStatus[] = [
  OrderStatus.CREATED,
  OrderStatus.WAITING_PAYMENT,
  OrderStatus.PAYMENT_CONFIRMED,
  OrderStatus.WAITING_BINATU,
  OrderStatus.IRONING_ACCEPTED,
  OrderStatus.CURRENTLY_IRONING,
  OrderStatus.FINISHED_IRONING,
  OrderStatus.READY_FOR_PICKUP,
  OrderStatus.WAITING_PICKUP_DRIVER,
  OrderStatus.PICKUP_COMPLETED,
  OrderStatus.WAITING_DELIVERY,
  OrderStatus.OUT_FOR_DELIVERY,
];

@Injectable()
export class CustomerAppService {
  constructor(
    private readonly customerRepository: CustomerRepository,
    private readonly orderRepository: OrderRepository,
    private readonly walletService: CustomerWalletService,
    private readonly walletTopUpService: CustomerWalletTopUpService,
    private readonly notificationService: NotificationService,
    private readonly pickupDeliveryService: PickupDeliveryService,
    private readonly prisma: PrismaService,
    private readonly catalogService: CatalogService,
    private readonly perfumeService: PerfumeService,
    private readonly taxService: TaxService,
    private readonly paymentConfigService: PaymentConfigService,
    private readonly voucherService: VoucherService,
    private readonly missionService: MissionService,
    private readonly rewardRedeemService: RewardRedeemService,
    private readonly customerServiceService: CustomerServiceService,
    private readonly paymentService: PaymentService,
    private readonly paymentRepository: PaymentRepository,
    private readonly notificationEventService: NotificationEventService,
  ) {}

  async getDashboard(
    customerId: string,
  ): Promise<ApiSuccessResponse<CustomerDashboardData>> {
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    const [activeOrders, readyPickup, wallet, unreadCount, notifications] =
      await Promise.all([
        this.prisma.order.count({
          where: {
            customerId,
            deletedAt: null,
            orderStatus: { in: ACTIVE_STATUSES },
          },
        }),
        this.prisma.order.count({
          where: {
            customerId,
            deletedAt: null,
            orderStatus: OrderStatus.READY_FOR_PICKUP,
          },
        }),
        this.walletService.getWallet(customerId),
        this.notificationService.getUnreadCount({
          customerId,
          roles: [],
        }),
        this.notificationService.findAll(
          { page: 1, limit: 5 } as NotificationQueryDto,
          { customerId, roles: [] },
        ),
      ]);

    const rewardPoints =
      customer.rewardPoints?.reduce((sum, entry) => sum + entry.point, 0) ?? 0;

    return {
      success: true,
      message: 'Dashboard loaded successfully',
      data: {
        greetingName: customer.fullName.split(' ')[0] ?? customer.fullName,
        activeOrders,
        readyPickup,
        walletBalance: wallet.data?.balance ?? 0,
        rewardPoints,
        unreadNotifications: unreadCount.data?.count ?? 0,
        latestNotifications: (notifications.data?.items ?? []).map((item) => ({
          id: item.id,
          title: item.title,
          message: item.message,
          createdAt: item.createdAt,
          isRead: item.isRead,
        })),
      },
    };
  }

  async getOrders(
    customerId: string,
    query: CustomerOrderQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedOrders>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [orders, total] = await this.orderRepository.findMany({
      page,
      limit,
      customerId,
      status: query.status as OrderStatus | undefined,
      search: query.search,
      dateFrom: query.dateFrom,
      dateTo: query.dateTo,
    });

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

  async getOrderDetail(
    customerId: string,
    orderId: string,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    const order = await this.orderRepository.findById(orderId);

    if (!order || order.customerId !== customerId) {
      throw new NotFoundException('Order not found');
    }

    return {
      success: true,
      message: 'Order retrieved successfully',
      data: toOrderDetail(order),
    };
  }

  async getOrderFeedback(customerId: string, orderId: string) {
    await this.getOrderDetail(customerId, orderId);
    return this.customerServiceService.getOrderFeedback(customerId, orderId);
  }

  async sendOrderFeedback(
    customerId: string,
    orderId: string,
    message: string,
  ) {
    const order = await this.orderRepository.findById(orderId);

    if (!order || order.customerId !== customerId) {
      throw new NotFoundException('Order not found');
    }

    return this.customerServiceService.sendOrderFeedback(
      customerId,
      orderId,
      order.invoiceNumber ?? order.queueNumber,
      message,
    );
  }

  async getOrderTimeline(customerId: string, orderId: string) {
    const detail = await this.getOrderDetail(customerId, orderId);

    return {
      success: true,
      message: 'Order timeline retrieved successfully',
      data: {
        orderId,
        timeline: detail.data?.timeline ?? [],
        statusHistory: detail.data?.statusHistory ?? [],
      },
    };
  }

  async getLaundryTracking(customerId: string, orderId: string) {
    const order = await this.orderRepository.findById(orderId);

    if (!order || order.customerId !== customerId) {
      throw new NotFoundException('Order not found');
    }

    return {
      success: true,
      message: 'Laundry tracking retrieved successfully',
      data: {
        orderId,
        orderStatus: order.orderStatus,
        steps: buildLaundryTracking(
          order.orderStatus,
          order.statusHistories.map((entry) => ({
            toStatus: entry.currentStatus,
            changedAt: entry.createdAt,
          })),
        ),
      },
    };
  }

  async getDeliveryTracking(customerId: string, orderId: string) {
    const order = await this.orderRepository.findById(orderId);

    if (!order || order.customerId !== customerId) {
      throw new NotFoundException('Order not found');
    }

    const deliveryJob = await this.prisma.deliveryJob.findFirst({
      where: { orderId, deletedAt: null },
      include: {
        driver: {
          select: {
            id: true,
            fullName: true,
            phone: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!deliveryJob) {
      return {
        success: true,
        message: 'No active delivery for this order',
        data: null,
      };
    }

    return {
      success: true,
      message: 'Delivery tracking retrieved successfully',
      data: {
        jobId: deliveryJob.id,
        status: deliveryJob.status,
        driver: deliveryJob.driver
          ? {
              id: deliveryJob.driver.id,
              fullName: deliveryJob.driver.fullName,
              phone: deliveryJob.driver.phone,
            }
          : null,
        scheduledDeliveryAt: deliveryJob.scheduledDeliveryAt?.toISOString() ?? null,
        departedAt: deliveryJob.departedAt?.toISOString() ?? null,
        completedAt: deliveryJob.completedAt?.toISOString() ?? null,
      },
    };
  }

  async getServices() {
    const data = await this.catalogService.listServices();
    return {
      success: true,
      message: 'Services retrieved successfully',
      data,
    };
  }

  async getPaymentConfig() {
    const data = await this.paymentConfigService.getCustomerPaymentConfig();
    return {
      success: true,
      message: 'Payment configuration retrieved successfully',
      data,
    };
  }

  async createPickupRequest(
    customerId: string,
    dto: CustomerPickupRequestDto,
  ) {
    const order = await this.orderRepository.findById(dto.orderId);

    if (!order || order.customerId !== customerId) {
      throw new ForbiddenException('Order not found');
    }

    return this.pickupDeliveryService.requestPickup(
      dto.orderId,
      {
        pickupAddressId: dto.pickupAddressId,
        scheduledPickupAt: dto.scheduledPickupAt,
        notes: dto.notes,
      },
      customerId,
    );
  }

  async getRewards(
    customerId: string,
  ): Promise<ApiSuccessResponse<CustomerRewardSummary>> {
    const now = new Date();
    const [currentPoints, points] = await Promise.all([
      this.rewardRedeemService.getAvailableBalance(customerId),
      this.prisma.rewardPoint.findMany({
        where: {
          customerId,
          deletedAt: null,
          type: 'earn',
        },
        select: { point: true, expiredAt: true, remainingPoint: true },
      }),
    ]);

    const expiredPoints = points
      .filter((entry) => entry.expiredAt && entry.expiredAt <= now)
      .reduce((sum, entry) => sum + Math.max(entry.remainingPoint ?? entry.point, 0), 0);

    return {
      success: true,
      message: 'Reward points retrieved successfully',
      data: {
        currentPoints,
        expiredPoints,
      },
    };
  }

  async getRewardCatalog() {
    const data = await this.rewardRedeemService.listCatalog({ activeOnly: true });
    return {
      success: true,
      message: 'Reward catalog retrieved successfully',
      data,
    };
  }

  async getRewardCatalogItem(catalogItemId: string) {
    const data = await this.rewardRedeemService.getCatalogItem(catalogItemId, {
      activeOnly: true,
    });
    return {
      success: true,
      message: 'Reward detail retrieved successfully',
      data,
    };
  }

  async redeemRewards(customerId: string, dto: CustomerRedeemRewardsDto) {
    const data = await this.rewardRedeemService.redeem({
      customerId,
      items: dto.items,
      idempotencyKey: dto.idempotencyKey,
    });
    const availablePoints =
      await this.rewardRedeemService.getAvailableBalance(customerId);

    return {
      success: true,
      message: 'Reward redeemed successfully',
      data: {
        redemption: data,
        availablePoints,
      },
    };
  }

  async getRewardRedemptions(
    customerId: string,
    query: CustomerRewardQueryDto,
  ) {
    const data = await this.rewardRedeemService.listRedemptions(customerId, {
      page: query.page,
      limit: query.limit,
    });
    return {
      success: true,
      message: 'Reward redemptions retrieved successfully',
      data,
    };
  }

  async getRewardRedemption(customerId: string, redemptionId: string) {
    const data = await this.rewardRedeemService.getRedemption(
      customerId,
      redemptionId,
    );
    return {
      success: true,
      message: 'Reward redemption retrieved successfully',
      data,
    };
  }

  async getRewardHistory(
    customerId: string,
    query: CustomerRewardQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedRewardHistory>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;

    const [items, total] = await Promise.all([
      this.prisma.rewardPoint.findMany({
        where: { customerId, deletedAt: null },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.rewardPoint.count({
        where: { customerId, deletedAt: null },
      }),
    ]);

    return {
      success: true,
      message: 'Reward history retrieved successfully',
      data: {
        items: items.map((entry) => ({
          id: entry.id,
          point: entry.point,
          type: entry.type,
          description: entry.description,
          expiredAt: entry.expiredAt?.toISOString() ?? null,
          createdAt: entry.createdAt.toISOString(),
        })),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async getPromos(query: CustomerPromoQueryDto) {
    const data = await this.voucherService.findActiveForCustomer(query);
    return {
      success: true,
      message: 'Promos retrieved successfully',
      data,
    };
  }

  async getPromoDetail(promoId: string) {
    const data = await this.voucherService.findCustomerPromoById(promoId);
    return {
      success: true,
      message: 'Promo retrieved successfully',
      data,
    };
  }

  async quotePromo(dto: CustomerPromoQuoteDto) {
    const data = await this.voucherService.quoteCustomerPromo(dto);
    return {
      success: true,
      message: 'Promo quote calculated successfully',
      data,
    };
  }

  async getPerfumes() {
    const perfumes = await this.perfumeService.listActive();

    return {
      success: true,
      message: 'Perfume options retrieved successfully',
      data: perfumes.map((perfume) => ({
        id: perfume.id,
        code: perfume.code,
        name: perfume.name,
        extraPrice: Number(perfume.extraPrice),
      })),
    };
  }

  async initiateWalletTopUp(customerId: string, dto: CustomerWalletTopUpDto) {
    const result = await this.walletTopUpService.initiate({
      customerId,
      amount: dto.amount,
      paymentMethod: dto.paymentMethod,
    });

    return {
      success: true,
      message: 'Wallet top-up initiated successfully',
      data: {
        requestId: result.request.id,
        referenceNumber: result.request.referenceNumber,
        amount: Number(result.request.amount),
        paymentMethod: result.request.paymentMethod,
        status: result.request.status,
        paymentInstructions: result.paymentInstructions,
      },
    };
  }

  async confirmWalletTopUp(customerId: string, requestId: string) {
    const result = await this.walletTopUpService.confirm(customerId, requestId);
    const wallet = await this.walletService.getWallet(customerId);

    return {
      success: true,
      message: 'Wallet top-up completed successfully',
      data: {
        requestId: result.request.id,
        referenceNumber: result.request.referenceNumber,
        amount: Number(result.request.amount),
        status: result.request.status,
        wallet: wallet.data,
      },
    };
  }

  async getWalletTopUpStatus(customerId: string, requestId: string) {
    const request = await this.walletTopUpService.getStatus(
      customerId,
      requestId,
    );

    return {
      success: true,
      message: 'Wallet top-up status retrieved successfully',
      data: {
        requestId: request.id,
        referenceNumber: request.referenceNumber,
        amount: Number(request.amount),
        paymentMethod: request.paymentMethod,
        status: request.status,
        completedAt: request.completedAt?.toISOString() ?? null,
      },
    };
  }

  async getMissions(customerId: string) {
    const missions = await this.missionService.listForCustomer(customerId);

    return {
      success: true,
      message: 'Missions retrieved successfully',
      data: missions,
    };
  }

  async claimMission(customerId: string, missionId: string) {
    const result = await this.missionService.claimMission(
      customerId,
      missionId,
    );

    return {
      success: true,
      message: 'Mission claimed successfully',
      data: {
        missionId: result.mission.id,
        rewardPoints: result.mission.rewardPoints,
        claimedAt: result.claim.claimedAt.toISOString(),
      },
    };
  }

  async listSupportTickets(customerId: string) {
    return this.customerServiceService.listCustomerTickets(customerId);
  }

  async createSupportTicket(
    customerId: string,
    dto: CreateSupportTicketDto,
  ) {
    return this.customerServiceService.createCustomerTicket(
      customerId,
      dto.category,
      dto.subject,
      dto.message,
    );
  }

  async getSupportTicket(customerId: string, ticketId: string) {
    return this.customerServiceService.getCustomerTicket(customerId, ticketId);
  }

  async sendSupportMessage(
    customerId: string,
    ticketId: string,
    dto: SendSupportMessageDto,
  ) {
    return this.customerServiceService.sendCustomerTicketMessage(
      customerId,
      ticketId,
      dto.message,
    );
  }

  async createOrder(customerId: string, dto: CustomerCreateOrderDto) {
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    if (!customer.isActive) {
      throw new BadRequestException('Customer is inactive');
    }

    const employeeId = await this.resolveSystemEmployeeId();
    const items = await this.buildCustomerOrderItems(dto.items);
    const itemsSubtotal = items.reduce((sum, item) => sum + item.subtotal, 0);
    const discount = 0;
    let serviceFee = 0;

    if (dto.perfumeId) {
      const perfume = await this.perfumeService.getById(dto.perfumeId);
      if (!perfume.isActive) {
        throw new BadRequestException('Selected perfume is not available');
      }
      serviceFee = Number(perfume.extraPrice);
    }

    const tax = await this.taxService.calculateTaxFromSettings(
      itemsSubtotal + serviceFee,
      discount,
    );
    const estimatedFinishDate = new Date();
    estimatedFinishDate.setDate(estimatedFinishDate.getDate() + 3);

    const notes = encodeOrderNotes(
      {
        discount,
        tax,
        serviceFee,
      },
      dto.notes,
    );

    const order = await this.orderRepository.createOrder({
      customerId,
      estimatedFinishDate,
      pickupRequired: dto.pickupRequired ?? true,
      deliveryRequired: dto.deliveryRequired ?? true,
      paymentMethod: dto.paymentMethod,
      notes,
      createdByEmployeeId: employeeId,
      items,
    });

    await this.notificationEventService.publish({
      templateCode: NOTIFICATION_EVENTS.ORDER_CREATED,
      type: API_NOTIFICATION_TYPES.ORDER,
      eventKey: order.id,
      senderEmployeeId: employeeId,
      orderId: order.id,
      orderNumber: order.invoiceNumber,
      customerId,
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

  async payOrder(
    customerId: string,
    orderId: string,
    dto: CustomerPayOrderDto,
  ) {
    const order = await this.paymentRepository.findOrderForPayment(orderId);

    if (!order || order.customerId !== customerId) {
      throw new NotFoundException('Order not found');
    }

    if (order.orderStatus === OrderStatus.CANCELLED) {
      throw new BadRequestException('Cannot pay cancelled order');
    }

    const grandTotal = this.paymentRepository.getOrderGrandTotal(order);
    const paidTotal = order.payments
      .filter((payment) => payment.paymentStatus === PaymentStatus.PAID)
      .reduce((sum, payment) => sum + Number(payment.amount), 0);
    const outstanding = grandTotal - paidTotal;

    if (outstanding <= 0) {
      throw new BadRequestException('Order is already fully paid');
    }

    const employeeId = await this.resolveSystemEmployeeId();
    const { apiMethod, paymentStatus } = this.mapCustomerPaymentMethod(
      dto.paymentMethod,
    );

    await this.paymentService.create(
      {
        orderId,
        paymentMethod: apiMethod,
        amount: outstanding,
        paymentStatus,
        notes: 'Customer app payment',
      },
      employeeId,
    );

    const updated = await this.orderRepository.findById(orderId);

    if (!updated) {
      throw new NotFoundException('Order not found');
    }

    return {
      success: true,
      message: 'Payment processed successfully',
      data: toOrderDetail(updated),
    };
  }

  private async resolveSystemEmployeeId(): Promise<string> {
    const employee = await this.prisma.employee.findFirst({
      where: {
        deletedAt: null,
        status: 'active',
        employeeRoles: {
          some: {
            deletedAt: null,
            role: {
              code: 'owner',
            },
          },
        },
      },
      select: { id: true },
      orderBy: { createdAt: 'asc' },
    });

    if (!employee) {
      throw new UnprocessableEntityException(
        'System employee is not configured for customer orders',
      );
    }

    return employee.id;
  }

  private async buildCustomerOrderItems(
    items: CustomerCreateOrderDto['items'],
  ) {
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

      if (quantity <= 0) {
        throw new BadRequestException('Quantity must be greater than zero');
      }

      builtItems.push({
        serviceId: item.serviceId,
        servicePriceId: price.id,
        quantity,
        weight: service.weight ? quantity : undefined,
        unitPrice,
        subtotal: calculateItemSubtotal(unitPrice, quantity),
      });
    }

    return builtItems;
  }

  private mapCustomerPaymentMethod(code: string): {
    apiMethod: ApiPaymentMethod;
    paymentStatus: PaymentStatus;
  } {
    switch (code.toUpperCase()) {
      case 'YELO_WALLET':
        return {
          apiMethod: ApiPaymentMethod.CUSTOMER_WALLET,
          paymentStatus: PaymentStatus.PAID,
        };
      case 'QRIS':
        return {
          apiMethod: ApiPaymentMethod.QRIS,
          paymentStatus: PaymentStatus.PENDING,
        };
      case 'BANK_TRANSFER':
        return {
          apiMethod: ApiPaymentMethod.BANK_TRANSFER,
          paymentStatus: PaymentStatus.PENDING,
        };
      default:
        throw new BadRequestException('Unsupported payment method');
    }
  }
}
