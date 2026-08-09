import { Badge } from "@/components/ui/badge";

export function CustomerStatusBadge({ isActive }: { isActive: boolean }) {
  return (
    <Badge
      className={
        isActive
          ? "bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300"
          : "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300"
      }
    >
      {isActive ? "ACTIVE" : "INACTIVE"}
    </Badge>
  );
}

export function CustomerMemberBadge({
  memberStatus,
}: {
  memberStatus: "MEMBER" | "REGULAR";
}) {
  return (
    <Badge
      className={
        memberStatus === "MEMBER"
          ? "bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300"
          : "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300"
      }
    >
      {memberStatus}
    </Badge>
  );
}
