import { Module } from '@nestjs/common';
import { AdminModule } from '../admin/admin.module';
import { MasterDataAuditService } from './audit/master-data-audit.service';
import { CatalogController } from './catalog.controller';
import { CatalogService } from './catalog.service';
import { ExpenseCategoryController } from './expense-category.controller';
import { ExpenseCategoryService } from './expense-category.service';
import { PaymentMethodController } from './payment-method.controller';
import { PaymentMethodService } from './payment-method.service';

@Module({
  imports: [AdminModule],
  controllers: [
    CatalogController,
    PaymentMethodController,
    ExpenseCategoryController,
  ],
  providers: [
    MasterDataAuditService,
    CatalogService,
    PaymentMethodService,
    ExpenseCategoryService,
  ],
  exports: [MasterDataAuditService, CatalogService],
})
export class MasterDataModule {}
