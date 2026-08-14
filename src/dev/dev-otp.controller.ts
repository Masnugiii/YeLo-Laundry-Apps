import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { ROLES } from '../auth/constants/roles.constant';
import { Roles } from '../auth/decorators/roles.decorator';
import { DevOtpService } from './dev-otp.service';
import {
  DevGenerateOtpDto,
  DevGenerateOtpResponseDto,
} from './dto/dev-generate-otp.dto';

@ApiTags('Development')
@ApiBearerAuth('access-token')
@Controller('dev/otp')
export class DevOtpController {
  constructor(private readonly devOtpService: DevOtpService) {}

  @Post('generate')
  @HttpCode(HttpStatus.OK)
  @Roles(ROLES.OWNER)
  @ApiOperation({
    summary: 'Generate development OTP (local only)',
    description:
      'Creates or reveals a pending OTP for whitelisted test phones. Disabled in production.',
  })
  @ApiResponse({ status: 404, description: 'Not available in production' })
  @ApiResponse({ status: 403, description: 'Phone not whitelisted' })
  async generate(
    @Body() dto: DevGenerateOtpDto,
  ): Promise<ApiSuccessResponse<DevGenerateOtpResponseDto>> {
    return this.devOtpService.generate(dto);
  }
}
