import { Prisma } from '@prisma/client';

export const ticketListSelect = {
  id: true,
  subject: true,
  status: true,
  priority: true,
  createdAt: true,
  updatedAt: true,
  customer: {
    select: {
      id: true,
      fullName: true,
      phone: true,
    },
  },
  messages: {
    orderBy: { createdAt: 'desc' as const },
    take: 1,
    select: {
      id: true,
      message: true,
      createdAt: true,
      senderType: true,
    },
  },
} satisfies Prisma.CustomerServiceTicketSelect;

export const ticketDetailSelect = {
  id: true,
  subject: true,
  status: true,
  priority: true,
  createdAt: true,
  updatedAt: true,
  closedAt: true,
  customer: {
    select: {
      id: true,
      fullName: true,
      phone: true,
      email: true,
    },
  },
  employee: {
    select: {
      id: true,
      fullName: true,
    },
  },
  messages: {
    orderBy: { createdAt: 'asc' as const },
    select: {
      id: true,
      message: true,
      senderType: true,
      createdAt: true,
      employee: {
        select: {
          id: true,
          fullName: true,
        },
      },
    },
  },
} satisfies Prisma.CustomerServiceTicketSelect;

export type TicketListRecord = Prisma.CustomerServiceTicketGetPayload<{
  select: typeof ticketListSelect;
}>;

export type TicketDetailRecord = Prisma.CustomerServiceTicketGetPayload<{
  select: typeof ticketDetailSelect;
}>;
