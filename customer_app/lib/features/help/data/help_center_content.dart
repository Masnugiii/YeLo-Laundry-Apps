import 'package:flutter/material.dart';

/// Editable help center content. Replace placeholders when official copy is ready.
class HelpCategoryItem {
  const HelpCategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? route;
}

class HelpFaqItem {
  const HelpFaqItem({
    required this.question,
    required this.answer,
    this.categoryId,
    this.keywords = const [],
  });

  final String question;
  final String answer;
  final String? categoryId;
  final List<String> keywords;
}

abstract final class HelpCenterContent {
  static const contactPlaceholder =
      '[Informasi kontak Customer Service akan ditambahkan]';

  static const categories = <HelpCategoryItem>[
    HelpCategoryItem(
      id: 'orders',
      label: 'Pesanan Laundry',
      icon: Icons.local_laundry_service_outlined,
      route: '/pickup',
    ),
    HelpCategoryItem(
      id: 'payment',
      label: 'Pembayaran',
      icon: Icons.payment_outlined,
      route: '/help/payment',
    ),
    HelpCategoryItem(
      id: 'wallet',
      label: 'Wallet & Top Up',
      icon: Icons.account_balance_wallet_outlined,
      route: '/wallet',
    ),
    HelpCategoryItem(
      id: 'pickup',
      label: 'Antar Jemput',
      icon: Icons.local_shipping_outlined,
      route: '/pickup',
    ),
    HelpCategoryItem(
      id: 'promo',
      label: 'Promo & Point',
      icon: Icons.local_offer_outlined,
      route: '/promo',
    ),
  ];

  static const paymentFaqs = <HelpFaqItem>[
    HelpFaqItem(
      question: 'Bagaimana cara melakukan pembayaran laundry?',
      answer:
          'Setelah pesanan laundry dibuat, lanjutkan ke halaman pembayaran dari '
          'detail pesanan atau notifikasi pembayaran. Pilih metode pembayaran yang '
          'tersedia, ikuti instruksi di aplikasi, lalu tunggu konfirmasi status '
          'pembayaran.',
      categoryId: 'payment',
      keywords: ['bayar', 'laundry', 'pesanan'],
    ),
    HelpFaqItem(
      question: 'Apa saja metode pembayaran yang tersedia?',
      answer:
          'Metode pembayaran yang ditampilkan di aplikasi dapat berbeda sesuai '
          'konfigurasi layanan. Umumnya mencakup Yelo Wallet, QRIS, dan Transfer '
          'Bank. Daftar metode yang aktif selalu ditampilkan saat checkout atau '
          'halaman pembayaran pesanan.',
      categoryId: 'payment',
      keywords: ['metode', 'payment method'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara membayar menggunakan Yelo Wallet?',
      answer:
          'Pastikan saldo Yelo Wallet mencukupi. Pada halaman pembayaran, pilih '
          'Yelo Wallet sebagai metode pembayaran, lalu konfirmasi transaksi. '
          'Saldo akan terpotong setelah pembayaran berhasil.',
      categoryId: 'payment',
      keywords: ['wallet', 'yelo wallet'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara membayar menggunakan QRIS?',
      answer:
          'Pilih QRIS pada halaman pembayaran, lalu scan kode QR yang ditampilkan '
          'menggunakan aplikasi e-wallet atau mobile banking yang mendukung QRIS. '
          'Selesaikan pembayaran sesuai instruksi di aplikasi pembayaran kamu.',
      categoryId: 'payment',
      keywords: ['qris', 'scan'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara melakukan Transfer Bank?',
      answer:
          'Pilih Transfer Bank pada halaman pembayaran, lalu transfer sesuai nominal '
          'dan rekening tujuan yang ditampilkan. Pastikan nominal transfer sesuai '
          'dan simpan bukti pembayaran jika diperlukan.',
      categoryId: 'payment',
      keywords: ['transfer', 'bank'],
    ),
    HelpFaqItem(
      question: 'Apa yang harus dilakukan jika pembayaran gagal?',
      answer:
          'Periksa kembali koneksi internet, saldo atau limit pembayaran, lalu coba '
          'ulang dari halaman pembayaran pesanan. Jika masih gagal, gunakan metode '
          'pembayaran lain atau hubungi Customer Service Yelo.',
      categoryId: 'payment',
      keywords: ['gagal', 'failed'],
    ),
    HelpFaqItem(
      question:
          'Apa yang harus dilakukan jika saldo sudah terpotong tetapi pembayaran belum berhasil?',
      answer:
          'Simpan bukti transaksi dan nomor pesanan kamu, lalu hubungi Customer '
          'Service Yelo untuk verifikasi. Tim kami akan membantu memastikan status '
          'pembayaran dan pesanan kamu diproses dengan benar.',
      categoryId: 'payment',
      keywords: ['saldo', 'terpotong', 'pending'],
    ),
  ];

  static const faqs = <HelpFaqItem>[
    HelpFaqItem(
      question: 'Bagaimana cara memesan laundry?',
      answer:
          'Buka menu Pesan Laundry, pilih layanan yang tersedia, lengkapi alamat '
          'dan detail pesanan, lalu lanjutkan ke pembayaran sesuai metode yang '
          'tersedia di aplikasi.',
      categoryId: 'orders',
      keywords: ['pesan', 'laundry', 'order'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara menggunakan layanan antar jemput?',
      answer:
          'Saat membuat pesanan, pilih alamat pickup melalui fitur yang tersedia '
          'di aplikasi. Pastikan alamat dan detail kontak sudah benar sebelum '
          'pesanan dikirim.',
      categoryId: 'pickup',
      keywords: ['antar', 'jemput', 'pickup', 'alamat'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara melakukan pembayaran?',
      answer:
          'Pembayaran dapat dilakukan melalui metode yang tersedia saat checkout '
          'atau pada halaman pembayaran pesanan. Status pembayaran dapat dipantau '
          'melalui aplikasi.',
      categoryId: 'payment',
      keywords: ['pembayaran', 'bayar', 'payment'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara Top Up Wallet?',
      answer:
          'Buka halaman Wallet, pilih Top Up, lalu ikuti langkah yang ditampilkan '
          'di aplikasi untuk menambah saldo Yelo Wallet.',
      categoryId: 'wallet',
      keywords: ['top up', 'wallet', 'saldo'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara menggunakan Point?',
      answer:
          'Yelo Point dapat dikumpulkan melalui aktivitas dan program yang tersedia. '
          'Detail penggunaan point ditampilkan pada halaman YeLo Rewards.',
      categoryId: 'promo',
      keywords: ['point', 'reward', 'klaim'],
    ),
    HelpFaqItem(
      question: 'Bagaimana cara menggunakan promo?',
      answer:
          'Buka halaman Promo untuk melihat promo yang tersedia. Syarat dan ketentuan '
          'setiap promo ditampilkan pada detail promo di aplikasi.',
      categoryId: 'promo',
      keywords: ['promo', 'voucher', 'diskon'],
    ),
  ];
}
