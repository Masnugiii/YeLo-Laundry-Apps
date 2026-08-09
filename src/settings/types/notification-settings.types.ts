export const NOTIFICATION_SETTINGS_KEY = 'notification.settings';

/** Outlet-level notification toggles per API spec / business rules. */
export interface NotificationToggleSettings {
  notify_new_order: boolean;
  notify_payment: boolean;
  notify_ironing_finished: boolean;
  notify_pickup_delivery: boolean;
  notify_wallet: boolean;
}

export const DEFAULT_NOTIFICATION_TOGGLE_SETTINGS: NotificationToggleSettings =
  {
    notify_new_order: true,
    notify_payment: true,
    notify_ironing_finished: true,
    notify_pickup_delivery: true,
    notify_wallet: true,
  };

export interface NotificationTemplateConfig {
  id: string;
  code: string;
  title: string;
  body: string;
  isActive: boolean;
}

export interface NotificationConfig {
  settings: NotificationToggleSettings;
  templates: NotificationTemplateConfig[];
}

export interface UpdateNotificationConfigInput {
  settings?: Partial<NotificationToggleSettings>;
  templates?: Array<{
    id: string;
    title?: string;
    body?: string;
    isActive?: boolean;
  }>;
}
