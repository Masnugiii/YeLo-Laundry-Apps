export interface ServiceCategoryRef {
  id: string;
  code: string;
  name: string;
}

export interface CatalogService {
  id: string;
  serviceCode: string;
  serviceName: string;
  description: string | null;
  unitType: string;
  weight: boolean;
  piece: boolean;
  durationDay: number | null;
  isActive: boolean;
  category: ServiceCategoryRef;
  prices?: ServicePrice[];
}

export interface ServicePrice {
  id: string;
  serviceId: string;
  price: number | string;
  effectiveDate: string;
  expiredDate: string | null;
  isActive: boolean;
  service?: Pick<CatalogService, "id" | "serviceCode" | "serviceName" | "isActive">;
}

export interface NumberingSequence {
  id: string;
  type: string;
  prefix: string;
  currentCounter: number;
  padding: number;
  dailyReset: boolean;
  lastResetDate: string | null;
  isActive: boolean;
}

export interface PaymentMethod {
  id: string;
  code: string;
  name: string;
  isActive: boolean;
}

export interface ExpenseCategory {
  id: string;
  code: string;
  name: string;
  description: string | null;
  isActive: boolean;
}

export interface CreateServiceInput {
  categoryId: string;
  serviceCode: string;
  serviceName: string;
  description?: string;
  unitType: string;
  weight?: boolean;
  piece?: boolean;
  durationDay?: number;
  isActive?: boolean;
}

export interface UpdateServiceInput {
  serviceName?: string;
  description?: string | null;
  isActive?: boolean;
  durationDay?: number | null;
  serviceCode?: string;
  unitType?: string;
}

export interface CreateServicePriceInput {
  serviceId: string;
  price: number;
  effectiveDate?: string;
  isActive?: boolean;
}

export interface UpdateNumberingInput {
  prefix?: string;
  padding?: number;
  dailyReset?: boolean;
  isActive?: boolean;
}

export interface UpdatePaymentMethodInput {
  name?: string;
  isActive?: boolean;
}

export interface CreateExpenseCategoryInput {
  code: string;
  name: string;
  description?: string;
  isActive?: boolean;
}

export interface UpdateExpenseCategoryInput {
  name?: string;
  description?: string | null;
  isActive?: boolean;
}

export interface LaundryPerfume {
  id: string;
  code: string;
  name: string;
  extraPrice: number | string;
  displayOrder: number;
  isActive: boolean;
}

export interface CreatePerfumeInput {
  code: string;
  name: string;
  extraPrice?: number;
  displayOrder?: number;
  isActive?: boolean;
}

export interface UpdatePerfumeInput {
  name?: string;
  extraPrice?: number;
  displayOrder?: number;
  isActive?: boolean;
}
