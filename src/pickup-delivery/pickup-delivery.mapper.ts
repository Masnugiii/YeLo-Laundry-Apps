import {
  DeliveryJobRecord,
  PickupJobRecord,
} from './pickup-delivery.select';
import {
  decodeJobNotes,
  encodeJobNotes,
  JobMeta,
  JobRoute,
  JobProof,
  JobType,
  TrackingPoint,
} from './utils/job-meta.util';
import {
  mapDeliveryStatusToApi,
  mapPickupStatusToApi,
} from './utils/status-mapper.util';

export interface AddressResponse {
  id: string;
  recipientName: string;
  phone: string;
  province: string;
  city: string;
  district: string;
  postalCode: string | null;
  addressDetail: string;
  isDefault: boolean;
}

export interface JobOrderSummary {
  id: string;
  orderNumber: string;
  queueNumber: string;
  orderStatus: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
}

export interface JobDetailResponse {
  id: string;
  jobType: JobType;
  orderId: string;
  order: JobOrderSummary;
  status: string;
  driver: {
    id: string;
    fullName: string;
    employeeCode: string;
    phone: string;
  } | null;
  address: AddressResponse;
  scheduledAt: Date | null;
  assignedAt: Date | null;
  completedAt: Date | null;
  notes: string | null;
  proof: JobProof | null;
  route: JobRoute | null;
  tracking: TrackingPoint[];
  assignedByEmployeeId: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface PaginatedJobs {
  items: JobDetailResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface PickupDeliveryDashboard {
  pickupRequested: number;
  driverAssigned: number;
  onTheWay: number;
  readyForDelivery: number;
  deliveredToday: number;
  failedDelivery: number;
  averageDeliveryTimeMinutes: number;
}

export interface DriverTasksDashboard {
  todayPickups: JobDetailResponse[];
  todayDeliveries: JobDetailResponse[];
  completedTasks: number;
  pendingTasks: number;
}

function mapAddress(
  address: PickupJobRecord['pickupAddress'] | DeliveryJobRecord['deliveryAddress'],
): AddressResponse {
  return {
    id: address.id,
    recipientName: address.recipientName,
    phone: address.phone,
    province: address.province,
    city: address.city,
    district: address.district,
    postalCode: address.postalCode,
    addressDetail: address.addressDetail,
    isDefault: address.isDefault,
  };
}

function mapOrderSummary(
  order: PickupJobRecord['order'] | DeliveryJobRecord['order'],
): JobOrderSummary {
  return {
    id: order.id,
    orderNumber: order.invoiceNumber,
    queueNumber: order.queueNumber,
    orderStatus: order.orderStatus,
    customerId: order.customer.id,
    customerName: order.customer.fullName,
    customerPhone: order.customer.phone,
  };
}

export function toPickupJobResponse(job: PickupJobRecord): JobDetailResponse {
  const { meta, notes } = decodeJobNotes(job.notes);

  return {
    id: job.id,
    jobType: 'PICKUP',
    orderId: job.orderId,
    order: mapOrderSummary(job.order),
    status: mapPickupStatusToApi(job.status, meta.displayStatus),
    driver: job.driver,
    address: mapAddress(job.pickupAddress),
    scheduledAt: job.scheduledPickupAt,
    assignedAt: job.assignedAt,
    completedAt: job.completedAt,
    notes,
    proof: meta.proof ?? null,
    route: meta.route ?? null,
    tracking: meta.tracking ?? [],
    assignedByEmployeeId: meta.assignedByEmployeeId ?? null,
    createdAt: job.createdAt,
    updatedAt: job.updatedAt,
  };
}

export function toDeliveryJobResponse(job: DeliveryJobRecord): JobDetailResponse {
  const { meta, notes } = decodeJobNotes(job.notes);
  const proof: JobProof | null =
    meta.proof ??
    (job.proofPhotoUrl
      ? {
          photoUrl: job.proofPhotoUrl,
          notes: notes ?? undefined,
        }
      : null);

  return {
    id: job.id,
    jobType: 'DELIVERY',
    orderId: job.orderId,
    order: mapOrderSummary(job.order),
    status: mapDeliveryStatusToApi(job.status, meta.displayStatus),
    driver: job.driver,
    address: mapAddress(job.deliveryAddress),
    scheduledAt: job.scheduledDeliveryAt,
    assignedAt: job.assignedAt,
    completedAt: job.completedAt,
    notes,
    proof,
    route: meta.route ?? null,
    tracking: meta.tracking ?? [],
    assignedByEmployeeId: meta.assignedByEmployeeId ?? null,
    createdAt: job.createdAt,
    updatedAt: job.updatedAt,
  };
}

export function mergeJobMeta(
  currentNotes: string | null | undefined,
  patch: Partial<JobMeta>,
  notes?: string | null,
): string | null {
  const { meta, notes: existingNotes } = decodeJobNotes(currentNotes);

  return encodeJobNotes({ ...meta, ...patch }, notes ?? existingNotes);
}
