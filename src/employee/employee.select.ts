import { Prisma } from '@prisma/client';

export const employeeListSelect = {
  id: true,
  employeeCode: true,
  fullName: true,
  phone: true,
  email: true,
  position: true,
  status: true,
  hiredAt: true,
  lastLoginAt: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
  employeeRoles: {
    where: { deletedAt: null },
    select: {
      role: {
        select: {
          code: true,
        },
      },
    },
  },
} satisfies Prisma.EmployeeSelect;

export const employeeDetailSelect = employeeListSelect;

export type EmployeeListRecord = Prisma.EmployeeGetPayload<{
  select: typeof employeeListSelect;
}>;
