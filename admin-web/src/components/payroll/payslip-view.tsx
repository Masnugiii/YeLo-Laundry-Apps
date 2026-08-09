"use client";

import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { PayrollDetail } from "@/types/payroll";

export function PayslipView({ payroll }: { payroll: PayrollDetail }) {
  function handlePrint() {
    const printWindow = window.open("", "_blank", "noopener,noreferrer,width=800,height=900");
    if (!printWindow) return;

    const bonusRows = payroll.bonuses
      .map(
        (bonus) =>
          `<tr><td>${bonus.type}</td><td>${bonus.notes ?? "-"}</td><td style="text-align:right">${formatCurrency(bonus.amount)}</td></tr>`,
      )
      .join("");

    const deductionRows = payroll.deductions
      .map(
        (deduction) =>
          `<tr><td>${deduction.type}</td><td>${deduction.notes ?? "-"}</td><td style="text-align:right">${formatCurrency(deduction.amount)}</td></tr>`,
      )
      .join("");

    printWindow.document.write(`
      <html>
        <head>
          <title>Payslip ${payroll.payrollNumber}</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 32px; color: #111; }
            h1 { font-size: 22px; margin-bottom: 4px; }
            .meta { color: #555; font-size: 13px; margin-bottom: 24px; }
            .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px; }
            .box { border: 1px solid #ddd; padding: 12px; border-radius: 8px; }
            .box h3 { margin: 0 0 8px; font-size: 14px; }
            table { width: 100%; border-collapse: collapse; font-size: 13px; margin-bottom: 16px; }
            th, td { border: 1px solid #ddd; padding: 8px; }
            th { background: #f5f5f5; text-align: left; }
            .total { font-size: 18px; font-weight: bold; margin-top: 16px; }
            .signatures { display: grid; grid-template-columns: 1fr 1fr; gap: 48px; margin-top: 48px; }
            .sign-line { border-top: 1px solid #333; padding-top: 8px; text-align: center; font-size: 12px; }
          </style>
        </head>
        <body>
          <h1>Yelo Laundry — Payslip</h1>
          <div class="meta">${payroll.payrollNumber} · ${formatDate(payroll.periodStart)} – ${formatDate(payroll.periodEnd)}</div>
          <div class="grid">
            <div class="box">
              <h3>Employee</h3>
              <div>${payroll.employeeName}</div>
              <div>${payroll.employeeCode} · ${payroll.role}</div>
              <div>${payroll.position}</div>
            </div>
            <div class="box">
              <h3>Attendance</h3>
              <div>Present: ${payroll.attendance.present}</div>
              <div>Absent: ${payroll.attendance.absent}</div>
              <div>Late: ${payroll.attendance.late}</div>
              <div>Leave: ${payroll.attendance.leave}</div>
            </div>
          </div>
          <h3>Production</h3>
          <table>
            <tr><th>Category</th><th>Qty</th></tr>
            <tr><td>Laundry Kg</td><td>${payroll.production.laundryKg}</td></tr>
            <tr><td>Laundry Piece</td><td>${payroll.production.laundryPiece}</td></tr>
            <tr><td>Ironing Kg</td><td>${payroll.production.ironingKg}</td></tr>
            <tr><td>Ironing Piece</td><td>${payroll.production.ironingPiece}</td></tr>
            <tr><td>Orders Finished</td><td>${payroll.production.ordersFinished}</td></tr>
            <tr><td><strong>Production Salary</strong></td><td><strong>${formatCurrency(payroll.productionSalary)}</strong></td></tr>
          </table>
          <h3>Bonus</h3>
          <table>
            <tr><th>Type</th><th>Notes</th><th>Amount</th></tr>
            ${bonusRows || '<tr><td colspan="3">No bonus</td></tr>'}
          </table>
          <h3>Deduction</h3>
          <table>
            <tr><th>Type</th><th>Notes</th><th>Amount</th></tr>
            ${deductionRows || '<tr><td colspan="3">No deduction</td></tr>'}
          </table>
          <div class="total">Net Salary: ${formatCurrency(payroll.netSalary)}</div>
          <div class="signatures">
            <div class="sign-line">Employee Signature</div>
            <div class="sign-line">Authorized Signature</div>
          </div>
        </body>
      </html>
    `);
    printWindow.document.close();
    printWindow.focus();
    printWindow.print();
  }

  return (
    <Card className="space-y-4 p-6">
      <div className="flex items-start justify-between gap-4">
        <div>
          <h3 className="text-lg font-semibold">Payslip Preview</h3>
          <p className="text-sm text-slate-500">
            {payroll.payrollNumber} · {formatDate(payroll.periodStart)} –{" "}
            {formatDate(payroll.periodEnd)}
          </p>
        </div>
        <Button onClick={handlePrint}>Print Payslip</Button>
      </div>
      <div className="grid gap-4 md:grid-cols-2">
        <div className="rounded-lg border p-4 text-sm">
          <p className="font-medium">{payroll.employeeName}</p>
          <p className="text-slate-500">
            {payroll.employeeCode} · {payroll.role}
          </p>
        </div>
        <div className="rounded-lg border p-4 text-sm">
          <p>Production Salary: {formatCurrency(payroll.productionSalary)}</p>
          <p>Bonus: {formatCurrency(payroll.bonus)}</p>
          <p>Deduction: {formatCurrency(payroll.deduction)}</p>
          <p className="font-semibold">Net: {formatCurrency(payroll.netSalary)}</p>
        </div>
      </div>
    </Card>
  );
}
