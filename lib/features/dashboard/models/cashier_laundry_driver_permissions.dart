/// Dummy permission map for Kasir + Binatu + Driver (HP Pribadi) UI preview.
abstract final class CashierLaundryDriverPermissions {
  // Allowed
  static const dashboard = true;
  static const customer = true;
  static const order = true;
  static const yeloWallet = true;
  static const pickupDelivery = true;
  static const driver = true;
  static const notificationCenter = true;
  static const printReceipt = true;
  static const shareReceiptWhatsapp = true;
  static const orderNumberSettingsReadOnly = true;
  static const receiptPrinterSettings = true;
  static const customerServiceCenter = true;
  static const attendance = true;
  static const ironingQueueAssistance = true;
  static const operationalContribution = true;

  // Restricted
  static const revenueReport = false;
  static const financialDashboard = false;
  static const expenses = false;
  static const employeeKpi = false;
  static const employeeManagement = false;
  static const laundryProfile = false;
  static const systemSettings = false;
  static const aiPlanner = false;
  static const ownerData = false;
}
