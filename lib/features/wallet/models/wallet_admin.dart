class WalletAdmin {
  const WalletAdmin({
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
        other is WalletAdmin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
