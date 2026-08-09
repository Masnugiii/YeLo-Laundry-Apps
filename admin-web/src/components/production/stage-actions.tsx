"use client";

import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { ConfirmDialog } from "@/components/ui/confirm-dialog";
import { useToast } from "@/components/ui/toast";
import { useProductionAction } from "@/hooks/use-production";
import { getErrorMessage } from "@/lib/errors";
import { getProductionAction, STAGE_LABELS } from "@/lib/production-stages";
import type { ProductionDetail } from "@/types/production";
import { useState } from "react";

interface StageActionsProps {
  order: ProductionDetail;
  onQualityCheck?: () => void;
}

export function StageActions({ order, onQualityCheck }: StageActionsProps) {
  const toast = useToast();
  const [confirmOpen, setConfirmOpen] = useState(false);
  const actionMutation = useProductionAction(order.orderId);
  const action = getProductionAction(order.productionStatus);
  const isActiveStage = [
    "WASHING",
    "DRYING",
    "IRONING",
    "QUALITY_CHECK",
  ].includes(order.productionStatus);

  async function runAction() {
    if (order.productionStatus === "QUALITY_CHECK") {
      onQualityCheck?.();
      return;
    }

    if (!action) {
      toast.error("No production action available for this stage.");
      return;
    }

    try {
      await actionMutation.mutateAsync({ action, input: {} });
      const message =
        action === "ready"
          ? `Order ${order.orderNumber} is ready for pickup.`
          : `Production stage updated for ${order.orderNumber}.`;
      toast.success(message);
      setConfirmOpen(false);
    } catch (error) {
      toast.error(getErrorMessage(error, "Failed to update production stage."));
    }
  }

  return (
    <>
      <Card className="space-y-4">
        <h3 className="text-lg font-semibold text-slate-900 dark:text-slate-100">
          Change Status
        </h3>
        <p className="text-sm text-slate-500">
          Current stage:{" "}
          <span className="font-medium text-slate-800 dark:text-slate-100">
            {STAGE_LABELS[order.productionStatus]}
          </span>
        </p>
        <div className="flex flex-wrap gap-2">
          <Button
            disabled={actionMutation.isPending || !action || isActiveStage}
            onClick={() => runAction()}
          >
            Start
          </Button>
          <Button variant="outline" disabled title="Pause is not supported by the backend API">
            Pause
          </Button>
          <Button variant="outline" disabled title="Resume is not supported by the backend API">
            Resume
          </Button>
          <Button
            variant="outline"
            disabled={actionMutation.isPending || !action}
            onClick={() => setConfirmOpen(true)}
          >
            Complete Stage
          </Button>
          <Button
            disabled={actionMutation.isPending || !action}
            onClick={() => runAction()}
          >
            Move Next Stage
          </Button>
        </div>
      </Card>

      <ConfirmDialog
        open={confirmOpen}
        title="Complete production stage?"
        description={`Confirm completing ${STAGE_LABELS[order.productionStatus]} for order ${order.orderNumber}.`}
        confirmLabel="Complete Stage"
        loading={actionMutation.isPending}
        onCancel={() => setConfirmOpen(false)}
        onConfirm={() => runAction()}
      />
    </>
  );
}
