import * as XLSX from "xlsx";
import type { OrderListItem } from "@/types/order";

export function exportOrdersExcel(orders: OrderListItem[]) {
  const rows = orders.map((order) => ({
    "Order Number": order.orderNumber,
    "Invoice Number": order.invoiceNumber,
    Customer: order.customerName,
    Phone: order.customerPhone,
    "Order Date": order.orderDate,
    Service: order.serviceSummary,
    Weight: order.totalWeight,
    Items: order.itemCount,
    Subtotal: order.subtotal,
    Discount: order.discount,
    Tax: order.tax,
    "Grand Total": order.grandTotal,
    "Payment Status": order.paymentStatus,
    "Laundry Status": order.orderStatus,
    "Pickup Status": order.pickupStatus ?? "",
    "Delivery Status": order.deliveryStatus ?? "",
    "Created By": order.createdBy.fullName,
  }));

  const worksheet = XLSX.utils.json_to_sheet(rows);
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Orders");
  XLSX.writeFile(workbook, "orders.xlsx");
}
