import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../database/prisma/prisma.service';
import { AdminSettingsService } from '../../admin/admin-settings.service';

export interface ReceiptConfig {
  showLogo: boolean;
  showQRCode: boolean;
  footerText: string | null;
  companyName: string;
  companyPhone: string | null;
  companyAddress: string | null;
  companyLogoUrl: string | null;
}

export interface UpdateReceiptConfigDto {
  showLogo?: boolean;
  showQRCode?: boolean;
  footerText?: string | null;
}

@Injectable()
export class ReceiptConfigService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly adminSettingsService: AdminSettingsService,
  ) {}

  async getConfig(): Promise<ReceiptConfig> {
    const [receipt, company] = await Promise.all([
      this.ensureReceiptRow(),
      this.adminSettingsService.getCompanySettings(),
    ]);

    return {
      showLogo: receipt.showLogo,
      showQRCode: receipt.showQRCode,
      footerText: receipt.footerText,
      companyName: company.companyName,
      companyPhone: company.phone,
      companyAddress: company.address,
      companyLogoUrl: company.logoUrl,
    };
  }

  async updateConfig(dto: UpdateReceiptConfigDto): Promise<ReceiptConfig> {
    const row = await this.ensureReceiptRow();

    await this.prisma.receiptSetting.update({
      where: { id: row.id },
      data: {
        ...(dto.showLogo !== undefined && { showLogo: dto.showLogo }),
        ...(dto.showQRCode !== undefined && { showQRCode: dto.showQRCode }),
        ...(dto.footerText !== undefined && { footerText: dto.footerText }),
      },
    });

    return this.getConfig();
  }

  private async ensureReceiptRow() {
    const existing = await this.prisma.receiptSetting.findFirst({
      orderBy: { createdAt: 'asc' },
    });

    if (existing) {
      return existing;
    }

    return this.prisma.receiptSetting.create({
      data: {
        showLogo: true,
        showQRCode: false,
        footerText:
          'Terima kasih telah mempercayakan cucian Anda kepada Yelo Laundry.',
      },
    });
  }
}
