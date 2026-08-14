import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { OwnerWriteGuard } from '../settings/guards/owner-write.guard';
import { CreatePerfumeDto, UpdatePerfumeDto } from './perfume.dto';
import { PerfumeService } from './perfume.service';

@ApiTags('Perfumes')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.SETTINGS)
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('perfumes')
export class PerfumeController {
  constructor(private readonly perfumeService: PerfumeService) {}

  @Get()
  @ApiOperation({ summary: 'List all perfumes' })
  async list() {
    const data = await this.perfumeService.listAll();
    return {
      success: true,
      message: 'Perfumes retrieved successfully',
      data,
    };
  }

  @Post()
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Create perfume (OWNER only)' })
  async create(
    @Body() dto: CreatePerfumeDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.perfumeService.create(dto, user.employeeId);
    return {
      success: true,
      message: 'Perfume created successfully',
      data,
    };
  }

  @Patch(':id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update perfume (OWNER only)' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePerfumeDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.perfumeService.update(id, dto, user.employeeId);
    return {
      success: true,
      message: 'Perfume updated successfully',
      data,
    };
  }

  @Delete(':id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Deactivate perfume (OWNER only)' })
  async delete(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.perfumeService.softDelete(id, user.employeeId);
    return {
      success: true,
      message: 'Perfume deleted successfully',
      data,
    };
  }
}
