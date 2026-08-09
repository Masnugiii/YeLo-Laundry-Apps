class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.occupation,
    this.address,
    this.walletBalance = 0,
    this.points = 0,
    this.isMember = false,
  });

  final String id;
  final String name;
  final String phone;
  final String? occupation;
  final String? address;
  final int walletBalance;
  final int points;
  final bool isMember;

  bool get hasDeposit => walletBalance > 0;
}

class CustomerFormData {
  const CustomerFormData({
    required this.name,
    required this.phone,
    this.occupation,
    this.address,
  });

  final String name;
  final String phone;
  final String? occupation;
  final String? address;

  Customer toCustomer({required String id}) {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      occupation: occupation,
      address: address,
    );
  }
}
