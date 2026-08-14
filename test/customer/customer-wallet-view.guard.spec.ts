import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { CustomerSelfGuard } from '../../src/customer/guards/customer-self.guard';
import { CustomerWalletViewGuard } from '../../src/customer/guards/customer-wallet-view.guard';

describe('Customer wallet view authorization', () => {
  const walletViewGuard = new CustomerWalletViewGuard();
  const customerSelfGuard = new CustomerSelfGuard();

  const customerAId = '990e8400-e29b-41d4-a716-446655440005';
  const customerBId = 'aa0e8400-e29b-41d4-a716-446655440006';

  function createContext(
    user: unknown,
    customerId: string,
  ): ExecutionContext {
    return {
      switchToHttp: () => ({
        getRequest: () => ({
          user,
          params: { customerId },
        }),
      }),
      getHandler: () => ({}),
      getClass: () => ({}),
    } as ExecutionContext;
  }

  it('allows customer actor to view own wallet', () => {
    expect(
      walletViewGuard.canActivate(
        createContext(
          {
            actorType: 'customer',
            customerId: customerAId,
            phone: '081200000001',
          },
          customerAId,
        ),
      ),
    ).toBe(true);
  });

  it('rejects customer actor viewing another customer wallet', () => {
    expect(() =>
      walletViewGuard.canActivate(
        createContext(
          {
            actorType: 'customer',
            customerId: customerAId,
            phone: '081200000001',
          },
          customerBId,
        ),
      ),
    ).toThrow(ForbiddenException);
  });

  it('allows internal staff actor after global guards', () => {
    expect(
      walletViewGuard.canActivate(
        createContext(
          {
            employeeId: '660e8400-e29b-41d4-a716-446655440001',
            phone: '081234567891',
            roles: ['CASHIER'],
            permissions: ['wallet'],
          },
          customerAId,
        ),
      ),
    ).toBe(true);
  });

  it('keeps CustomerSelfGuard strict for customer-only routes', () => {
    expect(() =>
      customerSelfGuard.canActivate(
        createContext(
          {
            employeeId: '660e8400-e29b-41d4-a716-446655440001',
            phone: '081234567891',
            roles: ['CASHIER'],
            permissions: ['wallet'],
          },
          customerAId,
        ),
      ),
    ).toThrow(ForbiddenException);
  });
});
