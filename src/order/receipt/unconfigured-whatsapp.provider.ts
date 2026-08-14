import { Injectable, Logger } from '@nestjs/common';
import { WhatsappProvider, WhatsappSendResult } from './order-receipt.types';

@Injectable()
export class UnconfiguredWhatsappProvider implements WhatsappProvider {
  private readonly logger = new Logger(UnconfiguredWhatsappProvider.name);

  isConfigured(): boolean {
    return false;
  }

  async sendMessage(_phone: string, _message: string): Promise<WhatsappSendResult> {
    this.logger.warn('WhatsApp provider is not configured');
    return {
      status: 'NOT_CONFIGURED',
      reason: 'WhatsApp provider is not configured',
    };
  }
}
