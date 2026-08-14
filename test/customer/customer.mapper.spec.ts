import { toCustomerDetail } from '../../src/customer/customer.mapper';
import { CustomerDetailRecord } from '../../src/customer/customer.select';

function buildCustomer(
  overrides: Partial<CustomerDetailRecord> = {},
): CustomerDetailRecord {
  const now = new Date('2026-01-01T00:00:00.000Z');

  return {
    id: 'cust-1',
    customerCode: 'CUS-0001',
    fullName: 'Test Customer',
    phone: '081234567890',
    email: null,
    gender: null,
    birthDate: null,
    occupation: null,
    photoUrl: null,
    isActive: true,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    wallet: {
      currentBalance: 0 as never,
      currency: 'IDR',
      isActive: true,
    },
    rewardPoints: [],
    defaultAddress: null,
    addresses: [],
    ...overrides,
  };
}

describe('toCustomerDetail', () => {
  it('maps an empty addresses list', () => {
    const detail = toCustomerDetail(buildCustomer({ addresses: [] }));

    expect(detail.addresses).toEqual([]);
  });

  it('defaults missing addresses to an empty list', () => {
    const detail = toCustomerDetail(
      buildCustomer({ addresses: undefined as unknown as [] }),
    );

    expect(detail.addresses).toEqual([]);
  });
});
