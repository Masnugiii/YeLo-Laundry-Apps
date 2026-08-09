"use client";

import { useEffect, useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import {
  useCreateExpense,
  useDeleteExpense,
  useExpenseCategories,
  useExpenses,
  useUpdateExpense,
} from "@/hooks/use-finance";
import { isOwnerRole } from "@/lib/auth";
import { getErrorMessage } from "@/lib/errors";
import {
  exportRowsCsv,
  exportRowsExcel,
  printFinanceReport,
} from "@/lib/finance-export";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { CreateExpenseInput, Expense, ExpenseListParams } from "@/types/finance";

const PAGE_SIZES = [10, 25, 50, 100] as const;

const defaultForm: CreateExpenseInput = {
  categoryCode: "OTHER",
  title: "",
  description: "",
  amount: 0,
  expenseDate: new Date().toISOString().slice(0, 10),
};

export default function ExpensesPage() {
  const toast = useToast();
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [categoryCode, setCategoryCode] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState<(typeof PAGE_SIZES)[number]>(25);
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState<Expense | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Expense | null>(null);
  const [form, setForm] = useState<CreateExpenseInput>(defaultForm);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  const params: ExpenseListParams = {
    page,
    limit,
    ...(search ? { search } : {}),
    ...(categoryCode ? { categoryCode } : {}),
    ...(dateFrom ? { dateFrom } : {}),
    ...(dateTo ? { dateTo } : {}),
  };

  const { data, isLoading, isError, error, refetch } = useExpenses(params);
  const categoriesQuery = useExpenseCategories();
  const createMutation = useCreateExpense();
  const updateMutation = useUpdateExpense(editing?.id ?? "");
  const deleteMutation = useDeleteExpense();

  const items = data?.items ?? [];
  const meta = data?.meta;
  const canDelete = isOwnerRole();

  function openCreate() {
    setEditing(null);
    setForm(defaultForm);
    setFormOpen(true);
  }

  function openEdit(expense: Expense) {
    setEditing(expense);
    setForm({
      categoryCode: expense.category.code,
      title: expense.title,
      description: expense.description ?? "",
      amount: expense.amount,
      expenseDate: expense.expenseDate.slice(0, 10),
    });
    setFormOpen(true);
  }

  async function handleSubmit() {
    try {
      if (editing) {
        await updateMutation.mutateAsync(form);
        toast.success("Expense updated successfully.");
      } else {
        await createMutation.mutateAsync(form);
        toast.success("Expense created successfully.");
      }
      setFormOpen(false);
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to save expense."));
    }
  }

  async function handleDelete() {
    if (!deleteTarget) return;
    try {
      await deleteMutation.mutateAsync(deleteTarget.id);
      toast.success("Expense deleted successfully.");
      setDeleteTarget(null);
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to delete expense."));
    }
  }

  const exportRows = items.map((item) => ({
    Name: item.title,
    Category: item.category.name,
    Amount: item.amount,
    Date: formatDate(item.expenseDate),
    Notes: item.description ?? "",
    Status: item.approvalStatus ?? "PENDING",
  }));

  if (isLoading) return <FinanceListSkeleton />;

  if (isError) {
    return (
      <QueryErrorState
        title="Failed to load expenses"
        message={getErrorMessage(error, "Unable to fetch expenses.")}
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-2">
        <Button onClick={openCreate}>Create Expense</Button>
        <Button variant="outline" onClick={() => exportRowsCsv("expenses.csv", exportRows)}>Export CSV</Button>
        <Button variant="outline" onClick={() => exportRowsExcel("expenses.xlsx", exportRows)}>Export Excel</Button>
        <Button variant="outline" onClick={() => printFinanceReport("Expense Report", exportRows)}>Print / PDF</Button>
      </div>

      <div className="grid gap-3 xl:grid-cols-4">
        <Input className="xl:col-span-2" placeholder="Search expense name or notes" value={searchInput} onChange={(e) => setSearchInput(e.target.value)} />
        <select className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900" value={categoryCode} onChange={(e) => { setCategoryCode(e.target.value); setPage(1); }}>
          <option value="">All categories</option>
          {(categoriesQuery.data ?? []).map((category) => (
            <option key={category.id} value={category.code}>{category.name}</option>
          ))}
        </select>
        <Input type="date" value={dateFrom} onChange={(e) => { setDateFrom(e.target.value); setPage(1); }} />
        <Input type="date" value={dateTo} onChange={(e) => { setDateTo(e.target.value); setPage(1); }} />
      </div>

      {items.length === 0 ? (
        <EmptyState title="No expenses found" description="Create an expense to start tracking operational costs." />
      ) : (
        <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
          <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
            <thead className="bg-slate-50 dark:bg-slate-900/50">
              <tr>
                {["Expense Name", "Category", "Amount", "Date", "Notes", "Status", "Actions"].map((header) => (
                  <th key={header} className="px-4 py-3 text-left font-medium text-slate-500">{header}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
              {items.map((item) => (
                <tr key={item.id}>
                  <td className="px-4 py-3">{item.title}</td>
                  <td className="px-4 py-3">{item.category.name}</td>
                  <td className="px-4 py-3">{formatCurrency(item.amount)}</td>
                  <td className="px-4 py-3">{formatDate(item.expenseDate)}</td>
                  <td className="px-4 py-3">{item.description ?? "-"}</td>
                  <td className="px-4 py-3">{item.approvalStatus ?? "PENDING"}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-2">
                      <Button variant="outline" size="sm" onClick={() => openEdit(item)}>Edit</Button>
                      {canDelete ? (
                        <Button variant="destructive" size="sm" onClick={() => setDeleteTarget(item)}>Delete</Button>
                      ) : null}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {meta ? (
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p className="text-sm text-slate-500">Page {meta.page} of {meta.totalPages} ({meta.total} expenses)</p>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>Previous</Button>
            <Button variant="outline" size="sm" disabled={page >= meta.totalPages} onClick={() => setPage((p) => p + 1)}>Next</Button>
          </div>
        </div>
      ) : null}

      {formOpen ? (
        <Card className="space-y-4">
          <h3 className="text-lg font-semibold">{editing ? "Edit Expense" : "Create Expense"}</h3>
          <div className="grid gap-3 md:grid-cols-2">
            <Input placeholder="Expense name" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} />
            <select className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900" value={form.categoryCode} onChange={(e) => setForm({ ...form, categoryCode: e.target.value })}>
              {(categoriesQuery.data ?? []).map((category) => (
                <option key={category.id} value={category.code}>{category.name}</option>
              ))}
            </select>
            <Input type="number" placeholder="Amount" value={form.amount || ""} onChange={(e) => setForm({ ...form, amount: Number(e.target.value) })} />
            <Input type="date" value={form.expenseDate} onChange={(e) => setForm({ ...form, expenseDate: e.target.value })} />
            <Input className="md:col-span-2" placeholder="Notes" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
          </div>
          <div className="flex gap-2">
            <Button onClick={() => void handleSubmit()} disabled={createMutation.isPending || updateMutation.isPending}>Save</Button>
            <Button variant="outline" onClick={() => setFormOpen(false)}>Cancel</Button>
          </div>
        </Card>
      ) : null}

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        title="Delete expense?"
        description="Only owners can delete financial records. This action cannot be undone."
        confirmLabel="Delete"
        destructive
        loading={deleteMutation.isPending}
        onCancel={() => setDeleteTarget(null)}
        onConfirm={() => void handleDelete()}
      />
    </div>
  );
}
