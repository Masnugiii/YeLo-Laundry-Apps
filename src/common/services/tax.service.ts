import { Injectable } from '@nestjs/common';
import { AdminSettingsService } from '../../admin/admin-settings.service';

@Injectable()
export class TaxService {
  constructor(private readonly adminSettingsService: AdminSettingsService) {}

  async getTaxRate(): Promise<number> {
    const company = await this.adminSettingsService.getCompanySettings();
    return company.taxRate ?? 0;
  }

  calculateTax(subtotal: number, discount = 0, taxRate?: number): number {
    const rate = taxRate ?? 0;
    const taxableBase = Math.max(0, subtotal - discount);
    return Number(((taxableBase * rate) / 100).toFixed(2));
  }

  async calculateTaxFromSettings(
    subtotal: number,
    discount = 0,
  ): Promise<number> {
    const rate = await this.getTaxRate();
    return this.calculateTax(subtotal, discount, rate);
  }
}
