class CheckoutPaymentMethods {
  CheckoutPaymentMethods._();

  static const yeloWallet = 'YELO_WALLET';
  static const qris = 'QRIS';
  static const bankTransfer = 'BANK_TRANSFER';

  static const all = [yeloWallet, qris, bankTransfer];

  static String label(String code) => switch (code) {
        yeloWallet => 'Yelo Wallet',
        qris => 'QRIS',
        bankTransfer => 'Transfer Bank',
        _ => code,
      };

  static String subtitle(String code) => switch (code) {
        yeloWallet => 'Bayar menggunakan Yelo Wallet',
        qris => 'Bayar menggunakan QRIS',
        bankTransfer => 'Transfer melalui rekening bank',
        _ => '',
      };
}
