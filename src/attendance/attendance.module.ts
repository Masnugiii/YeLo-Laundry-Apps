import { Module } from '@nestjs/common';
import { AttendanceAuditService } from './attendance-audit.service';
import { AttendanceSettingsRepository } from './attendance-settings.repository';
import { AttendanceController } from './attendance.controller';
import { AttendanceRepository } from './attendance.repository';
import { AttendanceService } from './attendance.service';
import { HolidayController } from './holiday.controller';
import { HolidayService } from './holiday.service';
import { LeaveController } from './leave.controller';
import { LeaveService } from './leave.service';
import { ReportService } from './report.service';
import { ShiftController } from './shift.controller';
import { ShiftService } from './shift.service';

@Module({
  controllers: [
    AttendanceController,
    ShiftController,
    LeaveController,
    HolidayController,
  ],
  providers: [
    AttendanceService,
    AttendanceRepository,
    ShiftService,
    LeaveService,
    HolidayService,
    ReportService,
    AttendanceSettingsRepository,
    AttendanceAuditService,
  ],
  exports: [AttendanceService, AttendanceRepository, AttendanceSettingsRepository],
})
export class AttendanceModule {}
