class CustomerSummary {
  const CustomerSummary({
    required this.totalCustomers,
    required this.totalMembers,
    required this.totalDeposit,
    required this.totalPoints,
  });

  final int totalCustomers;
  final int totalMembers;
  final int totalDeposit;
  final int totalPoints;
}

const dummyCustomerSummary = CustomerSummary(
  totalCustomers: 125,
  totalMembers: 80,
  totalDeposit: 4250000,
  totalPoints: 12500,
);
