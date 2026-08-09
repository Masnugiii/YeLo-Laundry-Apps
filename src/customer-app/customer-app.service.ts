import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CustomerRepository } from '../customer/customer.repository';
import { CustomerWalletService } from '../customer/customer-wallet.service';
import { NotificationService } from '../notification/notification.service';
import { NotificationQueryDto } from '../notification/dto/notification.dto';
import {
  OrderDetail,
  PaginatedOrders,
  toOrderDetail,
  toOrderListItem,
} from '../order/order.mapper';
import { OrderRepository } from '../order/order.repository';
import { PickupDeliveryService } from '../pickup-delivery/pickup-delivery.service';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  buildLaundryTracking,
  CustomerDashboardData,
  CustomerRewardSummary,
  PaginatedRewardHistory,
} from './customer-app.mapper';
import {
  CustomerOrderQueryDto,
  CustomerPickupRequestDto,
  CustomerRewardQueryDto,
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
    private readonly notificationService: NotificationService,
    private readonly pickupDeliveryService: PickupDeliveryService,
    private readonly prisma: PrismaService,
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
    const points = await this.prisma.rewardPoint.findMany({
      where: { customerId, deletedAt: null },
    });

    const currentPoints = points
      .filter((entry) => !entry.expiredAt || entry.expiredAt > now)
      .reduce((sum, entry) => sum + entry.point, 0);

    const expiredPoints = points
      .filter((entry) => entry.expiredAt && entry.expiredAt <= now)
      .reduce((sum, entry) => sum + entry.point, 0);

    return {
      success: true,
      message: 'Reward points retrieved successfully',
      data: {
        currentPoints,
        expiredPoints,
      },
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
}
