"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useRef, useState } from "react";
import {
  DeliveryStatusBadge,
  LaundryStatusBadge,
  PaymentStatusBadge,
  PickupStatusBadge,
} from "@/components/orders/order-badges";
import {
  OrderDetailSkeleton,
  QueryErrorState,
} from "@/components/orders/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useCancelOrder,
  useOrder,
  useOrderCustomer,
  useOrderPayments,
  useRefundPayment,
} from "@/hooks/use-orders";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency, formatDate } from "@/lib/utils";

function Field({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div>
      <p className="text-sm font-medium text-slate-500">{label}</p>
      <div className="mt-1 text-sm">{value}</div>
    </div>
  );
}

function getAddressText(address: Record<string, unknown> | null) {
  if (!address) return "-";
  const detail = address.addressDetail;
  const city = address.city;
  const province = address.province;
  return [detail, city, province].filter(Boolean).join(", ") || "-";
}

export default function OrderDetailPage() {
  const params = useParams<{ id: string }>();
  const orderId = params.id;
  const toast = useToast();
  const printRef = useRef<HTMLDivElement>(null);

  const orderQuery = useOrder(orderId);
  const customerQuery = useOrderCustomer(orderQuery.data?.customerId ?? "");
  const paymentsQuery = useOrderPayments(orderId);
  const cancelOrder = useCancelOrder(orderId);
  const refundPayment = useRefundPayment(orderId);

  const [showCancelDialog, setShowCancelDialog] = useState(false);
  const [cancelReason, setCancelReason] = useState("");
  const [showRefundDialog, setShowRefundDialog] = useState(false);
  const [refundAmount, setRefundAmount] = useState("");
  const [refundReason, setRefundReason] = useState("");
  const [selectedPaymentId, setSelectedPaymentId] = useState<string | null>(null);

  const order = orderQuery.data;
  const customer = customerQuery.data;
  const payments = paymentsQuery.data?.items ?? [];

  if (orderQuery.isLoading) return <OrderDetailSkeleton />;

  if (orderQuery.isError || !order) {
    return (
      <QueryErrorState
        title="Failed to load order"
        message={getErrorMessage(orderQuery.error, "Unable to fetch order details.")}
        onRetry={() => orderQuery.refetch()}
      />
    );
  }

  function handlePrint(mode: "invoice" | "receipt" | "summary") {
    if (!order) return;
    const currentOrder = order;
    const title =
      mode === "invoice" ? "Invoice" : mode === "receipt" ? "Receipt" : "Order Summary";
    const printWindow = window.open("", "_blank", "noopener,noreferrer,width=900,height=700");
    if (!printWindow) return;

    const paymentRows = payments
      .map(
        (payment) =>
          `<tr><td>${payment.referenceNumber ?? payment.id}</td><td>${payment.paymentMethod.name}</td><td>${payment.paymentStatus}</td><td>${formatCurrency(payment.amount)}</td></tr>`,
      )
      .join("");

    const itemRows = currentOrder.items
      .map(
        (item) =>
          `<tr><td>${item.serviceName}</td><td>${item.quantity}</td><td>${item.weight ?? "-"}</td><td>${formatCurrency(item.unitPrice)}</td><td>${formatCurrency(item.subtotal)}</td></tr>`,
      )
      .join("");

    printWindow.document.write(`
      <html><head><title>${title} - ${currentOrder.orderNumber}</title>
      <style>body{font-family:Arial,sans-serif;padding:24px} table{width:100%;border-collapse:collapse;margin-top:16px} th,td{border:1px solid #ddd;padding:8px;text-align:left} h1,h2{margin:0 0 8px}</style>
      </head><body>
      <h1>${title}</h1>
      <h2>${currentOrder.orderNumber}</h2>
      <p>Invoice: ${currentOrder.invoiceNumber}</p>
      <p>Customer: ${currentOrder.customerName} (${currentOrder.customerPhone})</p>
      <p>Order Date: ${formatDate(currentOrder.orderDate)}</p>
      <p>Status: ${currentOrder.orderStatus} | Payment: ${currentOrder.paymentStatus}</p>
      <table><thead><tr><th>Service</th><th>Qty</th><th>Weight</th><th>Price</th><th>Subtotal</th></tr></thead><tbody>${itemRows}</tbody></table>
      <p><strong>Subtotal:</strong> ${formatCurrency(currentOrder.subtotal)}</p>
      <p><strong>Discount:</strong> ${formatCurrency(currentOrder.discount)}</p>
      <p><strong>Tax:</strong> ${formatCurrency(currentOrder.tax)}</p>
      <p><strong>Grand Total:</strong> ${formatCurrency(currentOrder.grandTotal)}</p>
      ${mode !== "summary" ? `<table><thead><tr><th>Reference</th><th>Method</th><th>Status</th><th>Amount</th></tr></thead><tbody>${paymentRows}</tbody></table>` : ""}
      </body></html>
    `);
    printWindow.document.close();
    printWindow.focus();
    printWindow.print();
  }

  async function handleCancel() {
    if (!cancelReason.trim()) {
      toast.error("Cancellation reason is required.");
      return;
    }
    try {
      await cancelOrder.mutateAsync(cancelReason.trim());
      setShowCancelDialog(false);
      setCancelReason("");
      toast.success("Order cancelled successfully.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to cancel order."));
    }
  }

  async function handleRefund() {
    if (!selectedPaymentId) return;
    try {
      await refundPayment.mutateAsync({
        paymentId: selectedPaymentId,
        input: {
          amount: Number(refundAmount),
          reason: refundReason.trim(),
        },
      });
      setShowRefundDialog(false);
      setRefundAmount("");
      setRefundReason("");
      setSelectedPaymentId(null);
      toast.success("Refund processed successfully.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to process refund."));
    }
  }

  return (
    <div className="space-y-6" ref={printRef}>
      <div className="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
        <div>
          <Link href="/operations/orders" className="text-sm text-blue-600 hover:underline">
            Back to orders
          </Link>
          <h2 className="mt-2 text-2xl font-semibold">{order.orderNumber}</h2>
          <p className="text-sm text-slate-500">{order.invoiceNumber}</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" onClick={() => handlePrint("invoice")}>
            Print Invoice
          </Button>
          <Button variant="outline" onClick={() => handlePrint("receipt")}>
            Print Receipt
          </Button>
          <Button variant="outline" onClick={() => handlePrint("summary")}>
            Print Summary
          </Button>
          {order.orderStatus !== "CANCELLED" ? (
            <Button variant="destructive" onClick={() => setShowCancelDialog(true)}>
              Cancel Order
            </Button>
          ) : null}
          {payments.length > 0 ? (
            <Button
              variant="outline"
              onClick={() => {
                setSelectedPaymentId(payments[0].id);
                setRefundAmount(String(payments[0].amount));
                setShowRefundDialog(true);
              }}
            >
              Refund
            </Button>
          ) : null}
        </div>
      </div>

      <Card>
        <CardTitle>General</CardTitle>
        <div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          <Field label="Order Number" value={order.orderNumber} />
          <Field label="Invoice Number" value={order.invoiceNumber} />
          <Field label="Queue Number" value={order.queueNumber} />
          <Field label="Created Date" value={formatDate(order.createdAt)} />
          <Field label="Created By" value={order.createdBy.fullName} />
        </div>
      </Card>

      <Card>
        <CardTitle>Customer</CardTitle>
        <div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          <Field label="Customer Name" value={order.customerName} />
          <Field label="Phone" value={order.customerPhone} />
          <Field
            label="Address"
            value={getAddressText(order.pickupAddress ?? order.deliveryAddress)}
          />
          <Field
            label="Wallet Balance"
            value={customer ? formatCurrency(customer.walletBalance) : "Loading..."}
          />
          <Field
            label="Reward Points"
            value={customer ? customer.loyaltyPoints : "Loading..."}
          />
        </div>
      </Card>

      <Card>
        <CardTitle>Order Items</CardTitle>
        <div className="mt-4 overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="text-left text-slate-500">
                <th className="px-2 py-2">Service</th>
                <th className="px-2 py-2">Quantity</th>
                <th className="px-2 py-2">Weight</th>
                <th className="px-2 py-2">Price</th>
                <th className="px-2 py-2">Subtotal</th>
              </tr>
            </thead>
            <tbody>
              {order.items.map((item) => (
                <tr key={item.id} className="border-t border-slate-100 dark:border-slate-800">
                  <td className="px-2 py-2">{item.serviceName}</td>
                  <td className="px-2 py-2">{item.quantity}</td>
                  <td className="px-2 py-2">{item.weight ?? "-"}</td>
                  <td className="px-2 py-2">{formatCurrency(item.unitPrice)}</td>
                  <td className="px-2 py-2">{formatCurrency(item.subtotal)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      <Card>
        <CardTitle>Payment</CardTitle>
        <div className="mt-4 space-y-3">
          <div className="grid gap-4 md:grid-cols-3">
            <Field label="Payment Method" value={order.paymentMethod ?? "-"} />
            <Field label="Payment Status" value={<PaymentStatusBadge status={order.paymentStatus} />} />
            <Field label="Total Paid" value={formatCurrency(order.paymentsSummary.totalPaid)} />
            <Field label="Remaining" value={formatCurrency(order.paymentsSummary.remaining)} />
          </div>
          {payments.map((payment) => (
            <div
              key={payment.id}
              className="rounded-lg border border-slate-200 p-4 text-sm dark:border-slate-800"
            >
              <p className="font-medium">{payment.paymentMethod.name}</p>
              <p>Amount: {formatCurrency(payment.amount)}</p>
              <p>Status: {payment.displayStatus}</p>
              <p>Reference: {payment.referenceNumber ?? "-"}</p>
              <p>Paid At: {formatDate(payment.paidAt)}</p>
              <p>Wallet Used: {payment.paymentMethod.code === "CUSTOMER_WALLET" ? "Yes" : "No"}</p>
            </div>
          ))}
          {!payments.length ? (
            <p className="text-sm text-slate-500">No payment records yet.</p>
          ) : null}
        </div>
      </Card>

      <Card>
        <CardTitle>Laundry Timeline</CardTitle>
        <div className="mt-4 space-y-4">
          {order.timeline.map((entry) => (
            <div key={entry.id} className="border-l-2 border-blue-500 pl-4">
              <p className="font-medium">{entry.title}</p>
              <p className="text-sm text-slate-500">{entry.description ?? "-"}</p>
              <p className="text-xs text-slate-500">
                {entry.employee?.fullName ?? "System"} • {formatDate(entry.createdAt)}
              </p>
            </div>
          ))}
          {!order.timeline.length ? (
            <p className="text-sm text-slate-500">No timeline entries yet.</p>
          ) : null}
        </div>
      </Card>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardTitle>Pickup</CardTitle>
          <div className="mt-4 space-y-2 text-sm">
            <Field label="Pickup Address" value={getAddressText(order.pickupAddress)} />
            <Field
              label="Pickup Time"
              value={
                order.pickup?.scheduledPickupAt
                  ? formatDate(order.pickup.scheduledPickupAt)
                  : "-"
              }
            />
            <Field label="Driver" value={order.pickup?.driver?.fullName ?? "-"} />
            <Field
              label="Status"
              value={<PickupStatusBadge status={order.pickup?.status ?? null} />}
            />
          </div>
        </Card>

        <Card>
          <CardTitle>Delivery</CardTitle>
          <div className="mt-4 space-y-2 text-sm">
            <Field label="Delivery Address" value={getAddressText(order.deliveryAddress)} />
            <Field label="Driver" value={order.delivery?.driver?.fullName ?? "-"} />
            <Field
              label="Status"
              value={<DeliveryStatusBadge status={order.delivery?.status ?? null} />}
            />
            <Field
              label="ETA"
              value={
                order.delivery?.scheduledDeliveryAt
                  ? formatDate(order.delivery.scheduledDeliveryAt)
                  : "-"
              }
            />
            <Field
              label="Completed Time"
              value={
                order.delivery?.completedAt ? formatDate(order.delivery.completedAt) : "-"
              }
            />
          </div>
        </Card>
      </div>

      <Card>
        <CardTitle>Order History</CardTitle>
        <div className="mt-4 space-y-3">
          <Field label="Created" value={formatDate(order.createdAt)} />
          <Field label="Updated" value={formatDate(order.updatedAt)} />
          {order.statusHistory.map((entry) => (
            <div
              key={entry.id}
              className="rounded-lg border border-slate-200 p-4 text-sm dark:border-slate-800"
            >
              <p>
                Status changed: {entry.fromStatus ?? "N/A"} → {entry.toStatus}
              </p>
              <p className="text-slate-500">{entry.notes ?? "-"}</p>
              <p className="text-xs text-slate-500">
                {entry.changedBy?.fullName ?? "System"} • {formatDate(entry.changedAt)}
              </p>
            </div>
          ))}
          <Field
            label="Current Laundry Status"
            value={<LaundryStatusBadge status={order.orderStatus} />}
          />
        </div>
      </Card>

      <ConfirmDialog
        open={showCancelDialog}
        title="Cancel order?"
        description="This will cancel the order. Please provide a reason."
        confirmLabel="Cancel order"
        destructive
        loading={cancelOrder.isPending}
        onConfirm={handleCancel}
        onCancel={() => setShowCancelDialog(false)}
      />

      {showCancelDialog ? (
        <Card>
          <label className="block text-sm">
            <span className="font-medium text-slate-500">Cancellation reason</span>
            <Input
              className="mt-2"
              value={cancelReason}
              onChange={(event) => setCancelReason(event.target.value)}
            />
          </label>
        </Card>
      ) : null}

      <ConfirmDialog
        open={showRefundDialog}
        title="Refund payment?"
        description="Process a refund for the selected payment."
        confirmLabel="Refund"
        loading={refundPayment.isPending}
        onConfirm={handleRefund}
        onCancel={() => setShowRefundDialog(false)}
      />

      {showRefundDialog ? (
        <Card>
          <div className="grid gap-4 md:grid-cols-2">
            <label className="block text-sm">
              <span className="font-medium text-slate-500">Refund amount</span>
              <Input
                className="mt-2"
                type="number"
                value={refundAmount}
                onChange={(event) => setRefundAmount(event.target.value)}
              />
            </label>
            <label className="block text-sm">
              <span className="font-medium text-slate-500">Reason</span>
              <Input
                className="mt-2"
                value={refundReason}
                onChange={(event) => setRefundReason(event.target.value)}
              />
            </label>
          </div>
        </Card>
      ) : null}
    </div>
  );
}
