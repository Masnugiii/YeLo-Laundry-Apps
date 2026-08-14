export interface CustomerPromoItem {
  id: string;
  title: string;
  description: string;
  discountPercent: number | null;
  discountType: 'PERCENTAGE' | 'FIXED';
  discountValue: number;
  voucherCode: string;
  minTransaction: number;
  maxDiscount: number | null;
  expiresAt: string;
  startsAt: string;
  isUsable: boolean;
  unusableReason: string | null;
}

export interface CustomerPromoQuote {
  promoId: string;
  voucherCode: string;
  subtotal: number;
  discountPercent: number | null;
  discountAmount: number;
  total: number;
  maxDiscount: number | null;
}
