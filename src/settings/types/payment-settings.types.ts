export const CUSTOMER_PAYMENT_CONFIG_KEY = 'customer_payment_config';

export interface QrisPaymentSettings {
  isActive: boolean;
  qrImageUrl: string | null;
  qrPayload: string | null;
  instructions: string;
}

export interface BankTransferPaymentSettings {
  isActive: boolean;
  bankName: string;
  accountNumber: string;
  accountHolder: string;
  instructions: string;
}

export interface CustomerPaymentConfig {
  qris: QrisPaymentSettings;
  bankTransfer: BankTransferPaymentSettings;
}

export interface CustomerPaymentMethodAvailability {
  code: string;
  name: string;
  isActive: boolean;
}

export interface CustomerPaymentConfigResponse {
  methods: CustomerPaymentMethodAvailability[];
  qris: QrisPaymentSettings;
  bankTransfer: BankTransferPaymentSettings;
}

export const DEFAULT_CUSTOMER_PAYMENT_CONFIG: CustomerPaymentConfig = {
  qris: {
    isActive: false,
    qrImageUrl: null,
    qrPayload: null,
    instructions:
      'Scan QRIS menggunakan aplikasi e-wallet atau mobile banking Anda.',
  },
  bankTransfer: {
    isActive: false,
    bankName: '',
    accountNumber: '',
    accountHolder: '',
    instructions:
      'Transfer sesuai total pesanan, lalu konfirmasi pembayaran di aplikasi.',
  },
};
