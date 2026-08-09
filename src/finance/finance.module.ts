import { Module } from '@nestjs/common';
import { CustomerModule } from '../customer/customer.module';
import { NotificationModule } from '../notification/notification.module';
import { OrderModule } from '../order/order.module';
import { CashController } from './cash.controller';
import { CashService } from './cash.service';
import { ExpenseController } from './expense.controller';
import { ExpenseRepository } from './expense.repository';
import { ExpenseService } from './expense.service';
import { FinanceAuditService } from './finance-audit.service';
import { FinanceSettingsRepository } from './finance-settings.repository';
import { InvoiceController } from './invoice.controller';
import { InvoiceService } from './invoice.service';
import { PaymentController } from './payment.controller';
import { PaymentRepository } from './payment.repository';
import { PaymentService } from './payment.service';
import { ReportController } from './report.controller';
import { ReportService } from './report.service';

@Module({
  imports: [CustomerModule, OrderModule, NotificationModule],
  controllers: [
    PaymentController,
    InvoiceController,
    ExpenseController,
    CashController,
    ReportController,
  ],
  providers: [
    PaymentService,
    PaymentRepository,
    InvoiceService,
    ExpenseService,
    ExpenseRepository,
    CashService,
    ReportService,
    FinanceSettingsRepository,
    FinanceAuditService,
  ],
  exports: [
    PaymentService,
    PaymentRepository,
    FinanceSettingsRepository,
    FinanceAuditService,
    ReportService,
  ],
})
export class FinanceModule {}
