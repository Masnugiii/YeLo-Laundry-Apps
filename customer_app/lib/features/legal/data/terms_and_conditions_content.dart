/// Centralized terms and conditions content for easy updates.
class TermsSection {
  const TermsSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

abstract final class TermsAndConditionsContent {
  /// Update this value when the official document is revised.
  static const lastUpdated = '09 Agustus 2026';

  /// Replace section content with official legal text when available.
  static const placeholderContent =
      '[Konten Syarat & Ketentuan akan ditambahkan]';

  static const sections = <TermsSection>[
    TermsSection(title: '1. Ketentuan Umum', content: placeholderContent),
    TermsSection(title: '2. Definisi', content: placeholderContent),
    TermsSection(
      title: '3. Ketentuan Penggunaan Layanan',
      content: placeholderContent,
    ),
    TermsSection(title: '4. Pemesanan Laundry', content: placeholderContent),
    TermsSection(
      title: '5. Layanan Antar Jemput',
      content: placeholderContent,
    ),
    TermsSection(title: '6. Pembayaran', content: placeholderContent),
    TermsSection(title: '7. Yelo Wallet', content: placeholderContent),
    TermsSection(
      title: '8. Yelo Point dan Rewards',
      content: placeholderContent,
    ),
    TermsSection(title: '9. Promo', content: placeholderContent),
    TermsSection(
      title: '10. Tanggung Jawab Pengguna',
      content: placeholderContent,
    ),
    TermsSection(
      title: '11. Ketentuan Barang Laundry',
      content: placeholderContent,
    ),
    TermsSection(
      title: '12. Pembatalan dan Pengembalian Dana',
      content: placeholderContent,
    ),
    TermsSection(title: '13. Perubahan Layanan', content: placeholderContent),
    TermsSection(
      title: '14. Perubahan Syarat & Ketentuan',
      content: placeholderContent,
    ),
    TermsSection(title: '15. Hubungi Kami', content: placeholderContent),
  ];
}
