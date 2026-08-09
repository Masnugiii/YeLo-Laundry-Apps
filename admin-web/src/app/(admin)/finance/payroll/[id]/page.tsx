"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { useState } from "react";
import {
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { PayslipView } from "@/components/payroll/payslip-view";
import { PayrollStatusBadge } from "@/components/payroll/status-badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useApprovePayroll,
  usePayPayroll,
  usePayrollRecord,
} from "@/hooks/use-payroll";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { PayrollPaymentMethod } from "@/types/payroll";

const PAYMENT_METHODS: PayrollPaymentMethod[] = ["CASH", "TRANSFER", "WALLET"];

export default function PayrollDetailPage() {
  const params = useParams<{ id: string }>();
  const id = params.id;
  const toast = useToast();
  const payrollQuery = usePayrollRecord(id);
  const approveMutation = useApprovePayroll();
  const payMutation = usePayPayroll();

  const [approveOpen, setApproveOpen] = useState(false);
  const [payOpen, setPayOpen] = useState(false);
  const [method, setMethod] = useState<PayrollPaymentMethod>("CASH");
  const [amount, setAmount] = useState(0);
  const [referenceNumber, setReferenceNumber] = useState("");
  const [notes, setNotes] = useState("");

  const canApprove = isOwnerRole();
  const payroll = payrollQuery.data;

  async function handleApprove() {
    try {
      await approveMutation.mutateAsync({ payrollIds: [id] });
      toast.success("Payroll approved successfully.");
      setApproveOpen(false);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to approve payroll."));
    }
  }

  async function handlePay() {
    try {
      await payMutation.mutateAsync({
        payrollId: id,
        method,
        amount,
        referenceNumber: referenceNumber || undefined,
        notes: notes || undefined,
      });
      toast.success("Payroll payment recorded successfully.");
      setPayOpen(false);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to record payment."));
    }
  }

  if (payrollQuery.isLoading) return <FinanceListSkeleton />;
  if (payrollQuery.isError || !payroll) {
    return (
      <QueryErrorState
        title="Failed to load payroll detail"
        message={getErrorMessage(payrollQuery.error, "Payroll record not found.")}
        onRetry={() => payrollQuery.refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <Link href="/finance/payroll" className="text-sm text-blue-600 hover:underline">
            ← Back to Payroll
          </Link>
          <h2 className="mt-2 text-xl font-semibold">{payroll.payrollNumber}</h2>
          <p className="text-sm text-slate-500">
            {payroll.employeeName} · {formatDate(payroll.periodStart)} –{" "}
            {formatDate(payroll.periodEnd)}
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <PayrollStatusBadge status={payroll.status} />
          {canApprove && payroll.status === "CALCULATED" ? (
            <Button onClick={() => setApproveOpen(true)}>Approve</Button>
          ) : null}
          {payroll.status === "APPROVED" ? (
            <Button
              onClick={() => {
                setAmount(payroll.netSalary);
                setPayOpen(true);
              }}
            >
              Record Payment
            </Button>
          ) : null}
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card className="space-y-2 p-6">
          <h3 className="font-semibold">Employee</h3>
          <p>{payroll.employeeName}</p>
          <p className="text-sm text-slate-500">
            {payroll.employeeCode} · {payroll.role}
          </p>
          <p className="text-sm text-slate-500">{payroll.position}</p>
        </Card>
        <Card className="space-y-2 p-6">
          <h3 className="font-semibold">Payroll Period</h3>
          <p>
            {formatDate(payroll.periodStart)} – {formatDate(payroll.periodEnd)}
          </p>
          {payroll.calculatedAt ? (
            <p className="text-sm text-slate-500">
              Calculated: {formatDate(payroll.calculatedAt)}
            </p>
          ) : null}
          {payroll.approvedAt ? (
            <p className="text-sm text-slate-500">
              Approved: {formatDate(payroll.approvedAt)}
            </p>
          ) : null}
          {payroll.paidAt ? (
            <p className="text-sm text-slate-500">Paid: {formatDate(payroll.paidAt)}</p>
          ) : null}
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Attendance</h3>
          <div className="grid grid-cols-2 gap-2 text-sm">
            <p>Present: {payroll.attendance.present}</p>
            <p>Absent: {payroll.attendance.absent}</p>
            <p>Late: {payroll.attendance.late}</p>
            <p>Leave: {payroll.attendance.leave}</p>
          </div>
        </Card>
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Production Summary</h3>
          <div className="grid grid-cols-2 gap-2 text-sm">
            <p>Kilo Laundry: {payroll.production.laundryKg}</p>
            <p>Piece Laundry: {payroll.production.laundryPiece}</p>
            <p>Ironing Kg: {payroll.production.ironingKg}</p>
            <p>Ironing Piece: {payroll.production.ironingPiece}</p>
            <p>Orders Finished: {payroll.production.ordersFinished}</p>
          </div>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Bonus</h3>
          {payroll.bonuses.length ? (
            <div className="space-y-2 text-sm">
              {payroll.bonuses.map((bonus) => (
                <div key={bonus.id} className="flex justify-between border-b pb-2">
                  <div>
                    <p className="font-medium">{bonus.type}</p>
                    <p className="text-slate-500">{bonus.notes ?? "-"}</p>
                  </div>
                  <p>{formatCurrency(bonus.amount)}</p>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-slate-500">No bonus recorded.</p>
          )}
        </Card>
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Deduction</h3>
          {payroll.deductions.length ? (
            <div className="space-y-2 text-sm">
              {payroll.deductions.map((deduction) => (
                <div key={deduction.id} className="flex justify-between border-b pb-2">
                  <div>
                    <p className="font-medium">{deduction.type}</p>
                    <p className="text-slate-500">{deduction.notes ?? "-"}</p>
                  </div>
                  <p>{formatCurrency(deduction.amount)}</p>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-slate-500">No deduction recorded.</p>
          )}
        </Card>
      </div>

      <Card className="space-y-3 p-6">
        <h3 className="font-semibold">Salary Detail</h3>
        <div className="grid gap-2 text-sm md:grid-cols-2">
          <p>Base Salary: {formatCurrency(payroll.baseSalary)}</p>
          <p>Production Salary: {formatCurrency(payroll.productionSalary)}</p>
          <p>Total Bonus: {formatCurrency(payroll.bonus)}</p>
          <p>Total Deduction: {formatCurrency(payroll.deduction)}</p>
          <p>Gross Salary: {formatCurrency(payroll.grossSalary)}</p>
          <p className="font-semibold">Net Salary: {formatCurrency(payroll.netSalary)}</p>
        </div>
      </Card>

      <div className="grid gap-4 md:grid-cols-2">
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Approval History</h3>
          {payroll.approvalHistory.length ? (
            <div className="space-y-2 text-sm">
              {payroll.approvalHistory.map((event) => (
                <div key={event.id} className="border-b pb-2">
                  <p className="font-medium">{event.status}</p>
                  <p className="text-slate-500">
                    {event.actor.fullName} · {formatDate(event.createdAt)}
                  </p>
                  {event.notes ? <p>{event.notes}</p> : null}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-slate-500">No approval history.</p>
          )}
        </Card>
        <Card className="space-y-3 p-6">
          <h3 className="font-semibold">Payment History</h3>
          {payroll.paymentHistory.length ? (
            <div className="space-y-2 text-sm">
              {payroll.paymentHistory.map((payment) => (
                <div key={payment.id} className="border-b pb-2">
                  <p className="font-medium">
                    {payment.method} · {formatCurrency(payment.amount)}
                  </p>
                  <p className="text-slate-500">
                    {payment.paidBy.fullName} · {formatDate(payment.paidAt)}
                  </p>
                  {payment.referenceNumber ? <p>Ref: {payment.referenceNumber}</p> : null}
                  {payment.notes ? <p>{payment.notes}</p> : null}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-slate-500">No payment recorded.</p>
          )}
        </Card>
      </div>

      <PayslipView payroll={payroll} />

      <ConfirmDialog
        open={approveOpen}
        title="Approve Payroll"
        description={`Approve payroll ${payroll.payrollNumber} for ${payroll.employeeName}?`}
        confirmLabel="Approve"
        loading={approveMutation.isPending}
        onCancel={() => setApproveOpen(false)}
        onConfirm={handleApprove}
      />

      <ConfirmDialog
        open={payOpen}
        title="Record Payment"
        description={`Record payment of ${formatCurrency(amount)} for ${payroll.employeeName}.`}
        confirmLabel="Record Payment"
        loading={payMutation.isPending}
        onCancel={() => setPayOpen(false)}
        onConfirm={handlePay}
      />

      {payOpen ? (
        <Card className="space-y-4 p-6">
          <h3 className="font-semibold">Payment Details</h3>
          <div className="grid gap-3 md:grid-cols-2">
            <label className="space-y-1 text-sm">
              <span>Method</span>
              <select
                className="h-10 w-full rounded-md border border-slate-200 bg-white px-3 dark:border-slate-800 dark:bg-slate-950"
                value={method}
                onChange={(e) => setMethod(e.target.value as PayrollPaymentMethod)}
              >
                {PAYMENT_METHODS.map((option) => (
                  <option key={option} value={option}>
                    {option}
                  </option>
                ))}
              </select>
            </label>
            <label className="space-y-1 text-sm">
              <span>Amount</span>
              <Input
                type="number"
                value={amount}
                onChange={(e) => setAmount(Number(e.target.value))}
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Reference Number</span>
              <Input
                value={referenceNumber}
                onChange={(e) => setReferenceNumber(e.target.value)}
              />
            </label>
            <label className="space-y-1 text-sm">
              <span>Notes</span>
              <Input value={notes} onChange={(e) => setNotes(e.target.value)} />
            </label>
          </div>
        </Card>
      ) : null}
    </div>
  );
}
