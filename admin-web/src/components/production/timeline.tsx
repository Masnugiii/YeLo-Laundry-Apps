import { Card } from "@/components/ui/card";
import { STAGE_LABELS, TIMELINE_STAGES } from "@/lib/production-stages";
import { formatDate } from "@/lib/utils";
import type { ProductionStageEvent } from "@/types/production";

interface ProductionTimelineProps {
  history: ProductionStageEvent[];
}

export function ProductionTimeline({ history }: ProductionTimelineProps) {
  const historyByStage = new Map(
    history.map((event) => [event.stage, event]),
  );

  return (
    <Card className="space-y-4">
      <h3 className="text-lg font-semibold text-slate-900 dark:text-slate-100">
        Production Timeline
      </h3>
      <div className="space-y-4">
        {TIMELINE_STAGES.map((stage) => {
          const event = historyByStage.get(stage);
          return (
            <div
              key={stage}
              className="grid gap-2 border-l-2 border-slate-200 pl-4 dark:border-slate-700"
            >
              <div className="flex items-center justify-between gap-2">
                <p className="font-medium text-slate-800 dark:text-slate-100">
                  {STAGE_LABELS[stage]}
                </p>
                <span className="text-xs text-slate-500">
                  {event?.durationMinutes != null
                    ? `${event.durationMinutes} min`
                    : event
                      ? "In progress"
                      : "Pending"}
                </span>
              </div>
              {event ? (
                <div className="grid gap-1 text-sm text-slate-500">
                  <span>Employee: {event.employeeId}</span>
                  <span>Started: {formatDate(event.startedAt)}</span>
                  <span>
                    Finished:{" "}
                    {event.finishedAt ? formatDate(event.finishedAt) : "-"}
                  </span>
                  {event.notes ? <span>Notes: {event.notes}</span> : null}
                </div>
              ) : (
                <p className="text-sm text-slate-400">Not started</p>
              )}
            </div>
          );
        })}
      </div>
    </Card>
  );
}
