export interface CustomerServiceSummary {
  unreadMessages: number;
  newComplaints: number;
  orderQuestions: number;
  completed: number;
}

export type CustomerServiceCategory =
  | "ORDER_BARU"
  | "KOMPLAIN"
  | "PERTANYAAN"
  | "PROMO"
  | "TRACKING_ORDER"
  | "LAINNYA";

export type CustomerServiceStatus =
  | "OPEN"
  | "IN_PROGRESS"
  | "WAITING_CUSTOMER"
  | "RESOLVED"
  | "CLOSED";

export interface CustomerServiceTicket {
  id: string;
  customerId: string;
  customerName: string;
  whatsappNumber: string;
  subject: string;
  messagePreview: string;
  messageTime: string;
  category: CustomerServiceCategory;
  aiConfidence: number;
  isUnread: boolean;
  status: CustomerServiceStatus;
  priority: string;
}

export interface CustomerServiceMessage {
  id: string;
  senderType: "CUSTOMER" | "EMPLOYEE" | "SYSTEM";
  content: string;
  createdAt: string;
  isFromCustomer: boolean;
  employeeName?: string;
}

export interface CustomerServiceRelatedOrder {
  queueNumber: string;
  laundryService: string;
  currentStatus: string;
  estimatedCompletion: string | null;
}

export interface CustomerServiceTicketDetail extends CustomerServiceTicket {
  aiSummary: string;
  messages: CustomerServiceMessage[];
  relatedOrder: CustomerServiceRelatedOrder | null;
  assigneeName?: string;
}

export interface CustomerServiceListParams {
  page?: number;
  limit?: number;
  search?: string;
  category?: CustomerServiceCategory;
  status?: CustomerServiceStatus;
}

export interface UpdateCustomerServiceTicketInput {
  status?: CustomerServiceStatus;
  category?: CustomerServiceCategory;
  subject?: string;
}

export interface CreateCustomerServiceMessageInput {
  message: string;
}
