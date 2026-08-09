import { Injectable, NotFoundException } from '@nestjs/common';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CustomerNoteItem,
  PaginatedCustomerNotes,
  toCustomerNoteItem,
} from './customer-note.mapper';
import { CustomerNoteRepository } from './customer-note.repository';
import { CustomerRepository } from './customer.repository';
import { CreateCustomerNoteDto } from './dto/create-customer-note.dto';
import { CustomerNoteQueryDto } from './dto/customer-note-query.dto';
import { UpdateCustomerNoteDto } from './dto/update-customer-note.dto';
import {
  decodeCustomerNote,
  encodeCustomerNote,
} from './utils/customer-note-meta.util';

@Injectable()
export class CustomerNoteService {
  constructor(
    private readonly customerRepository: CustomerRepository,
    private readonly noteRepository: CustomerNoteRepository,
  ) {}

  async findAll(
    customerId: string,
    query: CustomerNoteQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedCustomerNotes>> {
    await this.ensureCustomerExists(customerId);

    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const [notes, total] = await this.noteRepository.findMany(customerId, query);

    return {
      success: true,
      message: 'Customer notes retrieved successfully',
      data: {
        items: notes.map(toCustomerNoteItem),
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async findOne(
    customerId: string,
    noteId: string,
  ): Promise<ApiSuccessResponse<CustomerNoteItem>> {
    await this.ensureCustomerExists(customerId);

    const note = await this.noteRepository.findById(customerId, noteId);

    if (!note) {
      throw new NotFoundException('Customer note not found');
    }

    return {
      success: true,
      message: 'Customer note retrieved successfully',
      data: toCustomerNoteItem(note),
    };
  }

  async create(
    customerId: string,
    dto: CreateCustomerNoteDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<CustomerNoteItem>> {
    await this.ensureCustomerExists(customerId);

    const encodedNote = encodeCustomerNote(
      {
        title: dto.title,
        category: dto.category,
        isPinned: dto.isPinned,
      },
      dto.note,
    );

    const note = await this.noteRepository.create(
      customerId,
      employeeId,
      encodedNote,
    );

    return {
      success: true,
      message: 'Customer note created successfully',
      data: toCustomerNoteItem(note),
    };
  }

  async update(
    customerId: string,
    noteId: string,
    dto: UpdateCustomerNoteDto,
  ): Promise<ApiSuccessResponse<CustomerNoteItem>> {
    await this.ensureCustomerExists(customerId);

    const existing = await this.noteRepository.findById(customerId, noteId);

    if (!existing) {
      throw new NotFoundException('Customer note not found');
    }

    const decoded = decodeCustomerNote(existing.note);
    const encodedNote = encodeCustomerNote(
      {
        title: dto.title !== undefined ? dto.title : decoded.meta.title,
        category:
          dto.category !== undefined ? dto.category : decoded.meta.category,
        isPinned:
          dto.isPinned !== undefined ? dto.isPinned : decoded.meta.isPinned,
      },
      dto.note !== undefined ? dto.note : decoded.body,
    );

    const note = await this.noteRepository.update(noteId, encodedNote);

    return {
      success: true,
      message: 'Customer note updated successfully',
      data: toCustomerNoteItem(note),
    };
  }

  async remove(
    customerId: string,
    noteId: string,
  ): Promise<ApiSuccessResponse<null>> {
    await this.ensureCustomerExists(customerId);

    const existing = await this.noteRepository.findById(customerId, noteId);

    if (!existing) {
      throw new NotFoundException('Customer note not found');
    }

    await this.noteRepository.softDelete(noteId);

    return {
      success: true,
      message: 'Customer note deleted successfully',
      data: null,
    };
  }

  private async ensureCustomerExists(customerId: string): Promise<void> {
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }
  }
}
