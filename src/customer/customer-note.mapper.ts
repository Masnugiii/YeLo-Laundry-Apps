import { CustomerNoteRecord } from './customer-note.select';
import { CustomerNoteCategory } from './utils/customer-note-meta.util';
import { decodeCustomerNote } from './utils/customer-note-meta.util';

export interface CustomerNoteAuthor {
  id: string;
  fullName: string;
  employeeCode: string;
}

export interface CustomerNoteItem {
  id: string;
  customerId: string;
  title: string | null;
  note: string;
  category: CustomerNoteCategory;
  isPinned: boolean;
  createdBy: CustomerNoteAuthor;
  createdAt: Date;
  updatedAt: Date;
}

export interface PaginatedCustomerNotes {
  items: CustomerNoteItem[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export function toCustomerNoteItem(note: CustomerNoteRecord): CustomerNoteItem {
  const decoded = decodeCustomerNote(note.note);

  return {
    id: note.id,
    customerId: note.customerId,
    title: decoded.meta.title,
    note: decoded.body,
    category: decoded.meta.category,
    isPinned: decoded.meta.isPinned,
    createdBy: {
      id: note.employee.id,
      fullName: note.employee.fullName,
      employeeCode: note.employee.employeeCode,
    },
    createdAt: note.createdAt,
    updatedAt: note.updatedAt,
  };
}
