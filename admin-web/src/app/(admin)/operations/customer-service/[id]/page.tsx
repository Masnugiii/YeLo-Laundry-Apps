"use client";

import { FormEvent, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import {
  CustomerServiceCategoryBadge,
  CustomerServiceStatusBadge,
} from "@/components/customer-service/customer-service-badges";
import {
  CustomerServiceDetailSkeleton,
  EmptyState,
  QueryErrorState,
} from "@/components/customer-service/list-states";
import { Button } from "@/components/ui/button";
import { Card, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  useCustomerServiceTicket,
  useReplyCustomerServiceTicket,
  useUpdateCustomerServiceTicket,
} from "@/hooks/use-customer-service";
import { getErrorMessage } from "@/lib/errors";
import { formatDate } from "@/lib/utils";
import type {
  CustomerServiceCategory,
  CustomerServiceStatus,
} from "@/types/customer-service";

const STATUSES: CustomerServiceStatus[] = [
  "OPEN",
  "IN_PROGRESS",
  "WAITING_CUSTOMER",
  "RESOLVED",
  "CLOSED",
];

const CATEGORIES: CustomerServiceCategory[] = [
  "ORDER_BARU",
  "KOMPLAIN",
  "PERTANYAAN",
  "PROMO",
  "TRACKING_ORDER",
  "LAINNYA",
];

const selectClassName =
  "h-10 w-full rounded-lg border border-slate-200 bg-white px-3 text-sm outline-none ring-blue-500 focus:ring-2 dark:border-slate-700 dark:bg-slate-900";

export default function CustomerServiceDetailPage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const ticketId = params.id;
  const ticketQuery = useCustomerServiceTicket(ticketId);
  const updateMutation = useUpdateCustomerServiceTicket(ticketId);
  const replyMutation = useReplyCustomerServiceTicket(ticketId);
  const [reply, setReply] = useState("");

  const ticket = ticketQuery.data;

  const handleReply = async (event: FormEvent) => {
    event.preventDefault();
    if (!reply.trim()) return;
    await replyMutation.mutateAsync({ message: reply.trim() });
    setReply("");
  };

  if (ticketQuery.isLoading) {
    return <CustomerServiceDetailSkeleton />;
  }

  if (ticketQuery.isError) {
    return (
      <QueryErrorState
        title="Failed to load ticket"
        message={getErrorMessage(ticketQuery.error, "Unable to fetch ticket detail.")}
        onRetry={() => void ticketQuery.refetch()}
      />
    );
  }

  if (!ticket) {
    return (
      <EmptyState
        title="Ticket not found"
        description="The customer service ticket could not be loaded."
      />
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3">
        <div>
          <p className="text-lg font-semibold">{ticket.customerName}</p>
          <p className="text-sm text-slate-500">{ticket.whatsappNumber}</p>
        </div>
        <Button variant="outline" onClick={() => router.push("/operations/customer-service")}>
          Back to list
        </Button>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <Card className="p-4 lg:col-span-1">
          <CardTitle className="mb-3">Ticket</CardTitle>
          <div className="space-y-2 text-sm">
            <p>
              <span className="font-medium">Subject:</span> {ticket.subject}
            </p>
            <div className="flex flex-wrap items-center gap-2">
              <CustomerServiceStatusBadge status={ticket.status} />
              <CustomerServiceCategoryBadge category={ticket.category} />
            </div>
            <p>
              <span className="font-medium">AI Summary:</span> {ticket.aiSummary}
            </p>
            {ticket.assigneeName ? (
              <p>
                <span className="font-medium">Assignee:</span>{" "}
                {ticket.assigneeName}
              </p>
            ) : null}
          </div>

          <div className="mt-4 space-y-3">
            <select
              className={selectClassName}
              value={ticket.status}
              disabled={updateMutation.isPending}
              onChange={(event) =>
                updateMutation.mutate({
                  status: event.target.value as CustomerServiceStatus,
                })
              }
            >
              {STATUSES.map((item) => (
                <option key={item} value={item}>
                  {item.replaceAll("_", " ")}
                </option>
              ))}
            </select>
            <select
              className={selectClassName}
              value={ticket.category}
              disabled={updateMutation.isPending}
              onChange={(event) =>
                updateMutation.mutate({
                  category: event.target.value as CustomerServiceCategory,
                })
              }
            >
              {CATEGORIES.map((category) => (
                <option key={category} value={category}>
                  {category.replaceAll("_", " ")}
                </option>
              ))}
            </select>
          </div>
        </Card>

        <Card className="p-4 lg:col-span-2">
          <CardTitle className="mb-3">Messages</CardTitle>
          {ticket.messages.length === 0 ? (
            <EmptyState
              title="No messages yet"
              description="Customer messages will appear here."
            />
          ) : (
            <div className="space-y-3">
              {ticket.messages.map((message) => (
                <div
                  key={message.id}
                  className={`rounded-lg border p-3 text-sm ${
                    message.isFromCustomer
                      ? "border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-900/60"
                      : "border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-950"
                  }`}
                >
                  <div className="mb-1 flex items-center justify-between gap-2">
                    <span className="font-medium">
                      {message.isFromCustomer
                        ? ticket.customerName
                        : message.employeeName ?? "Employee"}
                    </span>
                    <span className="text-xs text-slate-500">
                      {formatDate(message.createdAt)}
                    </span>
                  </div>
                  <p>{message.content}</p>
                </div>
              ))}
            </div>
          )}

          <form className="mt-4 flex gap-2" onSubmit={handleReply}>
            <Input
              placeholder="Type a reply..."
              value={reply}
              onChange={(event) => setReply(event.target.value)}
              disabled={replyMutation.isPending}
            />
            <Button type="submit" disabled={replyMutation.isPending}>
              Send
            </Button>
          </form>
        </Card>
      </div>

      {ticket.relatedOrder ? (
        <Card className="p-4">
          <CardTitle className="mb-3">Related Order</CardTitle>
          <div className="grid gap-2 text-sm md:grid-cols-2">
            <p>
              <span className="font-medium">Queue:</span>{" "}
              {ticket.relatedOrder.queueNumber}
            </p>
            <p>
              <span className="font-medium">Service:</span>{" "}
              {ticket.relatedOrder.laundryService}
            </p>
            <p>
              <span className="font-medium">Status:</span>{" "}
              {ticket.relatedOrder.currentStatus}
            </p>
            <p>
              <span className="font-medium">ETA:</span>{" "}
              {ticket.relatedOrder.estimatedCompletion
                ? formatDate(ticket.relatedOrder.estimatedCompletion)
                : "-"}
            </p>
          </div>
        </Card>
      ) : null}
    </div>
  );
}
