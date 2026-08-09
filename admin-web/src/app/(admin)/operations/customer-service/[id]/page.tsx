"use client";

import Link from "next/link";
import { useParams } from "next/navigation";
import { FormEvent, useState } from "react";
import {
  EmptyState,
  FinanceListSkeleton,
  QueryErrorState,
} from "@/components/finance/list-states";
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

export default function CustomerServiceDetailPage() {
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
    return <FinanceListSkeleton />;
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
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold">{ticket.customerName}</h1>
          <p className="text-sm text-muted-foreground">{ticket.whatsappNumber}</p>
        </div>
        <Link
          href="/operations/customer-service"
          className="inline-flex h-10 items-center rounded-md border border-input px-4 text-sm hover:bg-muted"
        >
          Back to list
        </Link>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <Card className="p-4 lg:col-span-1">
          <CardTitle className="mb-3">Ticket</CardTitle>
          <div className="space-y-2 text-sm">
            <p>
              <span className="font-medium">Subject:</span> {ticket.subject}
            </p>
            <p>
              <span className="font-medium">Status:</span> {ticket.status}
            </p>
            <p>
              <span className="font-medium">Category:</span> {ticket.category}
            </p>
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
              className="h-10 w-full rounded-md border border-input bg-background px-3 text-sm"
              value={ticket.status}
              onChange={(event) =>
                updateMutation.mutate({
                  status: event.target.value as CustomerServiceStatus,
                })
              }
            >
              {STATUSES.map((status) => (
                <option key={status} value={status}>
                  {status}
                </option>
              ))}
            </select>
            <select
              className="h-10 w-full rounded-md border border-input bg-background px-3 text-sm"
              value={ticket.category}
              onChange={(event) =>
                updateMutation.mutate({
                  category: event.target.value as CustomerServiceCategory,
                })
              }
            >
              {CATEGORIES.map((category) => (
                <option key={category} value={category}>
                  {category}
                </option>
              ))}
            </select>
          </div>
        </Card>

        <Card className="p-4 lg:col-span-2">
          <CardTitle className="mb-3">Messages</CardTitle>
          {ticket.messages.length === 0 ? (
            <p className="text-sm text-muted-foreground">No messages yet.</p>
          ) : (
            <div className="space-y-3">
              {ticket.messages.map((message) => (
                <div
                  key={message.id}
                  className={`rounded-md border p-3 text-sm ${
                    message.isFromCustomer ? "bg-muted/30" : "bg-background"
                  }`}
                >
                  <div className="mb-1 flex items-center justify-between gap-2">
                    <span className="font-medium">
                      {message.isFromCustomer
                        ? ticket.customerName
                        : message.employeeName ?? "Employee"}
                    </span>
                    <span className="text-xs text-muted-foreground">
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
