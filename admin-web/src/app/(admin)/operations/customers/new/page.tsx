"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";
import { useCreateCustomer } from "@/hooks/use-customers";
import { getErrorMessage } from "@/lib/errors";

export default function NewCustomerPage() {
  const router = useRouter();
  const toast = useToast();
  const createCustomer = useCreateCustomer();

  const [form, setForm] = useState({
    fullName: "",
    phone: "",
    email: "",
    gender: "",
    birthDate: "",
    address: "",
    memberStatus: "REGULAR",
    notes: "",
  });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    try {
      const customer = await createCustomer.mutateAsync({
        fullName: form.fullName.trim(),
        phone: form.phone.trim(),
        email: form.email.trim() || undefined,
        gender: form.gender || undefined,
        birthDate: form.birthDate || undefined,
        address: form.address.trim() || undefined,
        notes: form.notes.trim() || undefined,
        isActive: form.memberStatus !== "INACTIVE",
      });
      toast.success("Customer created successfully.");
      router.push(`/operations/customers/${customer.id}`);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to create customer."));
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <Link href="/operations/customers" className="text-sm text-blue-600 hover:underline">
          Back to customers
        </Link>
        <h2 className="mt-2 text-2xl font-semibold">Add Customer</h2>
      </div>

      <Card>
        <CardTitle>Customer Information</CardTitle>
        <form className="mt-4 grid gap-4 md:grid-cols-2" onSubmit={handleSubmit}>
          <label className="space-y-2 text-sm md:col-span-2">
            <span className="font-medium text-slate-500">Full Name</span>
            <Input
              value={form.fullName}
              onChange={(event) =>
                setForm((current) => ({ ...current, fullName: event.target.value }))
              }
              required
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Phone</span>
            <Input
              value={form.phone}
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
              value={form.email}
              onChange={(event) =>
                setForm((current) => ({ ...current, email: event.target.value }))
              }
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Gender</span>
            <select
              className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
              value={form.gender}
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
              value={form.birthDate}
              onChange={(event) =>
                setForm((current) => ({ ...current, birthDate: event.target.value }))
              }
            />
          </label>
          <label className="space-y-2 text-sm md:col-span-2">
            <span className="font-medium text-slate-500">Address</span>
            <Input
              value={form.address}
              onChange={(event) =>
                setForm((current) => ({ ...current, address: event.target.value }))
              }
            />
          </label>
          <label className="space-y-2 text-sm">
            <span className="font-medium text-slate-500">Member Status</span>
            <select
              className="h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm dark:border-slate-700 dark:bg-slate-900"
              value={form.memberStatus}
              onChange={(event) =>
                setForm((current) => ({ ...current, memberStatus: event.target.value }))
              }
            >
              <option value="REGULAR">Regular</option>
              <option value="MEMBER">Member</option>
              <option value="INACTIVE">Inactive</option>
            </select>
          </label>
          <label className="space-y-2 text-sm md:col-span-2">
            <span className="font-medium text-slate-500">Notes</span>
            <textarea
              className="min-h-24 w-full rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm dark:border-slate-700 dark:bg-slate-900"
              value={form.notes}
              onChange={(event) =>
                setForm((current) => ({ ...current, notes: event.target.value }))
              }
            />
          </label>
          <div className="md:col-span-2">
            <Button type="submit" disabled={createCustomer.isPending}>
              {createCustomer.isPending ? "Creating..." : "Create customer"}
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
