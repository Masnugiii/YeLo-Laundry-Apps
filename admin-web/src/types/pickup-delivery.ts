export interface PickupDeliveryDashboard {
  pickupRequested: number;
  driverAssigned: number;
  onTheWay: number;
  readyForDelivery: number;
  deliveredToday: number;
  failedDelivery: number;
  averageDeliveryTimeMinutes: number;
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

export interface JobDetail {
  id: string;
  jobType: "PICKUP" | "DELIVERY";
  orderId: string;
  order: JobOrderSummary;
  status: string;
  driver: {
    id: string;
    fullName: string;
    employeeCode: string;
    phone: string;
  } | null;
  scheduledAt: string | null;
  assignedAt: string | null;
  completedAt: string | null;
  notes: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface JobListParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: string;
  driverId?: string;
  dateFrom?: string;
  dateTo?: string;
}
