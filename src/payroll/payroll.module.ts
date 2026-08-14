import { Module, forwardRef } from '@nestjs/common';
import { FinanceModule } from '../finance/finance.module';
import { PayrollCalculatorService } from './payroll-calculator.service';
import { PayrollController } from './payroll.controller';
import { PayrollRepository } from './payroll.repository';
import { PayrollService } from './payroll.service';

@Module({
  imports: [forwardRef(() => FinanceModule)],
  controllers: [PayrollController],
  providers: [
    PayrollService,
    PayrollRepository,
    PayrollCalculatorService,
  ],
  exports: [PayrollService],
})
export class PayrollModule {}
