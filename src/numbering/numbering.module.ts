import { Module } from '@nestjs/common';
import { MasterDataModule } from '../master-data/master-data.module';
import { NumberingController } from './numbering.controller';
import { NumberingService } from './numbering.service';

@Module({
  imports: [MasterDataModule],
  controllers: [NumberingController],
  providers: [NumberingService],
  exports: [NumberingService],
})
export class NumberingModule {}
