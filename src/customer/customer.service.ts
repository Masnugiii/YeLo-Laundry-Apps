import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { normalizePhone } from '../auth/utils/phone.util';
import {
  CustomerBusinessSummary,
  CustomerDetail,
  CustomerImportResult,
  CustomerListItem,
  CustomerSearchResult,
  PaginatedCustomers,
  toCustomerDetail,
  toCustomerListItem,
  toCustomerSearchResult,
} from './customer.mapper';
import { CustomerRepository } from './customer.repository';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { CustomerQueryDto } from './dto/customer-query.dto';
import { CustomerSearchDto } from './dto/customer-search.dto';
import {
  DuplicateImportStrategy,
  ImportCustomersDto,
} from './dto/import-customers.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
import { UpdateCustomerStatusDto } from './dto/update-customer-status.dto';

@Injectable()
export class CustomerService {
  private readonly logger = new Logger(CustomerService.name);

  constructor(private readonly customerRepository: CustomerRepository) {}

  async findAll(
    query: CustomerQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedCustomers>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [customers, total] = await this.customerRepository.findMany(query);
    const statsMap = await this.customerRepository.getOrderStatsByCustomerIds(
      customers.map((customer) => customer.id),
    );

    return {
      success: true,
      message: 'Customers retrieved successfully',
      data: {
        items: customers.map((customer) =>
          toCustomerListItem(customer, statsMap.get(customer.id)),
        ),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async getSummary(
    id: string,
  ): Promise<ApiSuccessResponse<CustomerBusinessSummary>> {
    const customer = await this.customerRepository.findById(id);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    const summary = await this.customerRepository.getBusinessSummary(id);

    return {
      success: true,
      message: 'Customer summary retrieved successfully',
      data: {
        ...summary,
        memberSince: customer.createdAt,
      },
    };
  }

  async updateStatus(
    id: string,
    dto: UpdateCustomerStatusDto,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    return this.update(id, { isActive: dto.isActive });
  }

  async importCustomers(
    dto: ImportCustomersDto,
  ): Promise<ApiSuccessResponse<CustomerImportResult>> {
    const result: CustomerImportResult = {
      imported: 0,
      duplicate: 0,
      failed: 0,
      errors: [],
    };

    const duplicatePhones = new Set<string>();

    for (const [index, row] of dto.rows.entries()) {
      const phone = normalizePhone(row.phone);
      const existing = await this.customerRepository.findByPhone(phone);

      if (existing) {
        duplicatePhones.add(phone);
        if (dto.duplicateStrategy === DuplicateImportStrategy.CANCEL) {
          return {
            success: true,
            message: 'Import cancelled due to duplicate phone number',
            data: {
              imported: 0,
              duplicate: duplicatePhones.size,
              failed: 0,
              errors: [
                {
                  row: index + 1,
                  phone,
                  message: 'Duplicate phone number detected. Import cancelled.',
                },
              ],
            },
          };
        }

        if (dto.duplicateStrategy === DuplicateImportStrategy.SKIP) {
          result.duplicate += 1;
          continue;
        }

        try {
          await this.update(existing.id, {
            fullName: row.fullName.trim(),
            email: row.email?.trim(),
            gender: row.gender,
            birthDate: row.birthDate,
            isActive: row.memberStatus?.toUpperCase() !== 'INACTIVE',
          });
          result.imported += 1;
        } catch (error) {
          result.failed += 1;
          result.errors.push({
            row: index + 1,
            phone,
            message:
              error instanceof Error ? error.message : 'Failed to update customer',
          });
        }

        continue;
      }

      try {
        await this.create({
          fullName: row.fullName.trim(),
          phone,
          email: row.email?.trim(),
          gender: row.gender,
          birthDate: row.birthDate,
          isActive: row.memberStatus?.toUpperCase() !== 'INACTIVE',
        });
        result.imported += 1;
      } catch (error) {
        result.failed += 1;
        result.errors.push({
          row: index + 1,
          phone,
          message:
            error instanceof Error ? error.message : 'Failed to create customer',
        });
      }
    }

    return {
      success: true,
      message: 'Customer import completed',
      data: result,
    };
  }

  async exportCustomers(query: CustomerQueryDto): Promise<string> {
    const customers = await this.customerRepository.findManyForExport(query);
    const statsMap = await this.customerRepository.getOrderStatsByCustomerIds(
      customers.map((customer) => customer.id),
    );

    const headers = [
      'Customer Code',
      'Full Name',
      'Phone',
      'Email',
      'Member Status',
      'Total Orders',
      'Total Spending',
      'Last Order',
      'Status',
      'Created Date',
    ];

    const rows = customers.map((customer) => {
      const item = toCustomerListItem(customer, statsMap.get(customer.id));
      return [
        item.customerCode,
        item.fullName,
        item.phone,
        item.email ?? '',
        item.memberStatus,
        String(item.totalOrders),
        String(item.totalSpending),
        item.lastOrderAt ? item.lastOrderAt.toISOString() : '',
        item.isActive ? 'ACTIVE' : 'INACTIVE',
        item.createdAt.toISOString(),
      ];
    });

    return [
      headers.join(','),
      ...rows.map((row) =>
        row.map((value) => `"${String(value).replace(/"/g, '""')}"`).join(','),
      ),
    ].join('\n');
  }

  async search(
    dto: CustomerSearchDto,
  ): Promise<ApiSuccessResponse<CustomerSearchResult[]>> {
    const customers = await this.customerRepository.search(
      dto.q.trim(),
      dto.limit ?? 10,
    );

    return {
      success: true,
      message: 'Search results retrieved successfully',
      data: customers.map(toCustomerSearchResult),
    };
  }

  async findOne(id: string): Promise<ApiSuccessResponse<CustomerDetail>> {
    const customer = await this.customerRepository.findById(id);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    return {
      success: true,
      message: 'Customer retrieved successfully',
      data: toCustomerDetail(
        customer,
        await this.customerRepository
          .getOrderStatsByCustomerIds([customer.id])
          .then((map) => map.get(customer.id)),
      ),
    };
  }

  async create(
    dto: CreateCustomerDto,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    const phone = normalizePhone(dto.phone);
    const email = dto.email?.trim().toLowerCase() ?? null;

    await this.ensureUniqueFields({ phone, email: email ?? undefined });

    const customerCode = await this.customerRepository.generateNextCustomerCode();

    const customer = await this.customerRepository.createWithWallet({
      customerCode,
      fullName: dto.fullName.trim(),
      phone,
      email,
      gender: dto.gender,
      birthDate: dto.birthDate,
      isActive: dto.isActive ?? true,
      photoUrl: dto.photoUrl,
    });

    this.logger.log(`Customer created: ${customer.id} (${customer.customerCode})`);

    return {
      success: true,
      message: 'Customer created successfully',
      data: toCustomerDetail(customer),
    };
  }

  async update(
    id: string,
    dto: UpdateCustomerDto,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    const existing = await this.customerRepository.findById(id);

    if (!existing) {
      throw new NotFoundException('Customer not found');
    }

    const phone = dto.phone ? normalizePhone(dto.phone) : undefined;
    const email =
      dto.email === undefined
        ? undefined
        : dto.email
          ? dto.email.trim().toLowerCase()
          : null;

    await this.ensureUniqueFields({ phone, email: email ?? undefined }, id);

    const customer = await this.customerRepository.update(id, {
      ...(dto.fullName !== undefined && { fullName: dto.fullName.trim() }),
      ...(phone !== undefined && { phone }),
      ...(dto.email !== undefined && { email }),
      ...(dto.gender !== undefined && { gender: dto.gender }),
      ...(dto.birthDate !== undefined && { birthDate: dto.birthDate }),
      ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      ...(dto.photoUrl !== undefined && { photoUrl: dto.photoUrl }),
    });

    this.logger.log(`Customer updated: ${customer.id} (${customer.customerCode})`);

    return {
      success: true,
      message: 'Customer updated successfully',
      data: toCustomerDetail(customer),
    };
  }

  async remove(id: string): Promise<ApiSuccessResponse<null>> {
    const existing = await this.customerRepository.findById(id);

    if (!existing) {
      throw new NotFoundException('Customer not found');
    }

    const openOrders = await this.customerRepository.countOpenOrders(id);

    if (openOrders > 0) {
      throw new BadRequestException(
        'Cannot delete customer with open orders',
      );
    }

    await this.customerRepository.softDelete(id);

    this.logger.log(
      `Customer soft deleted: ${existing.id} (${existing.customerCode})`,
    );

    return {
      success: true,
      message: 'Customer deleted successfully',
      data: null,
    };
  }

  async restore(id: string): Promise<ApiSuccessResponse<CustomerDetail>> {
    const existing = await this.customerRepository.findById(id, true);

    if (!existing) {
      throw new NotFoundException('Customer not found');
    }

    if (!existing.deletedAt) {
      throw new BadRequestException('Customer is not deleted');
    }

    await this.ensureUniqueFields(
      {
        phone: existing.phone,
        email: existing.email ?? undefined,
      },
      id,
    );

    const customer = await this.customerRepository.restore(id);

    this.logger.log(`Customer restored: ${customer.id} (${customer.customerCode})`);

    return {
      success: true,
      message: 'Customer restored successfully',
      data: toCustomerDetail(customer),
    };
  }

  private async ensureUniqueFields(
    fields: { phone?: string; email?: string },
    excludeId?: string,
  ): Promise<void> {
    if (fields.phone) {
      const existing = await this.customerRepository.findByPhone(
        fields.phone,
        excludeId,
      );

      if (existing) {
        throw new ConflictException('Phone number already exists');
      }
    }

    if (fields.email) {
      const existing = await this.customerRepository.findByEmail(
        fields.email,
        excludeId,
      );

      if (existing) {
        throw new ConflictException('Email already exists');
      }
    }
  }
}
