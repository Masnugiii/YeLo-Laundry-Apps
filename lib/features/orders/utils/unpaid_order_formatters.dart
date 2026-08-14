import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';

String formatUnpaidOrderDate(DateTime dateTime) {
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
  final month = months[dateTime.month - 1];
  return '$day $month ${dateTime.year}';
}

String formatUnpaidOrderDateTime(DateTime dateTime) {
  final date = formatUnpaidOrderDate(dateTime);
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$date\n$hour:$minute WIB';
}

String formatUnpaidAmount(int amount) => formatRupiah(amount);
