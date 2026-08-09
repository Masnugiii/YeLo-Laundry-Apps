import { TicketStatus } from '@prisma/client';
import { CustomerServiceService } from '../../src/customer-service/customer-service.service';

describe('CustomerServiceService.getSummary', () => {
  const repository = {
    countSummary: jest.fn(),
    findMany: jest.fn(),
    findById: jest.fn(),
    updateTicket: jest.fn(),
    createMessage: jest.fn(),
    findLatestOrderSummary: jest.fn(),
  };

  let service: CustomerServiceService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new CustomerServiceService(repository as never);
  });

  it('aggregates unread, complaint, order question, and completed counts', async () => {
    repository.countSummary.mockResolvedValue([
      { status: TicketStatus.OPEN, subject: '[CS:KOMPLAIN] Noda baju' },
      { status: TicketStatus.IN_PROGRESS, subject: '[CS:TRACKING_ORDER] Status' },
      { status: TicketStatus.OPEN, subject: '[CS:ORDER_BARU] Order baru' },
      { status: TicketStatus.RESOLVED, subject: '[CS:PERTANYAAN] Jam buka' },
      { status: TicketStatus.CLOSED, subject: 'Tanpa kategori' },
    ]);

    const result = await service.getSummary();

    expect(result.success).toBe(true);
    expect(result.data).toEqual({
      unreadMessages: 3,
      newComplaints: 1,
      orderQuestions: 2,
      completed: 2,
    });
  });
});
