import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  Req,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Request } from 'express';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AllowCustomerActor } from '../customer/decorators/allow-customer-actor.decorator';
import { NotificationQueryDto, SendNotificationDto } from './dto/notification.dto';
import {
  NotificationDashboard,
  NotificationResponse,
  PaginatedNotifications,
} from './notification.mapper';
import { NotificationService } from './notification.service';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const NOTIFICATION_EXAMPLE = {
  id: 'ff0e8400-e29b-41d4-a716-446655440060',
  title: 'Order Created',
  message: 'Order YL-20260808-000001 has been created for Andi Wijaya.',
  type: 'ORDER',
  priority: 'NORMAL',
  status: 'SENT',
  channels: ['IN_APP'],
  isRead: false,
  createdAt: '2026-08-08T08:00:00.000Z',
};

@ApiTags('Notifications')
@ApiBearerAuth('access-token')
@Controller('notifications')
export class NotificationController {
  constructor(private readonly service: NotificationService) {}

  @Get()
  @AllowCustomerActor()
  @Roles(...VIEW_ROLES)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @ApiOperation({ summary: 'List notifications with filters' })
  @ApiResponse({
    status: 200,
    description: 'Notifications retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Notifications retrieved successfully',
        data: {
          items: [NOTIFICATION_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findAll(
    @Query() query: NotificationQueryDto,
    @Req() request: Request,
  ): Promise<ApiSuccessResponse<PaginatedNotifications>> {
    return this.service.findAll(
      query,
      NotificationService.actorFromUser(request.user),
    );
  }

  @Get('dashboard')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @ApiOperation({ summary: 'Get notification dashboard summary' })
  @ApiResponse({
    status: 200,
    description: 'Dashboard retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Notification dashboard retrieved successfully',
        data: {
          unreadCount: 5,
          todayNotifications: 12,
          failedNotifications: 1,
          pendingQueue: 2,
          sentToday: 10,
          readToday: 7,
        },
      },
    },
  })
  getDashboard(
    @Req() request: Request,
  ): Promise<ApiSuccessResponse<NotificationDashboard>> {
    return this.service.getDashboard(
      NotificationService.actorFromUser(request.user),
    );
  }

  @Get('unread-count')
  @AllowCustomerActor()
  @Roles(...VIEW_ROLES)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @ApiOperation({ summary: 'Get unread notification count' })
  @ApiResponse({
    status: 200,
    description: 'Unread count retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Unread count retrieved successfully',
        data: { count: 5 },
      },
    },
  })
  getUnreadCount(
    @Req() request: Request,
  ): Promise<ApiSuccessResponse<{ count: number }>> {
    return this.service.getUnreadCount(
      NotificationService.actorFromUser(request.user),
    );
  }

  @Get(':id')
  @AllowCustomerActor()
  @Roles(...VIEW_ROLES)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @ApiOperation({ summary: 'Get notification detail' })
  @ApiParam({ name: 'id', description: 'Notification UUID' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ): Promise<ApiSuccessResponse<NotificationResponse>> {
    return this.service.findOne(
      id,
      NotificationService.actorFromUser(request.user),
    );
  }

  @Post('send')
  @Roles(ROLES.OWNER)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send manual notification' })
  @ApiBody({
    type: SendNotificationDto,
    examples: {
      employee: {
        summary: 'Notify employee',
        value: {
          title: 'Shift Reminder',
          message: 'Please check your assigned pickup tasks.',
          type: 'SYSTEM',
          priority: 'HIGH',
          channels: ['IN_APP'],
          recipientEmployeeId: '660e8400-e29b-41d4-a716-446655440003',
        },
      },
      customer: {
        summary: 'Notify customer',
        value: {
          title: 'Order Ready',
          message: 'Your order YL-20260808-000001 is ready for pickup.',
          type: 'ORDER',
          priority: 'NORMAL',
          channels: ['IN_APP', 'PUSH'],
          recipientCustomerId: '990e8400-e29b-41d4-a716-446655440005',
          orderNumber: 'YL-20260808-000001',
          customerName: 'Andi Wijaya',
        },
      },
    },
  })
  send(
    @Body() dto: SendNotificationDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<NotificationResponse>> {
    return this.service.sendManual(dto, {
      employeeId: user.employeeId,
      roles: user.roles,
    });
  }

  @Post('read-all')
  @AllowCustomerActor()
  @Roles(...VIEW_ROLES)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all notifications as read' })
  markAllRead(
    @Req() request: Request,
  ): Promise<ApiSuccessResponse<{ updated: number }>> {
    return this.service.markAllRead(
      NotificationService.actorFromUser(request.user),
    );
  }

  @Post(':id/read')
  @AllowCustomerActor()
  @Roles(...VIEW_ROLES)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark notification as read' })
  @ApiParam({ name: 'id', description: 'Notification UUID' })
  markRead(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ): Promise<ApiSuccessResponse<NotificationResponse>> {
    return this.service.markRead(
      id,
      NotificationService.actorFromUser(request.user),
    );
  }

  @Delete(':id')
  @Roles(ROLES.OWNER)
  @Permissions(PERMISSIONS.NOTIFICATION)
  @ApiOperation({ summary: 'Soft delete notification' })
  @ApiParam({ name: 'id', description: 'Notification UUID' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<{ id: string }>> {
    return this.service.remove(id, {
      employeeId: user.employeeId,
      roles: user.roles,
    });
  }
}
