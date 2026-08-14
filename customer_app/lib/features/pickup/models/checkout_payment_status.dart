enum CheckoutPaymentPhase {
  pending,
  success,
  failed,
}

class CheckoutPaymentStatus {
  const CheckoutPaymentStatus(this.rawStatus);

  final String rawStatus;

  factory CheckoutPaymentStatus.fromRaw(String? status) {
    return CheckoutPaymentStatus(status?.trim().isNotEmpty == true ? status! : 'UNPAID');
  }

  CheckoutPaymentPhase get phase {
    switch (rawStatus.toUpperCase()) {
      case 'PAID':
        return CheckoutPaymentPhase.success;
      case 'CANCELLED':
      case 'REFUNDED':
      case 'FAILED':
        return CheckoutPaymentPhase.failed;
      case 'UNPAID':
      default:
        return CheckoutPaymentPhase.pending;
    }
  }

  String get displayLabel => switch (phase) {
        CheckoutPaymentPhase.pending => 'Menunggu Pembayaran',
        CheckoutPaymentPhase.success => 'Pembayaran Berhasil',
        CheckoutPaymentPhase.failed => 'Pembayaran Gagal',
      };

  String get detailMessage => switch (phase) {
        CheckoutPaymentPhase.pending =>
          'Pembayaran Anda sedang diproses. Tekan tombol di bawah untuk memeriksa status terbaru.',
        CheckoutPaymentPhase.success =>
          'Pembayaran telah dikonfirmasi. Anda dapat melanjutkan ke ringkasan pesanan.',
        CheckoutPaymentPhase.failed =>
          'Pembayaran tidak berhasil. Silakan ulangi pembayaran atau pilih metode lain.',
      };
}

bool isOrderPaymentPending(String? paymentStatus) {
  return CheckoutPaymentStatus.fromRaw(paymentStatus).phase ==
      CheckoutPaymentPhase.pending;
}
