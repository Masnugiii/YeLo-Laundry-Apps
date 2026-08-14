import {
  EMPLOYEES_QUERY_KEY,
  employeeDetailQueryKey,
  employeesQueryKey,
  isEmployeeListQueryKey,
  isPaginatedEmployeeList,
  patchEmployeeListItems,
} from '../../admin-web/src/hooks/employee-query-cache';
import type { Employee } from '../../admin-web/src/types/employee';

const employeeA: Employee = {
  id: 'emp-1',
  employeeCode: 'EMP0001',
  fullName: 'Owner',
  phone: '081234567890',
  email: null,
  position: 'Owner',
  status: 'ACTIVE',
  roles: ['OWNER'],
  hiredAt: null,
  lastLoginAt: null,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
  deletedAt: null,
};

const employeeB: Employee = {
  ...employeeA,
  id: 'emp-2',
  employeeCode: 'EMP0002',
  fullName: 'Kasir Operasional',
  roles: ['CASHIER'],
};

describe('employee query cache helpers', () => {
  it('identifies paginated employee list query keys', () => {
    expect(isEmployeeListQueryKey(employeesQueryKey({ page: 1, limit: 20 }))).toBe(
      true,
    );
    expect(isEmployeeListQueryKey(employeeDetailQueryKey('emp-1'))).toBe(false);
    expect(isEmployeeListQueryKey([EMPLOYEES_QUERY_KEY, 'statistics'])).toBe(false);
  });

  it('accepts paginated employee list cache shape', () => {
    expect(
      isPaginatedEmployeeList({
        items: [employeeA],
        meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
      }),
    ).toBe(true);
  });

  it('rejects detail and statistics cache shapes', () => {
    expect(isPaginatedEmployeeList(employeeA)).toBe(false);
    expect(isPaginatedEmployeeList({ totalEmployees: 1 })).toBe(false);
    expect(isPaginatedEmployeeList(undefined)).toBe(false);
    expect(isPaginatedEmployeeList({ items: undefined, meta: {} })).toBe(false);
  });

  it('patches only matching employee inside paginated list cache', () => {
    const current = {
      items: [employeeA, employeeB],
      meta: { page: 1, limit: 20, total: 2, totalPages: 1 },
    };

    const patched = patchEmployeeListItems(current, 'emp-1', (employee) => ({
      ...employee,
      fullName: 'Nugroho Prasetyo',
    }));

    expect(patched).toEqual({
      items: [{ ...employeeA, fullName: 'Nugroho Prasetyo' }, employeeB],
      meta: current.meta,
    });
  });

  it('does not crash when cache has no items array', () => {
    expect(
      patchEmployeeListItems(employeeA, 'emp-1', (employee) => ({
        ...employee,
        fullName: 'Should Not Apply',
      })),
    ).toBe(employeeA);

    expect(
      patchEmployeeListItems(undefined, 'emp-1', (employee) => ({
        ...employee,
        fullName: 'Should Not Apply',
      })),
    ).toBeUndefined();
  });
});
