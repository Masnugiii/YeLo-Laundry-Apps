import { Injectable, NotFoundException } from '@nestjs/common';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { normalizePhone } from '../auth/utils/phone.util';
import {
  CustomerAddressItem,
  toCustomerAddressItem,
} from './customer-address.mapper';
import { CustomerAddressRepository } from './customer-address.repository';
import { CustomerRepository } from './customer.repository';
import { CreateCustomerAddressDto } from './dto/create-customer-address.dto';
import { CustomerAddressQueryDto } from './dto/customer-address-query.dto';
import { UpdateCustomerAddressDto } from './dto/update-customer-address.dto';

@Injectable()
export class CustomerAddressService {
  constructor(
    private readonly customerRepository: CustomerRepository,
    private readonly addressRepository: CustomerAddressRepository,
  ) {}

  async findAll(
    customerId: string,
    query: CustomerAddressQueryDto,
  ): Promise<ApiSuccessResponse<CustomerAddressItem[]>> {
    await this.ensureCustomerExists(customerId);

    const addresses = await this.addressRepository.findByCustomerId(
      customerId,
      query,
    );

    return {
      success: true,
      message: 'Customer addresses retrieved successfully',
      data: addresses.map(toCustomerAddressItem),
    };
  }

  async findOne(
    customerId: string,
    addressId: string,
  ): Promise<ApiSuccessResponse<CustomerAddressItem>> {
    await this.ensureCustomerExists(customerId);

    const address = await this.addressRepository.findById(customerId, addressId);

    if (!address) {
      throw new NotFoundException('Customer address not found');
    }

    return {
      success: true,
      message: 'Customer address retrieved successfully',
      data: toCustomerAddressItem(address),
    };
  }

  async create(
    customerId: string,
    dto: CreateCustomerAddressDto,
  ): Promise<ApiSuccessResponse<CustomerAddressItem>> {
    await this.ensureCustomerExists(customerId);

    const address = await this.addressRepository.create(customerId, {
      recipientName: dto.recipientName.trim(),
      phone: normalizePhone(dto.phone),
      province: dto.province.trim(),
      city: dto.city.trim(),
      district: dto.district.trim(),
      postalCode: dto.postalCode?.trim() ?? null,
      addressDetail: dto.address.trim(),
      latitude: dto.latitude,
      longitude: dto.longitude,
      isDefault: dto.isDefault ?? false,
    });

    return {
      success: true,
      message: 'Customer address created successfully',
      data: this.mapAddressResponse(address, {
        label: dto.label,
        notes: dto.notes,
      }),
    };
  }

  async update(
    customerId: string,
    addressId: string,
    dto: UpdateCustomerAddressDto,
  ): Promise<ApiSuccessResponse<CustomerAddressItem>> {
    await this.ensureCustomerExists(customerId);

    const existing = await this.addressRepository.findById(customerId, addressId);

    if (!existing) {
      throw new NotFoundException('Customer address not found');
    }

    const address = await this.addressRepository.update(customerId, addressId, {
      ...(dto.recipientName !== undefined && {
        recipientName: dto.recipientName.trim(),
      }),
      ...(dto.phone !== undefined && { phone: normalizePhone(dto.phone) }),
      ...(dto.province !== undefined && { province: dto.province.trim() }),
      ...(dto.city !== undefined && { city: dto.city.trim() }),
      ...(dto.district !== undefined && { district: dto.district.trim() }),
      ...(dto.postalCode !== undefined && {
        postalCode: dto.postalCode?.trim() ?? null,
      }),
      ...(dto.address !== undefined && { addressDetail: dto.address.trim() }),
      ...(dto.latitude !== undefined && { latitude: dto.latitude }),
      ...(dto.longitude !== undefined && { longitude: dto.longitude }),
      ...(dto.isDefault !== undefined && { isDefault: dto.isDefault }),
    });

    return {
      success: true,
      message: 'Customer address updated successfully',
      data: this.mapAddressResponse(address, {
        label: dto.label,
        notes: dto.notes,
      }),
    };
  }

  async remove(
    customerId: string,
    addressId: string,
  ): Promise<ApiSuccessResponse<null>> {
    await this.ensureCustomerExists(customerId);

    const existing = await this.addressRepository.findById(customerId, addressId);

    if (!existing) {
      throw new NotFoundException('Customer address not found');
    }

    await this.addressRepository.softDelete(customerId, addressId);

    return {
      success: true,
      message: 'Customer address deleted successfully',
      data: null,
    };
  }

  private mapAddressResponse(
    address: Parameters<typeof toCustomerAddressItem>[0],
    extras?: { label?: string; notes?: string },
  ): CustomerAddressItem {
    const item = toCustomerAddressItem(address);

    return {
      ...item,
      label: extras?.label?.trim() ?? item.label,
      notes: extras?.notes?.trim() ?? item.notes,
    };
  }

  private async ensureCustomerExists(customerId: string): Promise<void> {
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }
  }
}
