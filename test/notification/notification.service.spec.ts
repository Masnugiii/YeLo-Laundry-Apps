import { NotificationService } from '../../src/notification/notification.service';

describe('NotificationService.markAllRead', () => {
  const repository = {
    markAllCustomerRead: jest.fn(),
    markAllEmployeeRead: jest.fn(),
  };

  let service: NotificationService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new NotificationService(
      repository as never,
      {} as never,
      {} as never,
    );
  });

  it('marks all notifications as read for authenticated customer', async () => {
    repository.markAllCustomerRead.mockResolvedValue(3);

    const result = await service.markAllRead({
      customerId: 'customer-a',
      roles: [],
    });

    expect(repository.markAllCustomerRead).toHaveBeenCalledWith('customer-a');
    expect(repository.markAllEmployeeRead).not.toHaveBeenCalled();
    expect(result).toEqual({
      success: true,
      message: 'All notifications marked as read',
      data: { updated: 3 },
    });
  });

  it('marks all notifications as read for authenticated employee', async () => {
    repository.markAllEmployeeRead.mockResolvedValue(5);

    const result = await service.markAllRead({
      employeeId: 'employee-a',
      roles: ['CASHIER'],
    });

    expect(repository.markAllEmployeeRead).toHaveBeenCalledWith('employee-a');
    expect(repository.markAllCustomerRead).not.toHaveBeenCalled();
    expect(result.data?.updated).toBe(5);
  });

  it('returns zero updated when actor has no notification scope', async () => {
    const result = await service.markAllRead({ roles: [] });

    expect(repository.markAllCustomerRead).not.toHaveBeenCalled();
    expect(repository.markAllEmployeeRead).not.toHaveBeenCalled();
    expect(result.data?.updated).toBe(0);
  });
});
