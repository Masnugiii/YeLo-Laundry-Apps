import { Badge } from "@/components/ui/badge";

export function EmployeeRoleBadges({ roles }: { roles: string[] }) {
  if (!roles.length) {
    return <span className="text-sm text-slate-500">No roles assigned</span>;
  }

  return (
    <div className="flex flex-wrap gap-2">
      {roles.map((role) => (
        <Badge
          key={role}
          className="bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-300"
        >
          {role}
        </Badge>
      ))}
    </div>
  );
}
