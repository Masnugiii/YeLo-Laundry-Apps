export interface OrderEmployeeSummary {
  id: string;
  fullName: string;
  employeeCode: string;
}

export interface OrderListItem {
  id: string;
  orderNumber: string;
  invoiceNumber: string;
  queueNumber: string;
  customerId: string;
  customerName: string;
  customerPhone: string;
  orderStatus: string;
  paymentStatus: string;
  serviceSummary: string;
  totalWeight: number;
  itemCount: number;
  subtotal: number;
  discount: number;
  tax: number;
  serviceFee: number;
  grandTotal: number;
  pickupRequired: boolean;
  deliveryRequired: boolean;
  pickupStatus: string | null;
  deliveryStatus: string | null;
  assignedEmployee: OrderEmployeeSummary | null;
  orderDate: string;
  createdBy: OrderEmployeeSummary;
  createdAt: string;
}

export interface OrderItem {
  id: string;
  serviceId: string;
  serviceCode: string;
  serviceName: string;
  serviceCategoryCode: string | null;
  serviceCategoryName: string | null;
  quantity: number;
  weight: number | null;
  unitPrice: number;
  subtotal: number;
  notes: string | null;
}

export interface OrderTimelineItem {
  id: string;
  type: string;
  title: string;
  description: string | null;
  employee: OrderEmployeeSummary | null;
  createdAt: string;
}

export interface OrderStatusHistoryItem {
  id: string;
  fromStatus: string | null;
  toStatus: string;
  notes: string | null;
  changedBy: OrderEmployeeSummary | null;
  changedAt: string;
}

export interface OrderJobInfo {
  id: string;
  status: string;
  scheduledPickupAt?: string | null;
  scheduledDeliveryAt?: string | null;
  completedAt?: string | null;
  driver?: OrderEmployeeSummary | null;
}

export interface OrderDetail extends OrderListItem {
  receivedDate: string | null;
  actualFinishDate: string | null;
  paymentMethod: string | null;
  notes: string | null;
  items: OrderItem[];
  timeline: OrderTimelineItem[];
  statusHistory: OrderStatusHistoryItem[];
  pickupAddress: Record<string, unknown> | null;
  deliveryAddress: Record<string, unknown> | null;
  pickup: OrderJobInfo | null;
  delivery: OrderJobInfo | null;
  paymentsSummary: {
    totalPaid: number;
    remaining: number;
  };
  updatedAt: string;
}

export interface OrderPayment {
  id: string;
  referenceNumber: string | null;
  orderId: string;
  orderNumber: string;
  amount: number;
  refundedAmount: number;
  netAmount: number;
  paymentStatus: string;
  displayStatus: string;
  paidAt: string;
  paymentMethod: {
    id: string;
    code: string;
    name: string;
    apiCode: string | null;
  };
  notes: string | null;
}

export interface OrderListParams {
  page?: number;
  limit?: number;
  search?: string;
  status?: string;
  paymentStatus?: string;
  pickupStatus?: string;
  deliveryStatus?: string;
  dateFrom?: string;
  dateTo?: string;
  employeeId?: string;
}

export interface RefundPaymentInput {
  amount: number;
  reason: string;
}
