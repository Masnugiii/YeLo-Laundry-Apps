import { OrderPaymentStatus } from '@prisma/client';
import { buildOrderReceiptMessage } from '../../src/order/receipt/order-receipt-message.builder';

describe('buildOrderReceiptMessage', () => {
  const baseInput = {
    businessName: 'Yelo Laundry',
    orderNumber: 'YL-20260810-000051',
    customerName: 'Budi',
    customerPhone: '081234567890',
    serviceLines: ['Cuci + Setrika · 5 Kg'],
    subtotal: 50000,
    tax: 0,
    serviceFee: 0,
    grandTotal: 50000,
  };

  it('builds unpaid receipt with BELUM DIBAYAR and BAYAR NANTI', () => {
    const message = buildOrderReceiptMessage({
      ...baseInput,
      paymentStatus: OrderPaymentStatus.UNPAID,
      paymentMethod: null,
      paidAt: null,
    });

    expect(message).toContain('YL-20260810-000051');
    expect(message).toContain('BELUM DIBAYAR');
    expect(message).toContain('BAYAR NANTI');
    expect(message).not.toContain('LUNAS');
    expect(message).not.toContain('Paid At:');
  });

  it('builds paid receipt with LUNAS and paid timestamp', () => {
    const paidAt = new Date('2026-08-10T14:30:00.000Z');
    const message = buildOrderReceiptMessage({
      ...baseInput,
      paymentStatus: OrderPaymentStatus.PAID,
      paymentMethod: 'CASH',
      paidAt,
    });

    expect(message).toContain('LUNAS');
    expect(message).toContain('CASH');
    expect(message).toContain('Paid At:');
    expect(message).not.toContain('BELUM DIBAYAR');
  });
});
