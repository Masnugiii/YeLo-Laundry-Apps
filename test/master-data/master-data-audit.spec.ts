import { PaymentMethodService } from '../../src/master-data/payment-method.service';
import { ExpenseCategoryService } from '../../src/master-data/expense-category.service';
import { MasterDataAuditService } from '../../src/master-data/audit/master-data-audit.service';

describe('Master data audit logging', () => {
  const record = jest.fn();
  const auditLogService = { record };
  const auditService = new MasterDataAuditService(auditLogService as never);

  const prisma = {
    paymentMethod: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    expenseCategory: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('creates audit log when payment method is updated', async () => {
    const service = new PaymentMethodService(prisma as never, auditService);
    prisma.paymentMethod.findFirst.mockResolvedValue({
      id: 'pm-1',
      code: 'CASH',
      name: 'Cash',
      isActive: true,
    });
    prisma.paymentMethod.update.mockResolvedValue({
      id: 'pm-1',
      code: 'CASH',
      name: 'Cash Updated',
      isActive: false,
    });

    await service.update('pm-1', { name: 'Cash Updated', isActive: false }, 'owner-id');

    expect(record).toHaveBeenCalledWith(
      expect.objectContaining({
        module: 'payment_methods',
        action: 'payment_method_updated',
      }),
    );
  });

  it('creates audit log when expense category is created', async () => {
    const service = new ExpenseCategoryService(prisma as never, auditService);
    prisma.expenseCategory.findFirst.mockResolvedValue(null);
    prisma.expenseCategory.create.mockResolvedValue({
      id: 'cat-1',
      code: 'TOOLS',
      name: 'Tools',
      isActive: true,
    });

    await service.create(
      { code: 'TOOLS', name: 'Tools' },
      'owner-id',
    );

    expect(record).toHaveBeenCalledWith(
      expect.objectContaining({
        module: 'expense_categories',
        action: 'expense_category_created',
      }),
    );
  });
});
