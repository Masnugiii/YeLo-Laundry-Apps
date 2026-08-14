import { Module } from '@nestjs/common';
import { SettingsConfigModule } from '../settings/settings-config.module';
import {
  LogEmailNotificationProvider,
  LogPushNotificationProvider,
  LogSmsNotificationProvider,
  NotificationDispatcherService,
} from './notification-dispatcher.service';
import { NotificationAuditService } from './notification-audit.service';
import { NotificationController } from './notification.controller';
import { NotificationEventService } from './notification-event.service';
import { NotificationRepository } from './notification.repository';
import { NotificationService } from './notification.service';
import { NotificationTemplateService } from './notification-template.service';

@Module({
  imports: [SettingsConfigModule],
  controllers: [NotificationController],
  providers: [
    NotificationService,
    NotificationRepository,
    NotificationEventService,
    NotificationDispatcherService,
    NotificationTemplateService,
    NotificationAuditService,
    LogPushNotificationProvider,
    LogEmailNotificationProvider,
    LogSmsNotificationProvider,
  ],
  exports: [
    NotificationService,
    NotificationRepository,
    NotificationEventService,
    NotificationDispatcherService,
    NotificationTemplateService,
  ],
})
export class NotificationModule {}
