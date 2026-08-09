import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PaymentStatus } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { OrderRepository } from '../order/order.repository';
import { calculateOrderTotals } from '../order/order.mapper';
import { decodeOrderNotes } from '../order/utils/order-meta.util';
import { FinanceAuditService } from './finance-audit.service';
import { FinanceSettingsRepository } from './finance-settings.repository';
import {
  GenerateInvoiceDto,
  InvoiceQueryDto,
  SendInvoiceDto,
} from './dto/invoice.dto';
import { InvoiceRecord } from './utils/invoice-meta.util';
import { PaymentRepository } from './payment.repository';

export interface InvoiceResponse {
  invoiceNumber: string;
  orderId: string;
  orderNumber: string;
  customerId: string;
  amount: number;
  status: string;
  generatedAt: string;
  sentAt: string | null;
  generatedByEmployeeId: string;
  sentByEmployeeId: string | null;
}

export interface PaginatedInvoices {
  items: InvoiceResponse[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

@Injectable()
export class InvoiceService {
  constructor(
    private readonly financeSettings: FinanceSettingsRepository,
    private readonly orderRepository: OrderRepository,
    private readonly paymentRepository: PaymentRepository,
    private readonly auditService: FinanceAuditService,
  ) {}

  async findAll(
    query: InvoiceQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedInvoices>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const skip = (page - 1) * limit;
    const [records, total] = await this.financeSettings.listInvoices(
      skip,
      limit,
      query.search,
    );

    let items = records.map((record) => this.toInvoiceResponse(record));

    if (query.dateFrom || query.dateTo) {
      items = items.filter((invoice) => {
        const generatedAt = new Date(invoice.generatedAt);

        if (query.dateFrom && generatedAt < query.dateFrom) {
          return false;
        }

        if (query.dateTo && generatedAt > query.dateTo) {
          return false;
        }

        return true;
      });
    }

    return {
      success: true,
      message: 'Invoices retrieved successfully',
      data: {
        items,
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async findOne(orderId: string): Promise<ApiSuccessResponse<InvoiceResponse>> {
    const invoice = await this.financeSettings.getInvoiceByOrderId(orderId);

    if (!invoice) {
      throw new NotFoundException('Invoice not found');
    }

    return {
      success: true,
      message: 'Invoice retrieved successfully',
      data: this.toInvoiceResponse(invoice),
    };
  }

  async generate(
    dto: GenerateInvoiceDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<InvoiceResponse>> {
    const order = await this.orderRepository.findById(dto.orderId);

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    const existing = await this.financeSettings.getInvoiceByOrderId(dto.orderId);

    if (existing) {
      return {
        success: true,
        message: 'Invoice already exists',
        data: this.toInvoiceResponse(existing),
      };
    }

    const paidTotal = await this.paymentRepository.getPaidTotalForOrder(dto.orderId);

    if (paidTotal <= 0) {
      throw new BadRequestException(
        'Invoice can only be generated for orders with payments',
      );
    }

    const { meta } = decodeOrderNotes(order.notes);
    const itemsSubtotal = order.items.reduce(
      (sum, item) => sum + Number(item.subtotal),
      0,
    );
    const grandTotal = calculateOrderTotals(itemsSubtotal, meta).grandTotal;

    const invoiceNumber =
      await this.financeSettings.generateReferenceNumber('INV');

    const record: InvoiceRecord = {
      invoiceNumber,
      orderId: dto.orderId,
      customerId: order.customerId,
      orderNumber: order.invoiceNumber,
      amount: grandTotal,
      status: paidTotal >= grandTotal ? 'PAID' : 'ISSUED',
      generatedAt: new Date().toISOString(),
      generatedByEmployeeId: employeeId,
    };

    await this.financeSettings.saveInvoice(record);

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'invoice_generated',
      referenceId: dto.orderId,
      description: `Invoice ${invoiceNumber} generated`,
    });

    return {
      success: true,
      message: 'Invoice generated successfully',
      data: this.toInvoiceResponse(record),
    };
  }

  async send(
    dto: SendInvoiceDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<InvoiceResponse>> {
    const invoice = await this.financeSettings.getInvoiceByOrderId(dto.orderId);

    if (!invoice) {
      throw new NotFoundException('Invoice not found. Generate invoice first.');
    }

    const updated: InvoiceRecord = {
      ...invoice,
      status: invoice.status === 'DRAFT' ? 'ISSUED' : invoice.status,
      sentAt: new Date().toISOString(),
      sentByEmployeeId: employeeId,
    };

    await this.financeSettings.saveInvoice(updated);

    await this.auditService.log({
      employeeId,
      module: 'finance',
      action: 'invoice_sent',
      referenceId: dto.orderId,
      description: `Invoice ${invoice.invoiceNumber} sent${dto.email ? ` to ${dto.email}` : ''}`,
    });

    return {
      success: true,
      message: 'Invoice sent successfully',
      data: this.toInvoiceResponse(updated),
    };
  }

  private toInvoiceResponse(record: InvoiceRecord): InvoiceResponse {
    return {
      invoiceNumber: record.invoiceNumber,
      orderId: record.orderId,
      orderNumber: record.orderNumber,
      customerId: record.customerId,
      amount: record.amount,
      status: record.status,
      generatedAt: record.generatedAt,
      sentAt: record.sentAt ?? null,
      generatedByEmployeeId: record.generatedByEmployeeId,
      sentByEmployeeId: record.sentByEmployeeId ?? null,
    };
  }
}
