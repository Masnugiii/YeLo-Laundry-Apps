enum ReceiptPaperSize {
  mm58,
  mm80,
}

enum ReceiptLanguage {
  indonesia,
  english,
}

class ReceiptBusinessFields {
  const ReceiptBusinessFields({
    this.showLogo = true,
    this.showName = true,
    this.showAddress = true,
    this.showWhatsapp = true,
    this.showInstagram = true,
    this.showWebsite = true,
  });

  final bool showLogo;
  final bool showName;
  final bool showAddress;
  final bool showWhatsapp;
  final bool showInstagram;
  final bool showWebsite;

  ReceiptBusinessFields copyWith({
    bool? showLogo,
    bool? showName,
    bool? showAddress,
    bool? showWhatsapp,
    bool? showInstagram,
    bool? showWebsite,
  }) {
    return ReceiptBusinessFields(
      showLogo: showLogo ?? this.showLogo,
      showName: showName ?? this.showName,
      showAddress: showAddress ?? this.showAddress,
      showWhatsapp: showWhatsapp ?? this.showWhatsapp,
      showInstagram: showInstagram ?? this.showInstagram,
      showWebsite: showWebsite ?? this.showWebsite,
    );
  }
}

class ReceiptOrderFields {
  const ReceiptOrderFields({
    this.showOrderNumber = true,
    this.showQueueNumber = true,
    this.showOrderDate = true,
    this.showEstimatedFinish = true,
  });

  final bool showOrderNumber;
  final bool showQueueNumber;
  final bool showOrderDate;
  final bool showEstimatedFinish;

  ReceiptOrderFields copyWith({
    bool? showOrderNumber,
    bool? showQueueNumber,
    bool? showOrderDate,
    bool? showEstimatedFinish,
  }) {
    return ReceiptOrderFields(
      showOrderNumber: showOrderNumber ?? this.showOrderNumber,
      showQueueNumber: showQueueNumber ?? this.showQueueNumber,
      showOrderDate: showOrderDate ?? this.showOrderDate,
      showEstimatedFinish: showEstimatedFinish ?? this.showEstimatedFinish,
    );
  }
}

class ReceiptCustomerFields {
  const ReceiptCustomerFields({
    this.showCustomerName = true,
    this.showPhone = true,
  });

  final bool showCustomerName;
  final bool showPhone;

  ReceiptCustomerFields copyWith({
    bool? showCustomerName,
    bool? showPhone,
  }) {
    return ReceiptCustomerFields(
      showCustomerName: showCustomerName ?? this.showCustomerName,
      showPhone: showPhone ?? this.showPhone,
    );
  }
}

class ReceiptServiceFields {
  const ReceiptServiceFields({
    this.showServiceName = true,
    this.showWeight = true,
    this.showPrice = true,
    this.showSubtotal = true,
    this.showDiscount = true,
    this.showGrandTotal = true,
  });

  final bool showServiceName;
  final bool showWeight;
  final bool showPrice;
  final bool showSubtotal;
  final bool showDiscount;
  final bool showGrandTotal;

  ReceiptServiceFields copyWith({
    bool? showServiceName,
    bool? showWeight,
    bool? showPrice,
    bool? showSubtotal,
    bool? showDiscount,
    bool? showGrandTotal,
  }) {
    return ReceiptServiceFields(
      showServiceName: showServiceName ?? this.showServiceName,
      showWeight: showWeight ?? this.showWeight,
      showPrice: showPrice ?? this.showPrice,
      showSubtotal: showSubtotal ?? this.showSubtotal,
      showDiscount: showDiscount ?? this.showDiscount,
      showGrandTotal: showGrandTotal ?? this.showGrandTotal,
    );
  }

  bool get hasServiceTable =>
      showServiceName || showWeight || showPrice;
}

class ReceiptPaymentFields {
  const ReceiptPaymentFields({
    this.showPaymentMethod = true,
    this.showPaymentStatus = true,
  });

  final bool showPaymentMethod;
  final bool showPaymentStatus;

