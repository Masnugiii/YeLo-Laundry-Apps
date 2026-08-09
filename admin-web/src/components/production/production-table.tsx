import Link from "next/link";
import { DelayBadge, PriorityBadge, StageBadge } from "@/components/production/production-badges";
import { formatRemainingTime } from "@/lib/production-stages";
import { formatDate } from "@/lib/utils";
import type { ProductionListItem } from "@/types/production";

interface ProductionTableProps {
  orders: ProductionListItem[];
}

export function ProductionTable({ orders }: ProductionTableProps) {
  return (
    <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-slate-800">
      <table className="min-w-full divide-y divide-slate-200 text-sm dark:divide-slate-800">
        <thead className="bg-slate-50 dark:bg-slate-900/50">
          <tr>
            {[
              "Order Number",
              "Customer",
              "Stage",
              "Employee",
              "Weight",
              "Pieces",
              "Started At",
              "Updated At",
              "Estimated Finish",
              "Status",
            ].map((header) => (
              <th
                key={header}
                className="px-4 py-3 text-left font-medium text-slate-500"
              >
                {header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-200 bg-white dark:divide-slate-800 dark:bg-slate-950">
          {orders.map((order) => (
            <tr key={order.orderId} className="hover:bg-slate-50 dark:hover:bg-slate-900/40">
              <td className="px-4 py-3">
                <Link
                  href={`/operations/production/${order.orderId}`}
                  className="font-medium text-blue-600 hover:underline"
                >
                  {order.orderNumber}
                </Link>
              </td>
              <td className="px-4 py-3">
                <div>{order.customerName}</div>
                <div className="text-xs text-slate-500">{order.customerPhone}</div>
              </td>
              <td className="px-4 py-3">
                <StageBadge stage={order.productionStatus} />
              </td>
              <td className="px-4 py-3">
                {order.assignedEmployee?.fullName ?? "-"}
              </td>
              <td className="px-4 py-3">{order.totalWeight} kg</td>
              <td className="px-4 py-3">{order.totalPieces}</td>
              <td className="px-4 py-3">
                {order.stageStartedAt ? formatDate(order.stageStartedAt) : "-"}
              </td>
              <td className="px-4 py-3">{formatDate(order.updatedAt)}</td>
              <td className="px-4 py-3">
                {order.estimatedFinishDate
                  ? formatDate(order.estimatedFinishDate)
                  : "-"}
              </td>
              <td className="px-4 py-3">
                <div className="flex flex-wrap items-center gap-2">
                  <PriorityBadge priority={order.priority} />
                  <DelayBadge
                    isDelayed={order.isDelayed}
                    remainingMinutes={order.remainingMinutes}
                  />
                  <span className="text-xs text-slate-500">
                    {formatRemainingTime(order.remainingMinutes)}
                  </span>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
