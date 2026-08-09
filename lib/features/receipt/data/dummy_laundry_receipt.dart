import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';

const dummyLaundryReceipt = LaundryReceipt(
  business: LaundryReceiptBusinessInfo(
    name: 'YELO LAUNDRY',
    address: 'Jl. Ahmad Yani No.123',
    city: 'Probolinggo',
    whatsapp: '0812-3456-7890',
    instagram: '@yelolaundry',
    website: 'www.yelolaundry.com',
  ),
  orderNumber: 'YL-004288',
  queueNumber: 'A-4288',
  orderDate: '08 Agustus 2026',
  orderTime: '09:15 WIB',
  estimatedFinishDate: '10 Agustus 2026',
  estimatedFinishTime: '17:00 WIB',
  customerName: 'Andi Saputra',
  customerPhone: '081234567890',
  lineItems: [
    LaundryReceiptLineItem(
      serviceName: 'Cuci Kering Lipat',
      weight: '4.5 Kg',
      price: 45000,
    ),
    LaundryReceiptLineItem(
      serviceName: 'Express Fee',
      weight: '-',
      price: 15000,
    ),
  ],
  subtotal: 60000,
  discount: 5000,
  grandTotal: 55000,
  paymentMethod: 'Cash',
  paymentStatus: 'Lunas',
  pickup: true,
  delivery: false,
  cashierName: 'Nugroho',
);
