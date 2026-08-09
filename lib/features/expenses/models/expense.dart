enum ExpenseCategory {
  pengeluaranSampah,
  beliGas,
  beliGalon,
  bayarListrik,
  beliRinso,
  beliPlastik,
  jasaCleaningYelo,
  transportKurir,
  atk,
  perawatanMesin,
  lainnya,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.pengeluaranSampah => 'Pengeluaran Sampah',
        ExpenseCategory.beliGas => 'Beli Gas',
        ExpenseCategory.beliGalon => 'Beli Galon',
        ExpenseCategory.bayarListrik => 'Bayar Listrik',
        ExpenseCategory.beliRinso => 'Beli Rinso',
        ExpenseCategory.beliPlastik => 'Beli Plastik',
        ExpenseCategory.jasaCleaningYelo => 'Jasa Cleaning Yelo',
        ExpenseCategory.transportKurir => 'Transport Kurir',
        ExpenseCategory.atk => 'ATK',
        ExpenseCategory.perawatanMesin => 'Perawatan Mesin',
        ExpenseCategory.lainnya => 'Lainnya',
      };
}

class ExpenseAdmin {
  const ExpenseAdmin({
    required this.id,
    required this.name,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final bool isCurrentUser;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ExpenseAdmin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ExpensePeriodFilter {
  today,
  thisWeek,
  thisMonth,
}

extension ExpensePeriodFilterX on ExpensePeriodFilter {
  String get label => switch (this) {
        ExpensePeriodFilter.today => 'Hari Ini',
        ExpensePeriodFilter.thisWeek => 'Minggu Ini',
        ExpensePeriodFilter.thisMonth => 'Bulan Ini',
      };
}

class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.adminName,
    required this.dateTime,
    this.description,
  });

  final String id;
  final ExpenseCategory category;
  final int amount;
  final String adminName;
  final DateTime dateTime;
  final String? description;

  String get formattedDate {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$day ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }
}
