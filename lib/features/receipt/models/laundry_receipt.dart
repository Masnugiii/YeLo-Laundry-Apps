class LaundryReceiptLineItem {
  const LaundryReceiptLineItem({
    required this.serviceName,
    required this.weight,
    required this.price,
  });

  final String serviceName;
  final String weight;
  final int price;
}

class LaundryReceiptBusinessInfo {
  const LaundryReceiptBusinessInfo({
    required this.name,
    required this.address,
    required this.city,
    required this.whatsapp,
    required this.instagram,
    required this.website,
    this.logoAsset = 'assets/images/Logo_WithBackground.png',
  });

  final String name;
  final String address;
  final String city;
  final String whatsapp;
  final String instagram;
  final String website;
  final String logoAsset;
}

class LaundryReceipt {
  const LaundryReceipt({
    required this.business,
    required this.orderNumber,
    required this.queueNumber,
    required this.orderDate,
    required this.orderTime,
    required this.estimatedFinishDate,
    required this.estimatedFinishTime,
    required this.customerName,
    required this.customerPhone,
    required this.lineItems,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.pickup,
    required this.delivery,
    required this.cashierName,
    this.qrDescription = 'Scan untuk melihat status laundry.',
    this.bottomNote =
        'Barang yang tidak diambil lebih dari 30 hari menjadi tanggung jawab pelanggan.\n\n'
        'Harap membawa struk ini saat pengambilan laundry.',
  });

  final LaundryReceiptBusinessInfo business;
  final String orderNumber;
  final String queueNumber;
  final String orderDate;
  final String orderTime;
  final String estimatedFinishDate;
  final String estimatedFinishTime;
  final String customerName;
  final String customerPhone;
  final List<LaundryReceiptLineItem> lineItems;
  final int subtotal;
  final int discount;
  final int grandTotal;
  final String paymentMethod;
  final String paymentStatus;
  final bool pickup;
  final bool delivery;
  final String cashierName;
  final String qrDescription;
  final String bottomNote;

  String get pickupLabel => pickup ? 'Ya' : 'Tidak';
  String get deliveryLabel => delivery ? 'Ya' : 'Tidak';
}

enum ReceiptPreviewMode {
  thermal58,
  thermal80,
  pdf,
  whatsapp,
}