  ReceiptPaymentFields copyWith({
    bool? showPaymentMethod,
    bool? showPaymentStatus,
  }) {
    return ReceiptPaymentFields(
      showPaymentMethod: showPaymentMethod ?? this.showPaymentMethod,
      showPaymentStatus: showPaymentStatus ?? this.showPaymentStatus,
    );
  }
}

class ReceiptPickupDeliveryFields {
  const ReceiptPickupDeliveryFields({
    this.showPickup = true,
    this.showDelivery = true,
    this.showPickupSchedule = true,
    this.showDeliverySchedule = true,
  });

  final bool showPickup;
  final bool showDelivery;
  final bool showPickupSchedule;
  final bool showDeliverySchedule;

  ReceiptPickupDeliveryFields copyWith({
    bool? showPickup,
    bool? showDelivery,
    bool? showPickupSchedule,
    bool? showDeliverySchedule,
  }) {
    return ReceiptPickupDeliveryFields(
      showPickup: showPickup ?? this.showPickup,
      showDelivery: showDelivery ?? this.showDelivery,
      showPickupSchedule: showPickupSchedule ?? this.showPickupSchedule,
      showDeliverySchedule: showDeliverySchedule ?? this.showDeliverySchedule,
    );
  }
}

class ReceiptEmployeeFields {
  const ReceiptEmployeeFields({
    this.showCashierName = true,
    this.showPicBinatu = true,
  });

  final bool showCashierName;
  final bool showPicBinatu;

  ReceiptEmployeeFields copyWith({
    bool? showCashierName,
    bool? showPicBinatu,
  }) {
    return ReceiptEmployeeFields(
      showCashierName: showCashierName ?? this.showCashierName,
      showPicBinatu: showPicBinatu ?? this.showPicBinatu,
    );
  }
}

class ReceiptCustomizationSettings {
  const ReceiptCustomizationSettings({
    this.business = const ReceiptBusinessFields(),
    this.order = const ReceiptOrderFields(),
    this.customer = const ReceiptCustomerFields(),
    this.service = const ReceiptServiceFields(),
    this.payment = const ReceiptPaymentFields(),
    this.pickupDelivery = const ReceiptPickupDeliveryFields(),
    this.employee = const ReceiptEmployeeFields(),
    this.showQrCode = true,
    this.receiptNote =
        'Terima kasih telah mempercayakan cucian Anda kepada Yelo Laundry.\n\n'
        'Barang yang tidak diambil lebih dari 30 hari menjadi tanggung jawab pelanggan.',
    this.paperSize = ReceiptPaperSize.mm58,
    this.language = ReceiptLanguage.indonesia,
  });

  final ReceiptBusinessFields business;
  final ReceiptOrderFields order;
  final ReceiptCustomerFields customer;
  final ReceiptServiceFields service;
  final ReceiptPaymentFields payment;
  final ReceiptPickupDeliveryFields pickupDelivery;
  final ReceiptEmployeeFields employee;
  final bool showQrCode;
  final String receiptNote;
  final ReceiptPaperSize paperSize;
  final ReceiptLanguage language;

  ReceiptCustomizationSettings copyWith({
    ReceiptBusinessFields? business,
    ReceiptOrderFields? order,
    ReceiptCustomerFields? customer,
    ReceiptServiceFields? service,
    ReceiptPaymentFields? payment,
    ReceiptPickupDeliveryFields? pickupDelivery,
    ReceiptEmployeeFields? employee,
    bool? showQrCode,
    String? receiptNote,
    ReceiptPaperSize? paperSize,
    ReceiptLanguage? language,
  }) {
    return ReceiptCustomizationSettings(
      business: business ?? this.business,
      order: order ?? this.order,
      customer: customer ?? this.customer,
      service: service ?? this.service,
      payment: payment ?? this.payment,
      pickupDelivery: pickupDelivery ?? this.pickupDelivery,
      employee: employee ?? this.employee,
      showQrCode: showQrCode ?? this.showQrCode,
      receiptNote: receiptNote ?? this.receiptNote,
      paperSize: paperSize ?? this.paperSize,
      language: language ?? this.language,
    );
  }
}
