import { Prisma } from '@prisma/client';

export const customerNoteSelect = {
  id: true,
  customerId: true,
  employeeId: true,
  note: true,
  createdAt: true,
  updatedAt: true,
  deletedAt: true,
  employee: {
    select: {
      id: true,
      fullName: true,
      employeeCode: true,
    },
  },
} satisfies Prisma.CustomerNoteSelect;

export type CustomerNoteRecord = Prisma.CustomerNoteGetPayload<{
  select: typeof customerNoteSelect;
}>;
