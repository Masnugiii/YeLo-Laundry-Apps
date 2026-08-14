import { Module } from '@nestjs/common';
import { PlatformModule } from '../platform/platform.module';
import { MasterDataAuditService } from './audit/master-data-audit.service';
import { CatalogController } from './catalog.controller';
import { CatalogService } from './catalog.service';
import { ExpenseCategoryController } from './expense-category.controller';
import { ExpenseCategoryService } from './expense-category.service';
import { PaymentMethodController } from './payment-method.controller';
import { PaymentMethodService } from './payment-method.service';
import { PerfumeController } from './perfume.controller';
import { PerfumeService } from './perfume.service';

@Module({
  imports: [PlatformModule],
  controllers: [
    CatalogController,
    PaymentMethodController,
    ExpenseCategoryController,
    PerfumeController,
  ],
  providers: [
    MasterDataAuditService,
    CatalogService,
    PaymentMethodService,
    ExpenseCategoryService,
    PerfumeService,
  ],
  exports: [MasterDataAuditService, CatalogService, PerfumeService],
})
export class MasterDataModule {}
