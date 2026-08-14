import { NotFoundException } from '@nestjs/common';
import { EmployeeStatus } from '@prisma/client';
import { EmployeeRepository } from '../../src/employee/employee.repository';
import { EmployeeService } from '../../src/employee/employee.service';

describe('EmployeeService.update', () => {
  const existingEmployee = {
    id: 'emp-1',
    employeeCode: 'EMP0001',
    fullName: 'Owner',
    phone: '081234567890',
    email: null,
    position: 'Owner',
    status: EmployeeStatus.active,
    hiredAt: null,
    lastLoginAt: null,
    createdAt: new Date('2026-01-01T00:00:00.000Z'),
    updatedAt: new Date('2026-01-01T00:00:00.000Z'),
    deletedAt: null,
    employeeRoles: [],
  };

  const updatedEmployee = {
    ...existingEmployee,
    fullName: 'Nugroho Prasetyo',
    updatedAt: new Date('2026-08-11T05:00:00.000Z'),
  };

  function createService() {
    const repository = {
      findById: jest.fn(),
      findByEmployeeCode: jest.fn(),
      findByPhone: jest.fn(),
      findByEmail: jest.fn(),
      update: jest.fn(),
    } as unknown as jest.Mocked<EmployeeRepository>;

    const service = new EmployeeService(repository);
    return { service, repository };
  }

  it('persists fullName updates through the repository', async () => {
    const { service, repository } = createService();
    repository.findById.mockResolvedValue(existingEmployee);
    repository.update.mockResolvedValue(updatedEmployee);

    const result = await service.update('emp-1', {
      fullName: 'Nugroho Prasetyo',
    });

    expect(repository.update).toHaveBeenCalledWith('emp-1', {
      fullName: 'Nugroho Prasetyo',
    });
    expect(result.data?.fullName).toBe('Nugroho Prasetyo');
  });

  it('trims fullName before persisting', async () => {
    const { service, repository } = createService();
    repository.findById.mockResolvedValue(existingEmployee);
    repository.update.mockResolvedValue({
      ...updatedEmployee,
      fullName: 'Nugroho Prasetyo',
    });

    await service.update('emp-1', {
      fullName: '  Nugroho Prasetyo  ',
    });

    expect(repository.update).toHaveBeenCalledWith('emp-1', {
      fullName: 'Nugroho Prasetyo',
    });
  });

  it('throws when employee does not exist', async () => {
    const { service, repository } = createService();
    repository.findById.mockResolvedValue(null);

    await expect(
      service.update('missing', { fullName: 'Someone Else' }),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});
