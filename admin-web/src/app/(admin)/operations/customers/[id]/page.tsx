"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { FormEvent, useState } from "react";
import {
  CustomerMemberBadge,
  CustomerStatusBadge,
} from "@/components/customers/customer-badges";
import {
  CustomerDetailSkeleton,
  QueryErrorState,
} from "@/components/customers/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useCustomer,
  useCustomerNotes,
  useCustomerOrders,
  useCustomerPayments,
  useCustomerSummary,
  useSetCustomerStatus,
  useUpdateCustomer,
} from "@/hooks/use-customers";
import { useCustomerLoyalty } from "@/hooks/use-loyalty";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { UpdateCustomerInput } from "@/types/customer";

function Field({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div>
      <p className="text-sm font-medium text-slate-500">{label}</p>
      <div className="mt-1 text-sm">{value}</div>
    </div>
  );
}

function buildFormFromCustomer(customer: NonNullable<ReturnType<typeof useCustomer>["data"]>) {
  return {
    fullName: customer.fullName,
    phone: customer.phone,
    email: customer.email ?? "",
    gender: customer.gender ?? "",
    birthDate: customer.birthDate?.slice(0, 10) ?? "",
    isActive: customer.isActive,
  };
}

export default function CustomerDetailPage() {
  const params = useParams<{ id: string }>();
  const customerId = params.id;
  const toast = useToast();

  const customerQuery = useCustomer(customerId);
  const loyaltyQuery = useCustomerLoyalty(customerId);
  const summaryQuery = useCustomerSummary(customerId);
  const ordersQuery = useCustomerOrders(customerId);
  const paymentsQuery = useCustomerPayments(customerId);
  const notesQuery = useCustomerNotes(customerId);

  const updateCustomer = useUpdateCustomer(customerId);
  const setCustomerStatus = useSetCustomerStatus(customerId);

  const [isEditing, setIsEditing] = useState(false);
  const [showDeactivateDialog, setShowDeactivateDialog] = useState(false);
  const [form, setForm] = useState<UpdateCustomerInput>({});

  const customer = customerQuery.data;

  function startEditing() {
    if (!customer) return;
    setForm(buildFormFromCustomer(customer));
    setIsEditing(true);
  }

  function cancelEditing() {
    setIsEditing(false);
    setForm({});
  }

  if (customerQuery.isLoading) return <CustomerDetailSkeleton />;

  if (customerQuery.isError || !customer) {
    return (
      <QueryErrorState
        title="Failed to load customer"
        message={getErrorMessage(customerQuery.error, "Unable to fetch customer.")}
        onRetry={() => customerQuery.refetch()}
      />
    );
  }

  const address =
    customer.defaultAddress?.addressDetail ??
    customer.addresses[0]?.addressDetail ??
    "-";
  const pickupDeliveryOrders =
    ordersQuery.data?.items.filter(
      (order) => order.pickupRequired || order.deliveryRequired,
    ) ?? [];

  async function handleSave(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    try {
      await updateCustomer.mutateAsync({
        fullName: form.fullName,
        phone: form.phone,
        email: form.email || undefined,
        gender: form.gender || undefined,
        birthDate: form.birthDate || undefined,
        isActive: form.isActive,
      });
      setIsEditing(false);
      setForm({});
      toast.success("Customer updated successfully.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to update customer."));
    }
  }

  async function handleDeactivate() {
    try {
      await setCustomerStatus.mutateAsync(false);
      setShowDeactivateDialog(false);
      toast.success("Customer deactivated successfully.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to deactivate customer."));
    }
  }

  async function handleActivate() {
    try {
      await setCustomerStatus.mutateAsync(true);
      toast.success("Customer activated successfully.");
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to activate customer."));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <div>
          <Link href="/operations/customers" className="text-sm text-blue-600 hover:underline">
            Back to customers
          </Link>
          <h2 className="mt-2 text-2xl font-semibold">{customer.fullName}</h2>
          <p className="text-sm text-slate-500">{customer.customerCode}</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" onClick={() => (isEditing ? cancelEditing() : startEditing())}>
            {isEditing ? "Cancel edit" : "Edit customer"}
          </Button>
          {customer.isActive ? (
            <Button variant="destructive" onClick={() => setShowDeactivateDialog(true)}>
              Deactivate
            </Button>
          ) : (
            <Button onClick={handleActivate}>Activate</Button>
          )}
        </div>
      </div>

      {isEditing ? (
        <Card>
          <CardTitle>Edit Customer</CardTitle>
          <form className="mt-4 grid gap-4 md:grid-cols-2" onSubmit={handleSave}>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Full Name</span>
              <Input
                value={form.fullName ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, fullName: event.target.value }))
                }
                required
              />
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Phone</span>
              <Input
                value={form.phone ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, phone: event.target.value }))
                }
                required
              />
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Email</span>
              <Input
                type="email"
                value={form.email ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, email: event.target.value }))
                }
              />
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Gender</span>
              <select
                className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
                value={form.gender ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, gender: event.target.value }))
                }
              >
                <option value="">Not specified</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
              </select>
            </label>
            <label className="space-y-2 text-sm">
              <span className="font-medium text-slate-500">Birth Date</span>
              <Input
                type="date"
                value={form.birthDate ?? ""}
                onChange={(event) =>
                  setForm((current) => ({ ...current, birthDate: event.target.value }))
                }
              />
            </label>
            <div className="md:col-span-2">
              <Button type="submit" disabled={updateCustomer.isPending}>
                {updateCustomer.isPending ? "Saving..." : "Save changes"}
              </Button>
            </div>
          </form>
        </Card>
      ) : (
        <Card>
          <CardTitle>General</CardTitle>
          <div className="mt-4 grid gap-4 md:grid-cols-2">
            <Field label="Customer Code" value={customer.customerCode} />
            <Field label="Full Name" value={customer.fullName} />
            <Field label="Phone" value={customer.phone} />
            <Field label="Email" value={customer.email ?? "-"} />
            <Field label="Gender" value={customer.gender ?? "-"} />
            <Field
              label="Birth Date"
              value={customer.birthDate ? formatDate(customer.birthDate) : "-"}
            />
            <Field label="Address" value={address} />
            <Field
              label="Member Status"
              value={<CustomerMemberBadge memberStatus={customer.memberStatus} />}
            />
            <Field
              label="Status"
              value={<CustomerStatusBadge isActive={customer.isActive} />}
            />
            <Field label="Created" value={formatDate(customer.createdAt)} />
            <Field label="Updated" value={formatDate(customer.updatedAt)} />
          </div>
        </Card>
      )}

      <Card>
        <CardTitle>Loyalty & Wallet</CardTitle>
        {loyaltyQuery.isLoading ? (
          <p className="mt-4 text-sm text-slate-500">Loading loyalty data...</p>
        ) : loyaltyQuery.data ? (
          <div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            <Field
              label="Wallet Balance"
              value={formatCurrency(loyaltyQuery.data.walletBalance)}
            />
            <Field
              label="Reward Points"
              value={loyaltyQuery.data.rewardPoint.currentPoint}
            />
            <Field
              label="Membership"
              value={loyaltyQuery.data.membership.currentLevel.name}
            />
            <Field label="Voucher Count" value={loyaltyQuery.data.voucherCount} />
            <Field
              label="Last Top Up"
              value={
                loyaltyQuery.data.lastTopup
                  ? `${formatCurrency(loyaltyQuery.data.lastTopup.amount)} · ${formatDate(loyaltyQuery.data.lastTopup.date)}`
                  : "-"
              }
            />
            <Field
              label="Lifetime Spending"
              value={formatCurrency(loyaltyQuery.data.lifetimeSpending)}
            />
            <Field
              label="Next Level"
              value={
                loyaltyQuery.data.membership.nextLevel
                  ? `${loyaltyQuery.data.membership.nextLevel.name} (${loyaltyQuery.data.membership.pointsToNext} pts)`
                  : "Max level"
              }
            />
            <Field
              label="Progress"
              value={`${loyaltyQuery.data.membership.progressPercent}%`}
            />
          </div>
        ) : (
          <p className="mt-4 text-sm text-slate-500">No loyalty data available.</p>
        )}
      </Card>

      <Card>
        <CardTitle>Business Summary</CardTitle>
        {summaryQuery.isLoading ? (
          <p className="mt-4 text-sm text-slate-500">Loading summary...</p>
        ) : summaryQuery.data ? (
          <div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            <Field label="Total Orders" value={summaryQuery.data.totalOrders} />
            <Field label="Completed Orders" value={summaryQuery.data.completedOrders} />
            <Field label="Cancelled Orders" value={summaryQuery.data.cancelledOrders} />
            <Field
              label="Total Spending"
              value={formatCurrency(summaryQuery.data.totalSpending)}
            />
            <Field
              label="Average Order Value"
              value={formatCurrency(summaryQuery.data.averageOrderValue)}
            />
            <Field
              label="Member Since"
              value={formatDate(summaryQuery.data.memberSince)}
            />
            <Field
              label="Last Order"
              value={
                summaryQuery.data.lastOrderAt
                  ? formatDate(summaryQuery.data.lastOrderAt)
                  : "-"
              }
            />
          </div>
        ) : (
          <p className="mt-4 text-sm text-slate-500">Summary unavailable.</p>
        )}
      </Card>

      <Card>
        <CardTitle>Laundry History</CardTitle>
        <div className="mt-4 overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="text-left text-slate-500">
                <th className="px-2 py-2">Order</th>
                <th className="px-2 py-2">Status</th>
                <th className="px-2 py-2">Payment</th>
                <th className="px-2 py-2">Total</th>
                <th className="px-2 py-2">Date</th>
              </tr>
            </thead>
            <tbody>
              {(ordersQuery.data?.items ?? []).map((order) => (
                <tr key={order.id} className="border-t border-slate-100 dark:border-slate-800">
                  <td className="px-2 py-2">{order.orderNumber}</td>
                  <td className="px-2 py-2">{order.orderStatus}</td>
                  <td className="px-2 py-2">{order.paymentStatus}</td>
                  <td className="px-2 py-2">{formatCurrency(order.grandTotal)}</td>
                  <td className="px-2 py-2">{formatDate(order.orderDate)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {!ordersQuery.data?.items.length ? (
            <p className="py-6 text-center text-sm text-slate-500">No laundry orders yet.</p>
          ) : null}
        </div>
      </Card>

      <Card>
        <CardTitle>Payment History</CardTitle>
        <div className="mt-4 overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="text-left text-slate-500">
                <th className="px-2 py-2">Reference</th>
                <th className="px-2 py-2">Status</th>
                <th className="px-2 py-2">Amount</th>
                <th className="px-2 py-2">Paid At</th>
              </tr>
            </thead>
            <tbody>
              {(paymentsQuery.data?.items ?? []).map((payment) => (
                <tr key={payment.id} className="border-t border-slate-100 dark:border-slate-800">
                  <td className="px-2 py-2">{payment.referenceNumber ?? payment.id}</td>
                  <td className="px-2 py-2">{payment.paymentStatus}</td>
                  <td className="px-2 py-2">{formatCurrency(payment.amount)}</td>
                  <td className="px-2 py-2">{formatDate(payment.paidAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {!paymentsQuery.data?.items.length ? (
            <p className="py-6 text-center text-sm text-slate-500">No payments yet.</p>
          ) : null}
        </div>
      </Card>

      <Card>
        <CardTitle>Pickup & Delivery</CardTitle>
        <div className="mt-4 space-y-3">
          {pickupDeliveryOrders.map((order) => (
            <div
              key={order.id}
              className="rounded-lg border border-slate-200 p-4 text-sm dark:border-slate-800"
            >
              <p className="font-medium">{order.orderNumber}</p>
              <p className="text-slate-500">
                Pickup: {order.pickupRequired ? "Yes" : "No"} | Delivery:{" "}
                {order.deliveryRequired ? "Yes" : "No"}
              </p>
              <p className="text-slate-500">{formatDate(order.orderDate)}</p>
            </div>
          ))}
          {!pickupDeliveryOrders.length ? (
            <p className="text-sm text-slate-500">No pickup or delivery history.</p>
          ) : null}
        </div>
      </Card>

      <Card>
        <CardTitle>Notes</CardTitle>
        <div className="mt-4 space-y-3">
          {(notesQuery.data?.items ?? []).map((note) => (
            <div
              key={note.id}
              className="rounded-lg border border-slate-200 p-4 text-sm dark:border-slate-800"
            >
              <p className="font-medium">{note.title ?? "Note"}</p>
              <p className="mt-1">{note.note}</p>
              <p className="mt-2 text-xs text-slate-500">
                {note.createdBy.fullName} • {formatDate(note.createdAt)}
              </p>
            </div>
          ))}
          {!notesQuery.data?.items.length ? (
            <p className="text-sm text-slate-500">No owner notes yet.</p>
          ) : null}
        </div>
      </Card>

      <ConfirmDialog
        open={showDeactivateDialog}
        title="Deactivate customer?"
        description={`Are you sure you want to deactivate ${customer.fullName}?`}
        confirmLabel="Deactivate"
        destructive
        loading={setCustomerStatus.isPending}
        onConfirm={handleDeactivate}
        onCancel={() => setShowDeactivateDialog(false)}
      />
    </div>
  );
}
