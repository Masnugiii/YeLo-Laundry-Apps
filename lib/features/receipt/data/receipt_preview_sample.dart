import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';

/// Static preview content for receipt customization screen only.
abstract final class ReceiptPreviewSample {
  static const receipt = LaundryReceipt(
    business: LaundryReceiptBusinessInfo(
      name: 'Preview',
      address: 'Preview Address',
      city: 'Preview City',
      whatsapp: '-',
      instagram: '-',
      website: '-',
    ),
    orderNumber: 'ORD-PREVIEW',
    queueNumber: 'A-0001',
    orderDate: '10 Agustus 2026',
    orderTime: '10:00 WIB',
    estimatedFinishDate: '12 Agustus 2026',
    estimatedFinishTime: '18:00 WIB',
    customerName: 'Preview Customer',
    customerPhone: '08xxxxxxxxxx',
    lineItems: [
      LaundryReceiptLineItem(
        serviceName: 'Cuci Kering',
        weight: '3 kg',
        price: 45000,
      ),
    ],
    subtotal: 45000,
    discount: 0,
    grandTotal: 45000,
    paymentMethod: 'Cash',
    paymentStatus: 'Lunas',
    pickup: true,
    delivery: false,
    cashierName: 'Kasir',
  );
}
