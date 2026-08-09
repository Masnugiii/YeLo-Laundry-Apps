import { Injectable } from '@nestjs/common';
import {
  DeliveryStatus,
  DriverActivityType,
  OrderStatus,
  PhotoType,
  PickupStatus,
  Prisma,
  TimelineType,
} from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { JobQueryDto } from './dto/pickup-delivery.dto';
import {
  deliveryJobListSelect,
  DeliveryJobRecord,
  driverActivitySelect,
  pickupJobListSelect,
  PickupJobRecord,
} from './pickup-delivery.select';
import { mergeJobMeta } from './pickup-delivery.mapper';
import {
  appendTrackingPoint,
  decodeJobNotes,
  JobMeta,
} from './utils/job-meta.util';
import {
  ACTIVE_DELIVERY_STATUSES,
  ACTIVE_PICKUP_STATUSES,
} from './utils/status-mapper.util';

export interface ResolvedJob {
  type: 'PICKUP' | 'DELIVERY';
  pickup?: PickupJobRecord;
  delivery?: DeliveryJobRecord;
}

@Injectable()
export class PickupDeliveryRepository {
  constructor(private readonly prisma: PrismaService) {}

  findPickups(query: JobQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildPickupWhere(query);

    return this.prisma.$transaction([
      this.prisma.pickupJob.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: pickupJobListSelect,
      }),
      this.prisma.pickupJob.count({ where }),
    ]);
  }

  findDeliveries(query: JobQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const where = this.buildDeliveryWhere(query);

    return this.prisma.$transaction([
      this.prisma.deliveryJob.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: deliveryJobListSelect,
      }),
      this.prisma.deliveryJob.count({ where }),
    ]);
  }

  async resolveJob(jobId: string): Promise<ResolvedJob | null> {
    const pickup = await this.prisma.pickupJob.findFirst({
      where: { id: jobId, deletedAt: null },
      select: pickupJobListSelect,
    });

    if (pickup) {
      return { type: 'PICKUP', pickup };
    }

    const delivery = await this.prisma.deliveryJob.findFirst({
      where: { id: jobId, deletedAt: null },
      select: deliveryJobListSelect,
    });

    if (delivery) {
      return { type: 'DELIVERY', delivery };
    }

    return null;
  }

  findOrder(orderId: string) {
    return this.prisma.order.findFirst({
      where: { id: orderId, deletedAt: null },
      select: {
        id: true,
        invoiceNumber: true,
        customerId: true,
        orderStatus: true,
        pickupRequired: true,
        deliveryRequired: true,
        pickupAddressId: true,
        deliveryAddressId: true,
        receivedDate: true,
        customer: {
          select: {
            id: true,
            defaultAddressId: true,
          },
        },
      },
    });
  }

  findCustomerAddress(customerId: string, addressId: string) {
    return this.prisma.customerAddress.findFirst({
      where: { id: addressId, customerId, deletedAt: null },
      select: { id: true },
    });
  }

  findDriver(driverId: string) {
    return this.prisma.employee.findFirst({
      where: { id: driverId, deletedAt: null },
      select: {
        id: true,
        fullName: true,
        employeeCode: true,
        employeeRoles: {
          where: { deletedAt: null },
          select: { role: { select: { code: true } } },
        },
      },
    });
  }

  async hasActiveTrip(driverId: string, excludeJobId?: string) {
    const [pickupCount, deliveryCount] = await this.prisma.$transaction([
      this.prisma.pickupJob.count({
        where: {
          driverId,
          deletedAt: null,
          status: { in: ACTIVE_PICKUP_STATUSES },
          ...(excludeJobId ? { NOT: { id: excludeJobId } } : {}),
        },
      }),
      this.prisma.deliveryJob.count({
        where: {
          driverId,
          deletedAt: null,
          status: { in: ACTIVE_DELIVERY_STATUSES },
          ...(excludeJobId ? { NOT: { id: excludeJobId } } : {}),
        },
      }),
    ]);

    return pickupCount + deliveryCount > 0;
  }

  createPickupJob(params: {
    orderId: string;
    pickupAddressId: string;
    scheduledPickupAt?: Date;
    notes?: string;
    employeeId: string;
  }) {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.pickupJob.findFirst({
        where: { orderId: params.orderId, deletedAt: null },
      });

      if (existing) {
        throw new Error('PICKUP_EXISTS');
      }

      const job = await tx.pickupJob.create({
        data: {
          orderId: params.orderId,
          pickupAddressId: params.pickupAddressId,
          scheduledPickupAt: params.scheduledPickupAt,
          notes: params.notes ?? null,
          status: PickupStatus.WAITING_ASSIGNMENT,
        },
        select: pickupJobListSelect,
      });

      await tx.order.update({
        where: { id: params.orderId },
        data: {
          pickupRequired: true,
          pickupAddressId: params.pickupAddressId,
          orderStatus: OrderStatus.WAITING_PICKUP_DRIVER,
          updatedByEmployeeId: params.employeeId,
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: params.orderId,
          timelineType: TimelineType.PICKUP,
          title: 'Pickup requested',
          description: params.notes,
          employeeId: params.employeeId,
        },
      });

      return job;
    });
  }

  createDeliveryJob(params: {
    orderId: string;
    deliveryAddressId: string;
    scheduledDeliveryAt?: Date;
    notes?: string;
    employeeId: string;
  }) {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.deliveryJob.findFirst({
        where: { orderId: params.orderId, deletedAt: null },
      });

      if (existing) {
        throw new Error('DELIVERY_EXISTS');
      }

      const job = await tx.deliveryJob.create({
        data: {
          orderId: params.orderId,
          deliveryAddressId: params.deliveryAddressId,
          scheduledDeliveryAt: params.scheduledDeliveryAt,
          notes: params.notes ?? null,
          status: DeliveryStatus.WAITING_ASSIGNMENT,
        },
        select: deliveryJobListSelect,
      });

      await tx.order.update({
        where: { id: params.orderId },
        data: {
          deliveryRequired: true,
          deliveryAddressId: params.deliveryAddressId,
          orderStatus: OrderStatus.WAITING_DELIVERY,
          updatedByEmployeeId: params.employeeId,
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: params.orderId,
          timelineType: TimelineType.DELIVERY,
          title: 'Delivery requested',
          description: params.notes,
          employeeId: params.employeeId,
        },
      });

      return job;
    });
  }

  assignDriverPickup(
    jobId: string,
    driverId: string,
    assignerId: string,
    route?: JobMeta['route'],
  ) {
    return this.prisma.$transaction(async (tx) => {
      const job = await tx.pickupJob.findFirst({
        where: { id: jobId, deletedAt: null },
        select: pickupJobListSelect,
      });

      if (!job) {
        throw new Error('NOT_FOUND');
      }

      if (job.status !== PickupStatus.WAITING_ASSIGNMENT) {
        throw new Error('INVALID_STATUS');
      }

      const duplicate = await tx.pickupJob.findFirst({
        where: {
          driverId,
          orderId: job.orderId,
          deletedAt: null,
          NOT: { id: jobId },
        },
      });

      if (duplicate) {
        throw new Error('DUPLICATE_ASSIGNMENT');
      }

      const updated = await tx.pickupJob.update({
        where: { id: jobId },
        data: {
          driverId,
          status: PickupStatus.ASSIGNED,
          assignedAt: new Date(),
          notes: mergeJobMeta(job.notes, {
            assignedByEmployeeId: assignerId,
            route,
          }),
        },
        select: pickupJobListSelect,
      });

      await tx.driverActivity.create({
        data: {
          driverId,
          orderId: job.orderId,
          activityType: DriverActivityType.ASSIGNMENT_RECEIVED,
          description: 'Pickup assignment received',
        },
      });

      return updated;
    });
  }

  assignDriverDelivery(
    jobId: string,
    driverId: string,
    assignerId: string,
    route?: JobMeta['route'],
  ) {
    return this.prisma.$transaction(async (tx) => {
      const job = await tx.deliveryJob.findFirst({
        where: { id: jobId, deletedAt: null },
        select: deliveryJobListSelect,
      });

      if (!job) {
        throw new Error('NOT_FOUND');
      }

      if (job.status !== DeliveryStatus.WAITING_ASSIGNMENT) {
        throw new Error('INVALID_STATUS');
      }

      if (
        job.order.orderStatus !== OrderStatus.READY_FOR_PICKUP &&
        job.order.orderStatus !== OrderStatus.WAITING_DELIVERY
      ) {
        throw new Error('ORDER_NOT_READY');
      }

      const updated = await tx.deliveryJob.update({
        where: { id: jobId },
        data: {
          driverId,
          status: DeliveryStatus.ASSIGNED,
          assignedAt: new Date(),
          notes: mergeJobMeta(job.notes, {
            assignedByEmployeeId: assignerId,
            route,
          }),
        },
        select: deliveryJobListSelect,
      });

      await tx.driverActivity.create({
        data: {
          driverId,
          orderId: job.orderId,
          activityType: DriverActivityType.ASSIGNMENT_RECEIVED,
          description: 'Delivery assignment received',
        },
      });

      return updated;
    });
  }

  startPickupTrip(
    jobId: string,
    driverId: string,
    location?: { latitude?: number; longitude?: number },
  ) {
    return this.updatePickupStatus(jobId, driverId, PickupStatus.ON_THE_WAY, {
      activityType: DriverActivityType.PICKUP_STARTED,
      routePatch: { tripStartedAt: new Date().toISOString() },
      location,
    });
  }

  arrivePickup(
    jobId: string,
    driverId: string,
    location?: { latitude?: number; longitude?: number },
  ) {
    return this.updatePickupStatus(jobId, driverId, PickupStatus.ARRIVED, {
      activityType: DriverActivityType.LOCATION_UPDATED,
      setArrivedAt: true,
      location,
    });
  }

  completePickup(
    jobId: string,
    driverId: string,
    proof: { photoUrl: string; notes?: string },
  ) {
    return this.prisma.$transaction(async (tx) => {
      const job = await this.getPickupForDriver(tx, jobId, driverId);

      if (job.status !== PickupStatus.ARRIVED) {
        throw new Error('NOT_ARRIVED');
      }

      const now = new Date();
      const { meta } = decodeJobNotes(job.notes);

      const updated = await tx.pickupJob.update({
        where: { id: jobId },
        data: {
          status: PickupStatus.COMPLETED,
          completedAt: now,
          notes: mergeJobMeta(job.notes, {
            displayStatus: 'RECEIVED',
            proof: {
              photoUrl: proof.photoUrl,
              notes: proof.notes,
              completedAt: now.toISOString(),
              employeeId: driverId,
            },
            route: {
              ...meta.route,
              tripEndedAt: now.toISOString(),
            },
          }),
        },
        select: pickupJobListSelect,
      });

      await tx.order.update({
        where: { id: job.orderId },
        data: {
          receivedDate: now,
          orderStatus: OrderStatus.PICKUP_COMPLETED,
          updatedByEmployeeId: driverId,
        },
      });

      await tx.orderPhoto.create({
        data: {
          orderId: job.orderId,
          photoType: PhotoType.CUSTOMER_ITEM,
          photoUrl: proof.photoUrl,
          uploadedByEmployeeId: driverId,
          description: proof.notes,
        },
      });

      await tx.driverActivity.create({
        data: {
          driverId,
          orderId: job.orderId,
          activityType: DriverActivityType.PICKUP_COMPLETED,
          description: proof.notes,
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: job.orderId,
          timelineType: TimelineType.PICKUP,
          title: 'Pickup completed',
          description: proof.notes,
          employeeId: driverId,
        },
      });

      return updated;
    });
  }

  startDeliveryTrip(
    jobId: string,
    driverId: string,
    location?: { latitude?: number; longitude?: number },
  ) {
    return this.updateDeliveryStatus(
      jobId,
      driverId,
      DeliveryStatus.OUT_FOR_DELIVERY,
      {
        activityType: DriverActivityType.DELIVERY_STARTED,
        routePatch: { tripStartedAt: new Date().toISOString() },
        setDepartedAt: true,
        location,
      },
    );
  }

  arriveDelivery(
    jobId: string,
    driverId: string,
    location?: { latitude?: number; longitude?: number },
  ) {
    return this.updateDeliveryStatus(jobId, driverId, DeliveryStatus.ARRIVED, {
      activityType: DriverActivityType.LOCATION_UPDATED,
      location,
    });
  }

  completeDelivery(
    jobId: string,
    driverId: string,
    proof: { photoUrl: string; receiverName: string; notes?: string },
  ) {
    return this.prisma.$transaction(async (tx) => {
      const job = await this.getDeliveryForDriver(tx, jobId, driverId);

      if (job.status !== DeliveryStatus.ARRIVED) {
        throw new Error('NOT_ARRIVED');
      }

      const now = new Date();
      const { meta } = decodeJobNotes(job.notes);

      const updated = await tx.deliveryJob.update({
        where: { id: jobId },
        data: {
          status: DeliveryStatus.COMPLETED,
          completedAt: now,
          proofPhotoUrl: proof.photoUrl,
          notes: mergeJobMeta(job.notes, {
            displayStatus: 'DELIVERED',
            proof: {
              photoUrl: proof.photoUrl,
              receiverName: proof.receiverName,
              notes: proof.notes,
              completedAt: now.toISOString(),
              employeeId: driverId,
            },
            route: {
              ...meta.route,
              tripEndedAt: now.toISOString(),
            },
          }, proof.notes),
        },
        select: deliveryJobListSelect,
      });

      await tx.order.update({
        where: { id: job.orderId },
        data: {
          orderStatus: OrderStatus.DELIVERED,
          completedDate: now,
          updatedByEmployeeId: driverId,
        },
      });

      await tx.orderPhoto.create({
        data: {
          orderId: job.orderId,
          photoType: PhotoType.DELIVERY_PROOF,
          photoUrl: proof.photoUrl,
          uploadedByEmployeeId: driverId,
          description: `${proof.receiverName}${proof.notes ? ` - ${proof.notes}` : ''}`,
        },
      });

      await tx.driverActivity.create({
        data: {
          driverId,
          orderId: job.orderId,
          activityType: DriverActivityType.DELIVERY_COMPLETED,
          description: proof.notes,
        },
      });

      await tx.orderTimeline.create({
        data: {
          orderId: job.orderId,
          timelineType: TimelineType.DELIVERY,
          title: 'Delivery completed',
          description: `Received by ${proof.receiverName}`,
          employeeId: driverId,
        },
      });

      return updated;
    });
  }

  recordTracking(
    jobId: string,
    driverId: string,
    type: 'PICKUP' | 'DELIVERY',
    point: { latitude: number; longitude: number; speed?: number },
  ) {
    return this.prisma.$transaction(async (tx) => {
      const recordedAt = new Date().toISOString();
      const trackingPoint = { ...point, recordedAt };

      if (type === 'PICKUP') {
        const job = await this.getPickupForDriver(tx, jobId, driverId);
        const { meta } = decodeJobNotes(job.notes);

        await tx.pickupJob.update({
          where: { id: jobId },
          data: {
            notes: mergeJobMeta(job.notes, {
              tracking: appendTrackingPoint(meta, trackingPoint).tracking,
            }),
          },
        });
      } else {
        const job = await this.getDeliveryForDriver(tx, jobId, driverId);
        const { meta } = decodeJobNotes(job.notes);

        await tx.deliveryJob.update({
          where: { id: jobId },
          data: {
            notes: mergeJobMeta(job.notes, {
              tracking: appendTrackingPoint(meta, trackingPoint).tracking,
            }),
          },
        });
      }

      await tx.driverActivity.create({
        data: {
          driverId,
          orderId:
            type === 'PICKUP'
              ? (await tx.pickupJob.findUniqueOrThrow({ where: { id: jobId } }))
                  .orderId
              : (await tx.deliveryJob.findUniqueOrThrow({ where: { id: jobId } }))
                  .orderId,
          activityType: DriverActivityType.LOCATION_UPDATED,
          latitude: point.latitude,
          longitude: point.longitude,
          description: point.speed
            ? `Speed ${point.speed} km/h`
            : 'Location updated',
        },
      });

      return trackingPoint;
    });
  }

  getDriverTasks(driverId: string, startOfDay: Date) {
    return this.prisma.$transaction([
      this.prisma.pickupJob.findMany({
        where: {
          driverId,
          deletedAt: null,
          createdAt: { gte: startOfDay },
        },
        orderBy: { scheduledPickupAt: 'asc' },
        select: pickupJobListSelect,
      }),
      this.prisma.deliveryJob.findMany({
        where: {
          driverId,
          deletedAt: null,
          createdAt: { gte: startOfDay },
        },
        orderBy: { scheduledDeliveryAt: 'asc' },
        select: deliveryJobListSelect,
      }),
    ]);
  }

  getDashboardMetrics() {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    return this.prisma.$transaction([
      this.prisma.pickupJob.count({
        where: {
          deletedAt: null,
          status: PickupStatus.WAITING_ASSIGNMENT,
        },
      }),
      this.prisma.pickupJob.count({
        where: {
          deletedAt: null,
          status: { in: [PickupStatus.ASSIGNED, PickupStatus.ACCEPTED] },
        },
      }),
      this.prisma.pickupJob.count({
        where: {
          deletedAt: null,
          status: { in: [PickupStatus.ON_THE_WAY, PickupStatus.ARRIVED] },
        },
      }),
      this.prisma.deliveryJob.count({
        where: {
          deletedAt: null,
          status: DeliveryStatus.WAITING_ASSIGNMENT,
          order: { orderStatus: OrderStatus.READY_FOR_PICKUP },
        },
      }),
      this.prisma.deliveryJob.count({
        where: {
          deletedAt: null,
          status: DeliveryStatus.COMPLETED,
          completedAt: { gte: startOfDay },
        },
      }),
      this.prisma.deliveryJob.count({
        where: {
          deletedAt: null,
          status: DeliveryStatus.FAILED,
          updatedAt: { gte: startOfDay },
        },
      }),
      this.prisma.deliveryJob.findMany({
        where: {
          deletedAt: null,
          status: DeliveryStatus.COMPLETED,
          completedAt: { not: null },
          departedAt: { not: null },
        },
        select: {
          departedAt: true,
          completedAt: true,
        },
        take: 100,
        orderBy: { completedAt: 'desc' },
      }),
    ]);
  }

  getDriverActivities(orderId: string) {
    return this.prisma.driverActivity.findMany({
      where: { orderId },
      orderBy: { createdAt: 'asc' },
      select: driverActivitySelect,
    });
  }

  private async updatePickupStatus(
    jobId: string,
    driverId: string,
    status: PickupStatus,
    options: {
      activityType: DriverActivityType;
      routePatch?: JobMeta['route'];
      setArrivedAt?: boolean;
      location?: { latitude?: number; longitude?: number };
    },
  ) {
    return this.prisma.$transaction(async (tx) => {
      const job = await this.getPickupForDriver(tx, jobId, driverId);
      this.validatePickupTransition(job.status, status);

      const { meta } = decodeJobNotes(job.notes);

      const updated = await tx.pickupJob.update({
        where: { id: jobId },
        data: {
          status,
          ...(options.setArrivedAt ? { arrivedAt: new Date() } : {}),
          notes: mergeJobMeta(job.notes, {
            route: { ...meta.route, ...options.routePatch },
          }),
        },
        select: pickupJobListSelect,
      });

      await tx.driverActivity.create({
        data: {
          driverId,
          orderId: job.orderId,
          activityType: options.activityType,
          latitude: options.location?.latitude,
          longitude: options.location?.longitude,
          description: `Pickup status ${status}`,
        },
      });

      return updated;
    });
  }

  private async updateDeliveryStatus(
    jobId: string,
    driverId: string,
    status: DeliveryStatus,
    options: {
      activityType: DriverActivityType;
      routePatch?: JobMeta['route'];
      setDepartedAt?: boolean;
      location?: { latitude?: number; longitude?: number };
    },
  ) {
    return this.prisma.$transaction(async (tx) => {
      const job = await this.getDeliveryForDriver(tx, jobId, driverId);
      this.validateDeliveryTransition(job.status, status);

      const { meta } = decodeJobNotes(job.notes);

      const updated = await tx.deliveryJob.update({
        where: { id: jobId },
        data: {
          status,
          ...(options.setDepartedAt ? { departedAt: new Date() } : {}),
          notes: mergeJobMeta(job.notes, {
            route: { ...meta.route, ...options.routePatch },
          }),
        },
        select: deliveryJobListSelect,
      });

      if (status === DeliveryStatus.OUT_FOR_DELIVERY) {
        await tx.order.update({
          where: { id: job.orderId },
          data: { orderStatus: OrderStatus.OUT_FOR_DELIVERY },
        });
      }

      await tx.driverActivity.create({
        data: {
          driverId,
          orderId: job.orderId,
          activityType: options.activityType,
          latitude: options.location?.latitude,
          longitude: options.location?.longitude,
          description: `Delivery status ${status}`,
        },
      });

      return updated;
    });
  }

  private validatePickupTransition(
    current: PickupStatus,
    next: PickupStatus,
  ) {
    const allowed: Record<PickupStatus, PickupStatus[]> = {
      [PickupStatus.WAITING_ASSIGNMENT]: [],
      [PickupStatus.ASSIGNED]: [PickupStatus.ON_THE_WAY],
      [PickupStatus.ACCEPTED]: [PickupStatus.ON_THE_WAY],
      [PickupStatus.ON_THE_WAY]: [PickupStatus.ARRIVED],
      [PickupStatus.ARRIVED]: [PickupStatus.COMPLETED],
      [PickupStatus.COMPLETED]: [],
      [PickupStatus.CANCELLED]: [],
    };

    if (!allowed[current]?.includes(next)) {
      throw new Error('INVALID_TRANSITION');
    }
  }

  private validateDeliveryTransition(
    current: DeliveryStatus,
    next: DeliveryStatus,
  ) {
    const allowed: Record<DeliveryStatus, DeliveryStatus[]> = {
      [DeliveryStatus.WAITING_ASSIGNMENT]: [],
      [DeliveryStatus.ASSIGNED]: [DeliveryStatus.OUT_FOR_DELIVERY],
      [DeliveryStatus.ACCEPTED]: [DeliveryStatus.OUT_FOR_DELIVERY],
      [DeliveryStatus.OUT_FOR_DELIVERY]: [DeliveryStatus.ARRIVED],
      [DeliveryStatus.ARRIVED]: [DeliveryStatus.COMPLETED],
      [DeliveryStatus.COMPLETED]: [],
      [DeliveryStatus.FAILED]: [],
      [DeliveryStatus.CANCELLED]: [],
    };

    if (!allowed[current]?.includes(next)) {
      throw new Error('INVALID_TRANSITION');
    }
  }

  private async getPickupForDriver(
    tx: Prisma.TransactionClient,
    jobId: string,
    driverId: string,
  ) {
    const job = await tx.pickupJob.findFirst({
      where: { id: jobId, deletedAt: null },
      select: pickupJobListSelect,
    });

    if (!job) {
      throw new Error('NOT_FOUND');
    }

    if (job.driverId !== driverId) {
      throw new Error('NOT_ASSIGNED_DRIVER');
    }

    return job;
  }

  private async getDeliveryForDriver(
    tx: Prisma.TransactionClient,
    jobId: string,
    driverId: string,
  ) {
    const job = await tx.deliveryJob.findFirst({
      where: { id: jobId, deletedAt: null },
      select: deliveryJobListSelect,
    });

    if (!job) {
      throw new Error('NOT_FOUND');
    }

    if (job.driverId !== driverId) {
      throw new Error('NOT_ASSIGNED_DRIVER');
    }

    return job;
  }

  private buildPickupWhere(query: JobQueryDto): Prisma.PickupJobWhereInput {
    const where: Prisma.PickupJobWhereInput = { deletedAt: null };

    if (query.driverId) {
      where.driverId = query.driverId;
    }

    if (query.status) {
      where.status = this.mapApiPickupStatusToPrisma(query.status);
    }

    if (query.dateFrom || query.dateTo) {
      where.createdAt = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    if (query.search) {
      const search = query.search.trim();
      where.order = {
        OR: [
          { invoiceNumber: { contains: search, mode: 'insensitive' } },
          {
            customer: {
              OR: [
                { fullName: { contains: search, mode: 'insensitive' } },
                { phone: { contains: search, mode: 'insensitive' } },
              ],
            },
          },
        ],
      };
    }

    return where;
  }

  private buildDeliveryWhere(query: JobQueryDto): Prisma.DeliveryJobWhereInput {
    const where: Prisma.DeliveryJobWhereInput = { deletedAt: null };

    if (query.driverId) {
      where.driverId = query.driverId;
    }

    if (query.status) {
      where.status = this.mapApiDeliveryStatusToPrisma(query.status);
    }

    if (query.dateFrom || query.dateTo) {
      where.createdAt = {
        ...(query.dateFrom ? { gte: query.dateFrom } : {}),
        ...(query.dateTo ? { lte: query.dateTo } : {}),
      };
    }

    if (query.search) {
      const search = query.search.trim();
      where.order = {
        OR: [
          { invoiceNumber: { contains: search, mode: 'insensitive' } },
          {
            customer: {
              OR: [
                { fullName: { contains: search, mode: 'insensitive' } },
                { phone: { contains: search, mode: 'insensitive' } },
              ],
            },
          },
        ],
      };
    }

    return where;
  }

  private mapApiPickupStatusToPrisma(status: string): PickupStatus {
    switch (status) {
      case 'REQUESTED':
        return PickupStatus.WAITING_ASSIGNMENT;
      case 'ASSIGNED':
        return PickupStatus.ASSIGNED;
      case 'ON_THE_WAY':
        return PickupStatus.ON_THE_WAY;
      case 'ARRIVED':
        return PickupStatus.ARRIVED;
      case 'PICKED_UP':
      case 'RECEIVED':
        return PickupStatus.COMPLETED;
      default:
        return status as PickupStatus;
    }
  }

  private mapApiDeliveryStatusToPrisma(status: string): DeliveryStatus {
    switch (status) {
      case 'WAITING':
        return DeliveryStatus.WAITING_ASSIGNMENT;
      case 'ASSIGNED':
        return DeliveryStatus.ASSIGNED;
      case 'ON_THE_WAY':
        return DeliveryStatus.OUT_FOR_DELIVERY;
      case 'ARRIVED':
        return DeliveryStatus.ARRIVED;
      case 'DELIVERED':
        return DeliveryStatus.COMPLETED;
      case 'FAILED':
        return DeliveryStatus.FAILED;
      default:
        return status as DeliveryStatus;
    }
  }
}
