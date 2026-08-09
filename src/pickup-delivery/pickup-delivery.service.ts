import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { ROLES } from '../auth/constants/roles.constant';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { NotificationEventService } from '../notification/notification-event.service';
import { PickupDeliveryAuditService } from './pickup-delivery-audit.service';
import {
  AssignDriverDto,
  DeliverySuccessDto,
  JobQueryDto,
  PickupSuccessDto,
  RecordTrackingDto,
  RequestDeliveryDto,
  RequestPickupDto,
  TripLocationDto,
} from './dto/pickup-delivery.dto';
import {
  DriverTasksDashboard,
  JobDetailResponse,
  PaginatedJobs,
  PickupDeliveryDashboard,
  toDeliveryJobResponse,
  toPickupJobResponse,
} from './pickup-delivery.mapper';
import { PickupDeliveryRepository } from './pickup-delivery.repository';

const WRITE_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;
const DRIVER_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.DRIVER] as const;

@Injectable()
export class PickupDeliveryService {
  constructor(
    private readonly repository: PickupDeliveryRepository,
    private readonly notificationService: NotificationEventService,
    private readonly auditService: PickupDeliveryAuditService,
  ) {}

  async getDashboard(): Promise<ApiSuccessResponse<PickupDeliveryDashboard>> {
    const [
      pickupRequested,
      driverAssigned,
      onTheWay,
      readyForDelivery,
      deliveredToday,
      failedDelivery,
      completedTrips,
    ] = await this.repository.getDashboardMetrics();

    const durations = completedTrips
      .filter((trip) => trip.departedAt && trip.completedAt)
      .map((trip) =>
        Math.round(
          (trip.completedAt!.getTime() - trip.departedAt!.getTime()) / 60000,
        ),
      );

    const averageDeliveryTimeMinutes =
      durations.length > 0
        ? Math.round(
            durations.reduce((sum, value) => sum + value, 0) / durations.length,
          )
        : 0;

    return {
      success: true,
      message: 'Pickup & delivery dashboard retrieved successfully',
      data: {
        pickupRequested,
        driverAssigned,
        onTheWay,
        readyForDelivery,
        deliveredToday,
        failedDelivery,
        averageDeliveryTimeMinutes,
      },
    };
  }

