import { Decimal } from '@prisma/client/runtime/library';
import { CustomerAddressRecord } from './customer-address.select';

export interface CustomerAddressCoordinates {
  latitude: number | null;
  longitude: number | null;
}

export interface CustomerAddressItem {
  id: string;
  customerId: string;
  label: string | null;
  recipientName: string;
  phone: string;
  address: string;
  fullAddress: string;
  province: string;
  city: string;
  district: string;
  postalCode: string | null;
  coordinates: CustomerAddressCoordinates;
  isDefault: boolean;
  notes: string | null;
  createdAt: Date;
  updatedAt: Date;
}

function decimalToNumber(value: Decimal | null | undefined): number | null {
  if (value === null || value === undefined) {
    return null;
  }

  return Number(value);
}

export function buildFullAddress(address: {
  address: string;
  district: string;
  city: string;
  province: string;
  postalCode: string | null;
}): string {
  const parts = [
    address.address,
    address.district,
    address.city,
    address.province,
    address.postalCode,
  ].filter(Boolean);

  return parts.join(', ');
}

export function toCustomerAddressItem(
  address: CustomerAddressRecord,
): CustomerAddressItem {
  const streetAddress = address.addressDetail;

  return {
    id: address.id,
    customerId: address.customerId,
    label: null,
    recipientName: address.recipientName,
    phone: address.phone,
    address: streetAddress,
    fullAddress: buildFullAddress({
      address: streetAddress,
      district: address.district,
      city: address.city,
      province: address.province,
      postalCode: address.postalCode,
    }),
    province: address.province,
    city: address.city,
    district: address.district,
    postalCode: address.postalCode,
    coordinates: {
      latitude: decimalToNumber(address.latitude),
      longitude: decimalToNumber(address.longitude),
    },
    isDefault: address.isDefault,
    notes: null,
    createdAt: address.createdAt,
    updatedAt: address.updatedAt,
  };
}
