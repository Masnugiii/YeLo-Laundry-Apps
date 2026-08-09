export interface NotificationItem {
  id: string;
  title: string;
  message: string;
  type: string;
  priority: string;
  status: string;
  channels: string[];
  isRead: boolean;
  createdAt: string;
  readAt?: string | null;
}

export interface NotificationListParams {
  page?: number;
  limit?: number;
  isRead?: boolean;
  type?: string;
}

export interface NotificationUnreadCount {
  count: number;
}