  async findPickups(
    query: JobQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedJobs>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [jobs, total] = await this.repository.findPickups(query);

    return {
      success: true,
      message: 'Pickup jobs retrieved successfully',
      data: {
        items: jobs.map(toPickupJobResponse),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async findDeliveries(
    query: JobQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedJobs>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [jobs, total] = await this.repository.findDeliveries(query);

    return {
      success: true,
      message: 'Delivery jobs retrieved successfully',
      data: {
        items: jobs.map(toDeliveryJobResponse),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async findJobDetail(id: string): Promise<ApiSuccessResponse<JobDetailResponse>> {
    const resolved = await this.repository.resolveJob(id);

    if (!resolved) {
      throw new NotFoundException('Pickup or delivery job not found');
    }

    return {
      success: true,
      message: 'Job detail retrieved successfully',
      data:
        resolved.type === 'PICKUP'
          ? toPickupJobResponse(resolved.pickup!)
          : toDeliveryJobResponse(resolved.delivery!),
    };
  }

  async requestPickup(
    orderId: string,
    dto: RequestPickupDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    const order = await this.repository.findOrder(orderId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    const addressId =
      dto.pickupAddressId ??
      order.pickupAddressId ??
      order.customer.defaultAddressId;

    if (!addressId) {
      throw new BadRequestException('Customer address is required for pickup');
    }

    const address = await this.repository.findCustomerAddress(
      order.customerId,
      addressId,
    );

    if (!address) {
      throw new BadRequestException('Pickup address not found');
    }

    let job;

    try {
      job = await this.repository.createPickupJob({
        orderId,
        pickupAddressId: addressId,
        scheduledPickupAt: dto.scheduledPickupAt,
        notes: dto.notes,
        employeeId,
      });
    } catch (error) {
      if (error instanceof Error && error.message === 'PICKUP_EXISTS') {
        throw new BadRequestException('Pickup already requested for this order');
      }

      throw error;
    }

    await this.notificationService.publishPickupDeliveryEvent('pickup_requested', {
      orderId,
      orderNumber: order.invoiceNumber,
      employeeId,
      customerId: order.customerId,
    });

    await this.auditService.log({
      employeeId,
      action: 'pickup_requested',
      referenceId: job.id,
      description: `Pickup requested for order ${order.invoiceNumber}`,
    });

    return {
      success: true,
      message: 'Pickup requested successfully',
      data: toPickupJobResponse(job),
    };
  }

  async requestDelivery(
    orderId: string,
    dto: RequestDeliveryDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    const order = await this.repository.findOrder(orderId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.orderStatus !== OrderStatus.READY_FOR_PICKUP) {
      throw new BadRequestException(
        'Order must be ready for pickup before requesting delivery',
      );
    }

    const addressId =
      dto.deliveryAddressId ??
      order.deliveryAddressId ??
      order.customer.defaultAddressId;

    if (!addressId) {
      throw new BadRequestException('Customer address is required for delivery');
    }

    const address = await this.repository.findCustomerAddress(
      order.customerId,
      addressId,
    );

    if (!address) {
      throw new BadRequestException('Delivery address not found');
    }

    let job;

    try {
      job = await this.repository.createDeliveryJob({
        orderId,
        deliveryAddressId: addressId,
        scheduledDeliveryAt: dto.scheduledDeliveryAt,
        notes: dto.notes,
        employeeId,
      });
    } catch (error) {
      if (error instanceof Error && error.message === 'DELIVERY_EXISTS') {
        throw new BadRequestException(
          'Delivery already requested for this order',
        );
      }

      throw error;
    }

    await this.notificationService.publishPickupDeliveryEvent('ready_for_delivery', {
      orderId,
      orderNumber: order.invoiceNumber,
      employeeId,
      customerId: order.customerId,
    });

    return {
      success: true,
      message: 'Delivery requested successfully',
      data: toDeliveryJobResponse(job),
    };
  }

  async assignDriver(
    jobId: string,
    dto: AssignDriverDto,
    employeeId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    if (!this.canAssign(roles)) {
      throw new ForbiddenException('Insufficient permissions to assign driver');
    }

    const driver = await this.repository.findDriver(dto.driverId);

    if (!driver) {
      throw new NotFoundException('Driver not found');
    }

    const hasDriverRole = driver.employeeRoles.some(
      (entry) => entry.role.code === 'driver',
    );

    if (!hasDriverRole && !roles.includes(ROLES.OWNER)) {
      throw new BadRequestException('Selected employee is not a driver');
    }

    const hasActiveTrip = await this.repository.hasActiveTrip(dto.driverId, jobId);

    if (hasActiveTrip) {
      throw new BadRequestException('Driver already has an active trip');
    }

    const resolved = await this.repository.resolveJob(jobId);

    if (!resolved) {
      throw new NotFoundException('Job not found');
    }

    const route = {
      estimatedDistanceKm: dto.estimatedDistanceKm,
      estimatedDurationMinutes: dto.estimatedDurationMinutes,
    };

    let response: JobDetailResponse;

    try {
      if (resolved.type === 'PICKUP') {
        const pickupJob = await this.repository.assignDriverPickup(
          jobId,
          dto.driverId,
          employeeId,
          route,
        );
        response = toPickupJobResponse(pickupJob);
      } else {
        const deliveryJob = await this.repository.assignDriverDelivery(
          jobId,
          dto.driverId,
          employeeId,
          route,
        );
        response = toDeliveryJobResponse(deliveryJob);
      }
    } catch (error) {
      this.handleWorkflowError(error);
    }

    await this.notificationService.publishPickupDeliveryEvent('driver_assigned', {
      orderId: response!.orderId,
      orderNumber: response!.order.orderNumber,
      employeeId,
      driverId: dto.driverId,
      driverName: driver.fullName,
      customerId: response!.order.customerId,
      customerName: response!.order.customerName,
    });

    return {
      success: true,
      message: 'Driver assigned successfully',
      data: response!,
    };
  }

  async startTrip(
    jobId: string,
    dto: TripLocationDto,
    employeeId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    this.ensureDriver(roles);

    const resolved = await this.repository.resolveJob(jobId);

    if (!resolved) {
      throw new NotFoundException('Job not found');
    }

    const hasActiveTrip = await this.repository.hasActiveTrip(employeeId, jobId);

    if (hasActiveTrip) {
      throw new BadRequestException('Driver already has an active trip');
    }

    let response: JobDetailResponse;

    try {
      if (resolved.type === 'PICKUP') {
        const pickupJob = await this.repository.startPickupTrip(
          jobId,
          employeeId,
          dto,
        );
        response = toPickupJobResponse(pickupJob);
      } else {
        const deliveryJob = await this.repository.startDeliveryTrip(
          jobId,
          employeeId,
          dto,
        );
        response = toDeliveryJobResponse(deliveryJob);
      }
    } catch (error) {
      this.handleWorkflowError(error);
    }

    await this.notificationService.publishPickupDeliveryEvent(
      resolved.type === 'PICKUP' ? 'driver_on_the_way' : 'delivery_started',
      {
        orderId: response!.orderId,
        orderNumber: response!.order.orderNumber,
        employeeId,
        driverId: employeeId,
        customerId: response!.order.customerId,
        customerName: response!.order.customerName,
      },
    );

    return {
      success: true,
      message: 'Trip started successfully',
      data: response!,
    };
  }

  async arrived(
    jobId: string,
    dto: TripLocationDto,
    employeeId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    this.ensureDriver(roles);

    const resolved = await this.repository.resolveJob(jobId);

    if (!resolved) {
      throw new NotFoundException('Job not found');
    }

    let response: JobDetailResponse;

    try {
      if (resolved.type === 'PICKUP') {
        const pickupJob = await this.repository.arrivePickup(
          jobId,
          employeeId,
          dto,
        );
        response = toPickupJobResponse(pickupJob);
      } else {
        const deliveryJob = await this.repository.arriveDelivery(
          jobId,
          employeeId,
          dto,
        );
        response = toDeliveryJobResponse(deliveryJob);
      }
    } catch (error) {
      this.handleWorkflowError(error);
    }

    return {
      success: true,
      message: 'Arrival recorded successfully',
      data: response!,
    };
  }

  async pickupSuccess(
    jobId: string,
    dto: PickupSuccessDto,
    employeeId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    this.ensureDriver(roles);

    let job;

    try {
      job = await this.repository.completePickup(jobId, employeeId, dto);
    } catch (error) {
      this.handleWorkflowError(error);
    }

    await this.notificationService.publishPickupDeliveryEvent('pickup_completed', {
      orderId: job!.orderId,
      orderNumber: job!.order.invoiceNumber,
      employeeId,
      customerId: job!.order.customer.id,
      customerName: job!.order.customer.fullName,
    });

    return {
      success: true,
      message: 'Pickup completed successfully',
      data: toPickupJobResponse(job!),
    };
  }

  async deliverySuccess(
    jobId: string,
    dto: DeliverySuccessDto,
    employeeId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<JobDetailResponse>> {
    this.ensureDriver(roles);

    let job;

    try {
      job = await this.repository.completeDelivery(jobId, employeeId, dto);
    } catch (error) {
      this.handleWorkflowError(error);
    }

    await this.notificationService.publishPickupDeliveryEvent('delivery_completed', {
      orderId: job!.orderId,
      orderNumber: job!.order.invoiceNumber,
      employeeId,
      customerId: job!.order.customer.id,
      customerName: job!.order.customer.fullName,
    });

    return {
      success: true,
      message: 'Delivery completed successfully',
      data: toDeliveryJobResponse(job!),
    };
  }

  async recordTracking(
    jobId: string,
    dto: RecordTrackingDto,
    employeeId: string,
    roles: string[],
  ) {
    this.ensureDriver(roles);

    const resolved = await this.repository.resolveJob(jobId);

    if (!resolved) {
      throw new NotFoundException('Job not found');
    }

    const point = await this.repository.recordTracking(
      jobId,
      employeeId,
      resolved.type,
      dto,
    );

    return {
      success: true,
      message: 'Tracking point recorded successfully',
      data: point,
    };
  }

  async getTracking(jobId: string) {
    const resolved = await this.repository.resolveJob(jobId);

    if (!resolved) {
      throw new NotFoundException('Job not found');
    }

    const job =
      resolved.type === 'PICKUP'
        ? toPickupJobResponse(resolved.pickup!)
        : toDeliveryJobResponse(resolved.delivery!);

    const activities = await this.repository.getDriverActivities(job.orderId);

    return {
      success: true,
      message: 'Tracking data retrieved successfully',
      data: {
        jobId,
        jobType: resolved.type,
        orderId: job.orderId,
        tracking: job.tracking,
        activities,
      },
    };
  }

  async getDriverTasks(
    employeeId: string,
  ): Promise<ApiSuccessResponse<DriverTasksDashboard>> {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const [pickups, deliveries] =
      await this.repository.getDriverTasks(employeeId, startOfDay);

    const todayPickups = pickups.map(toPickupJobResponse);
    const todayDeliveries = deliveries.map(toDeliveryJobResponse);

    const completedTasks =
      todayPickups.filter((job) => job.completedAt).length +
      todayDeliveries.filter((job) => job.completedAt).length;

    const pendingTasks =
      todayPickups.filter((job) => !job.completedAt).length +
      todayDeliveries.filter((job) => !job.completedAt).length;

    return {
      success: true,
      message: 'Driver tasks retrieved successfully',
      data: {
        todayPickups,
        todayDeliveries,
        completedTasks,
        pendingTasks,
      },
    };
  }

  private canAssign(roles: string[]): boolean {
    return WRITE_ROLES.some((role) => roles.includes(role));
  }

  private ensureDriver(roles: string[]): void {
    if (!DRIVER_ROLES.some((role) => roles.includes(role))) {
      throw new ForbiddenException('Only drivers can perform this action');
    }
  }

  private handleWorkflowError(error: unknown): never {
    if (error instanceof Error) {
      switch (error.message) {
        case 'NOT_FOUND':
          throw new NotFoundException('Job not found');
        case 'INVALID_STATUS':
        case 'INVALID_TRANSITION':
          throw new BadRequestException('Invalid job status transition');
        case 'NOT_ASSIGNED_DRIVER':
          throw new ForbiddenException('Only assigned driver can update this job');
        case 'NOT_ARRIVED':
          throw new BadRequestException('Driver must arrive before completing job');
        case 'ORDER_NOT_READY':
          throw new BadRequestException('Order is not ready for delivery');
        case 'DUPLICATE_ASSIGNMENT':
          throw new BadRequestException('Duplicate driver assignment');
      }
    }

    throw error;
  }
}
