/// Foundation model for future wallet deduction audit history.
class WalletDeductionRecord {
  const WalletDeductionRecord({
    required this.adminName,
    required this.deductionReason,
    required this.amount,
    required this.dateTime,
    required this.customerId,
  });

  final String adminName;
  final String deductionReason;
  final int amount;
  final DateTime dateTime;
  final String customerId;
}
