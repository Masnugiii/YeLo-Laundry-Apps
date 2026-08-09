"use client";

import Link from "next/link";
import { use, useState } from "react";
import {
  DelayBadge,
  PriorityBadge,
  StageBadge,
} from "@/components/production/production-badges";
import {
  ProductionDetailSkeleton,
  QueryErrorState,
} from "@/components/production/list-states";
import { ProductionMetricsCard } from "@/components/production/metrics-card";
import { QcChecklist } from "@/components/production/qc-checklist";
import { StageActions } from "@/components/production/stage-actions";
import { ProductionTimeline } from "@/components/production/timeline";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { useToast } from "@/components/ui/toast";
import {
  useProductionAction,
  useProductionOrder,
  useQualityCheck,
} from "@/hooks/use-production";
import { getErrorMessage } from "@/lib/errors";
import { formatRemainingTime, STAGE_LABELS } from "@/lib/production-stages";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { QcChecklistState } from "@/types/production";

const defaultQcState: QcChecklistState = {
  clean: false,
  dry: false,
  ironed: false,
  folded: false,
  packaging: false,
  perfume: false,
  specialRequestCompleted: false,
  operatorNotes: "",
};

export default function ProductionDetailPage({
  params,
}: {
  params: Promise<{ orderId: string }>;
}) {
  const { orderId } = use(params);
  const toast = useToast();
  const { data, isLoading, isError, error, refetch } = useProductionOrder(orderId);
  const actionMutation = useProductionAction(orderId);
  const qualityMutation = useQualityCheck(orderId);
  const [qcState, setQcState] = useState<QcChecklistState>(defaultQcState);
  const [failDialogOpen, setFailDialogOpen] = useState(false);

  if (isLoading) return <ProductionDetailSkeleton />;

  if (isError || !data) {
    return (
      <QueryErrorState
        title="Failed to load production order"
        message={getErrorMessage(error, "Unable to fetch production order detail.")}
        onRetry={() => refetch()}
      />
    );
  }

  const order = data;

  const specialNotes =
    order.statusHistory.find((entry) => entry.notes)?.notes ??
    order.orderTimelines.find((entry) => entry.description)?.description ??
    "-";

  async function handleQualityCheck(passed: boolean) {
    if (!passed) {
      setFailDialogOpen(true);
      return;
    }

    const checklistSummary = [
      qcState.clean && "Clean",
      qcState.dry && "Dry",
      qcState.ironed && "Ironed",
      qcState.folded && "Folded",
      qcState.packaging && "Packaging",
      qcState.perfume && "Perfume",
      qcState.specialRequestCompleted && "Special request completed",
    ]
      .filter(Boolean)
      .join(", ");

    try {
      await qualityMutation.mutateAsync({
        passed: true,
        notes: [checklistSummary, qcState.operatorNotes].filter(Boolean).join(" — "),
      });
      toast.success(`QC passed for ${order.orderNumber}.`);
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to submit quality check."));
    }
  }

  async function confirmFailQc() {
    try {
      await qualityMutation.mutateAsync({
        passed: false,
        reason: qcState.operatorNotes || "QC checklist failed",
        reworkStage: "WAITING_IRON",
        notes: qcState.operatorNotes,
      });
      toast.error(`QC failed for ${order.orderNumber}. Sent for rework.`);
      setFailDialogOpen(false);
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to submit QC failure."));
    }
  }

  async function markReady() {
    try {
      await actionMutation.mutateAsync({ action: "ready", input: {} });
      toast.success(`Order ${order.orderNumber} is ready for pickup.`);
    } catch (mutationError) {
      toast.error(getErrorMessage(mutationError, "Failed to mark order ready."));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <Link href="/operations/production">
            <Button variant="outline" size="sm">
              Back to Production
            </Button>
          </Link>
          <h2 className="mt-3 text-2xl font-semibold text-slate-900 dark:text-slate-100">
            {order.orderNumber}
          </h2>
          <p className="text-sm text-slate-500">{order.queueNumber}</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <PriorityBadge priority={order.priority} />
          <StageBadge stage={order.productionStatus} />
          <DelayBadge
            isDelayed={order.isDelayed}
            remainingMinutes={order.remainingMinutes}
          />
        </div>
      </div>

      {order.isDelayed ? (
        <Card className="border-red-200 bg-red-50 text-red-700 dark:border-red-900 dark:bg-red-950/30 dark:text-red-200">
          Production delayed — {formatRemainingTime(order.remainingMinutes)}
        </Card>
      ) : null}

      <div className="grid gap-4 lg:grid-cols-2">
        <Card className="space-y-3">
          <h3 className="text-lg font-semibold">Order Information</h3>
          <div className="grid gap-2 text-sm">
            <p>
              <span className="text-slate-500">Customer:</span> {order.customerName}
            </p>
            <p>
              <span className="text-slate-500">Phone:</span> {order.customerPhone}
            </p>
            <p>
              <span className="text-slate-500">Service:</span> {order.serviceSummary}
            </p>
            <p>
              <span className="text-slate-500">Weight:</span> {order.totalWeight} kg
            </p>
            <p>
              <span className="text-slate-500">Pieces:</span> {order.totalPieces}
            </p>
            <p>
              <span className="text-slate-500">Special Notes:</span> {specialNotes}
            </p>
            <p>
              <span className="text-slate-500">Estimated Finish:</span>{" "}
              {order.estimatedFinishDate
                ? formatDate(order.estimatedFinishDate)
                : "-"}
            </p>
          </div>
        </Card>

        <Card className="space-y-3">
          <h3 className="text-lg font-semibold">Current Stage</h3>
          <p className="text-3xl font-semibold text-slate-900 dark:text-slate-100">
            {STAGE_LABELS[order.productionStatus]}
          </p>
          <p className="text-sm text-slate-500">
            Assigned: {order.assignedEmployee?.fullName ?? "Unassigned"}
          </p>
          <p className="text-sm text-slate-500">
            Stage started:{" "}
            {order.stageStartedAt ? formatDate(order.stageStartedAt) : "-"}
          </p>
        </Card>
      </div>

      <Card className="space-y-3">
        <h3 className="text-lg font-semibold">Order Items</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead>
              <tr className="text-left text-slate-500">
                <th className="px-2 py-2">Service</th>
                <th className="px-2 py-2">Qty</th>
                <th className="px-2 py-2">Weight</th>
                <th className="px-2 py-2">Subtotal</th>
              </tr>
            </thead>
            <tbody>
              {order.items.map((item) => (
                <tr key={item.id} className="border-t border-slate-200 dark:border-slate-800">
                  <td className="px-2 py-2">{item.serviceName}</td>
                  <td className="px-2 py-2">{item.quantity}</td>
                  <td className="px-2 py-2">{item.weight ?? "-"}</td>
                  <td className="px-2 py-2">{formatCurrency(item.subtotal)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      <div className="grid gap-4 xl:grid-cols-2">
        <ProductionTimeline history={order.productionHistory} />
        <ProductionMetricsCard order={order} />
      </div>

      <Card className="space-y-4">
        <h3 className="text-lg font-semibold">Assign Employee</h3>
        <p className="text-sm text-slate-500">
          Operator assignment follows stage actions. Current operator:{" "}
          <span className="font-medium text-slate-800 dark:text-slate-100">
            {order.assignedEmployee?.fullName ?? "Unassigned"}
          </span>
        </p>
        <div className="space-y-2">
          {order.productionHistory.map((event) => (
            <div
              key={`${event.stage}-${event.startedAt}`}
              className="rounded-lg border border-slate-200 p-3 text-sm dark:border-slate-800"
            >
              <p className="font-medium">{STAGE_LABELS[event.stage]}</p>
              <p className="text-slate-500">Employee ID: {event.employeeId}</p>
              <p className="text-slate-500">
                Assigned: {formatDate(event.startedAt)}
              </p>
              <p className="text-slate-500">
                Completed:{" "}
                {event.finishedAt ? formatDate(event.finishedAt) : "In progress"}
              </p>
            </div>
          ))}
        </div>
      </Card>

      <StageActions
        order={order}
        onQualityCheck={() => {
          document.getElementById("qc-checklist")?.scrollIntoView({
            behavior: "smooth",
          });
        }}
      />

      {order.productionStatus === "QUALITY_CHECK" ? (
        <div id="qc-checklist">
          <QcChecklist
            value={qcState}
            onChange={setQcState}
            onSubmit={handleQualityCheck}
            loading={qualityMutation.isPending}
          />
        </div>
      ) : null}

      {order.productionStatus === "READY" || order.productionStatus === "QUALITY_CHECK" ? (
        <Card className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <h3 className="text-lg font-semibold">Ready for Pickup</h3>
            <p className="text-sm text-slate-500">
              Mark order ready to notify pickup team and customer.
            </p>
          </div>
          <Button
            disabled={actionMutation.isPending}
            onClick={() => void markReady()}
          >
            Notify Ready Pickup
          </Button>
        </Card>
      ) : null}

      <ConfirmDialog
        open={failDialogOpen}
        title="Fail quality check?"
        description="This will send the order back for rework and record a QC failure."
        confirmLabel="Fail QC"
        destructive
        loading={qualityMutation.isPending}
        onCancel={() => setFailDialogOpen(false)}
        onConfirm={() => void confirmFailQc()}
      />
    </div>
  );
}
