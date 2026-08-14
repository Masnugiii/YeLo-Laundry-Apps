import { Controller, Get, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../../common/decorators/public.decorator';

@ApiTags('Health')
@Controller()
export class RootController {
  @Public()
  @Get()
  @ApiOperation({ summary: 'Platform root / Railway health probe' })
  getRoot() {
    return {
      success: true,
      message: 'YeLo Laundry ERP is running',
    };
  }

  @Public()
  @Get('favicon.ico')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Ignore favicon probes from browsers and proxies' })
  getFavicon() {
    return;
  }
}
