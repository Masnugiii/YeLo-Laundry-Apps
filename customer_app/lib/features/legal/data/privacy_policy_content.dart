/// Centralized privacy policy content for easy updates.
class PrivacyPolicySection {
  const PrivacyPolicySection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

abstract final class PrivacyPolicyContent {
  /// Update this value when the official policy document is revised.
  static const lastUpdated = '09 Agustus 2026';

  static const sections = <PrivacyPolicySection>[
    PrivacyPolicySection(
      title: '1. Pendahuluan',
      content:
          'Kebijakan Privasi ini menjelaskan bagaimana Yelo Laundry mengelola '
          'informasi melalui aplikasi pelanggan. Dengan menggunakan aplikasi ini, '
          'Anda dianggap telah membaca dan memahami kebijakan ini.\n\n'
          'Teks resmi kebijakan privasi akan dipublikasikan oleh Yelo Laundry '
          'melalui saluran resmi perusahaan.',
    ),
    PrivacyPolicySection(
      title: '2. Informasi yang Kami Kumpulkan',
      content:
          'Aplikasi dapat memproses informasi yang diperlukan untuk menyediakan '
          'layanan, seperti data akun, informasi pesanan, alamat, dan data '
          'transaksi yang relevan dengan penggunaan layanan Yelo Laundry.\n\n'
          'Rincian jenis data yang dikumpulkan akan dijelaskan dalam versi '
          'resmi kebijakan privasi Yelo Laundry.',
    ),
    PrivacyPolicySection(
      title: '3. Penggunaan Informasi',
      content:
          'Informasi dapat digunakan untuk menyediakan layanan laundry, '
          'memproses pesanan, mengelola akun, memberikan dukungan pelanggan, '
          'serta meningkatkan pengalaman penggunaan aplikasi.\n\n'
          'Detail penggunaan informasi akan diperbarui sesuai kebijakan resmi '
          'Yelo Laundry.',
    ),
    PrivacyPolicySection(
      title: '4. Penyimpanan dan Keamanan Data',
      content:
          'Yelo Laundry berupaya melindungi informasi pengguna dengan langkah '
          'keamanan yang wajar sesuai praktik industri.\n\n'
          'Ketentuan mengenai lokasi penyimpanan, periode retensi, dan '
          'langkah perlindungan data akan dijelaskan dalam dokumen resmi '
          'kebijakan privasi.',
    ),
    PrivacyPolicySection(
      title: '5. Berbagi Informasi',
      content:
          'Informasi dapat dibagikan kepada pihak yang diperlukan untuk '
          'menyediakan layanan, seperti mitra operasional atau penyedia '
          'teknologi, sesuai kebutuhan layanan dan ketentuan yang berlaku.\n\n'
          'Rincian pihak penerima informasi akan dijelaskan dalam versi '
          'resmi kebijakan privasi.',
    ),
    PrivacyPolicySection(
      title: '6. Hak Pengguna',
      content:
          'Pengguna dapat memiliki hak tertentu terkait data pribadi, '
          'seperti akses, koreksi, atau penghapusan data sesuai ketentuan '
          'yang berlaku.\n\n'
          'Prosedur pengajuan permintaan hak pengguna akan diinformasikan '
          'melalui saluran resmi Yelo Laundry.',
    ),
    PrivacyPolicySection(
      title: '7. Cookies dan Teknologi Serupa',
      content:
          'Aplikasi atau layanan terkait dapat menggunakan teknologi serupa '
          'untuk mendukung fungsionalitas, analitik, atau preferensi '
          'pengguna.\n\n'
          'Penjelasan lebih lanjut akan tersedia dalam dokumen resmi '
          'kebijakan privasi.',
    ),
    PrivacyPolicySection(
      title: '8. Notifikasi',
      content:
          'Aplikasi dapat mengirimkan notifikasi terkait status pesanan, '
          'pembayaran, promo, atau informasi layanan lainnya sesuai '
          'pengaturan yang Anda pilih.\n\n'
          'Anda dapat mengelola preferensi notifikasi melalui pengaturan '
          'aplikasi jika fitur tersebut tersedia.',
    ),
    PrivacyPolicySection(
      title: '9. Layanan Pihak Ketiga',
      content:
          'Aplikasi dapat terhubung dengan layanan pihak ketiga untuk '
          'menyediakan fitur tertentu, seperti pembayaran, peta, atau '
          'notifikasi.\n\n'
          'Daftar layanan pihak ketiga yang digunakan akan dijelaskan dalam '
          'versi resmi kebijakan privasi Yelo Laundry.',
    ),
    PrivacyPolicySection(
      title: '10. Perubahan Kebijakan Privasi',
      content:
          'Yelo Laundry dapat memperbarui Kebijakan Privasi ini dari waktu '
          'ke waktu. Perubahan material akan diinformasikan melalui aplikasi '
          'atau saluran resmi lainnya.\n\n'
          'Tanggal pembaruan terakhir ditampilkan di bagian atas halaman ini.',
    ),
    PrivacyPolicySection(
      title: '11. Hubungi Kami',
      content:
          'Jika Anda memiliki pertanyaan terkait Kebijakan Privasi ini, '
          'silakan hubungi Yelo Laundry melalui saluran dukungan resmi yang '
          'tersedia di aplikasi.\n\n'
          'Informasi kontak resmi akan diperbarui pada dokumen kebijakan '
          'privasi final.',
    ),
  ];
}
