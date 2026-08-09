import { Module } from '@nestjs/common';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { AppConfigModule } from './config/config.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ValidationExceptionFilter } from './common/filters/validation-exception.filter';
import { TransformResponseInterceptor } from './common/interceptors/transform-response.interceptor';
import { PrismaModule } from './database/prisma/prisma.module';
import { LoggerModule } from './logger/logger.module';
import { AuthModule } from './auth/auth.module';
import { CustomerModule } from './customer/customer.module';
import { EmployeeModule } from './employee/employee.module';
import { OrderModule } from './order/order.module';
import { FinanceModule } from './finance/finance.module';
import { AttendanceModule } from './attendance/attendance.module';
import { LaundryModule } from './laundry/laundry.module';
import { PickupDeliveryModule } from './pickup-delivery/pickup-delivery.module';
import { NotificationModule } from './notification/notification.module';
import { CustomerAppModule } from './customer-app/customer-app.module';
import { AdminModule } from './admin/admin.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { PayrollModule } from './payroll/payroll.module';
import { LoyaltyModule } from './loyalty/loyalty.module';
import { ReportsModule } from './reports/reports.module';
import { PermissionModule } from './permission/permission.module';
import { RbacModule } from './rbac/rbac.module';
import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [
    AppConfigModule,
    LoggerModule,
    PrismaModule,
    HealthModule,
    AuthModule,
    RbacModule,
    EmployeeModule,
    CustomerModule,
    OrderModule,
    FinanceModule,
    AttendanceModule,
    LaundryModule,
    PickupDeliveryModule,
    NotificationModule,
    CustomerAppModule,
    AdminModule,
    DashboardModule,
    PayrollModule,
    LoyaltyModule,
    ReportsModule,
    PermissionModule,
  ],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: TransformResponseInterceptor,
    },
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
    {
      provide: APP_FILTER,
      useClass: HttpExceptionFilter,
    },
    {
      provide: APP_FILTER,
      useClass: ValidationExceptionFilter,
    },
  ],
})
export class AppModule {}
