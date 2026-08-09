import 'package:yelo_laundry_erp/core/role/role.dart';

UserRole mapBackendRoleToUserRole(List<String> roles) {
  if (roles.contains('OWNER')) {
    return UserRole.owner;
  }
  if (roles.contains('MANAGER') || roles.contains('DRIVER')) {
    return UserRole.cashierLaundryDriver;
  }
  if (roles.contains('OPERATOR')) {
    return UserRole.cashierLaundry;
  }
  if (roles.contains('BINATU')) {
    return UserRole.laundry;
  }
  return UserRole.cashier;
}
