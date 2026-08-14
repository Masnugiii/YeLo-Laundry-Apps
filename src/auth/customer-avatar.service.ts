import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { existsSync, mkdirSync, unlinkSync, writeFileSync } from 'fs';
import { extname, join } from 'path';
import { Request } from 'express';
import { CustomerRepository } from '../customer/customer.repository';
import { DEFAULT_MAX_FILE_SIZE_BYTES } from '../settings/types/document-rules.types';
import { OtpService } from './otp/otp.service';
import { UploadedAvatarFile } from './types/uploaded-avatar-file.interface';

const AVATAR_MIME_TYPES = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
]);

const EXTENSION_BY_MIME: Record<string, string> = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

@Injectable()
export class CustomerAvatarService {
  constructor(
    private readonly customerRepository: CustomerRepository,
    private readonly otpService: OtpService,
    private readonly configService: ConfigService,
  ) {}

  async uploadCustomerAvatar(
    customerId: string,
    file: UploadedAvatarFile | undefined,
    request: Request,
  ) {
    if (!file) {
      throw new BadRequestException('Avatar file is required');
    }

    if (!AVATAR_MIME_TYPES.has(file.mimetype)) {
      throw new BadRequestException('Format foto tidak didukung.');
    }

    if (file.size > DEFAULT_MAX_FILE_SIZE_BYTES) {
      throw new BadRequestException('Ukuran foto terlalu besar.');
    }

    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    const uploadDir = join(process.cwd(), 'uploads', 'customer-avatars');
    if (!existsSync(uploadDir)) {
      mkdirSync(uploadDir, { recursive: true });
    }

    const extension =
      EXTENSION_BY_MIME[file.mimetype] ??
      (extname(file.originalname) || '.jpg');
    const fileName = `${customerId}${extension}`;
    const destination = join(uploadDir, fileName);

    if (customer.photoUrl) {
      this.tryDeleteStoredAvatar(customer.photoUrl);
    }

    writeFileSync(destination, file.buffer);

    const apiPrefix = this.configService.get<string>('app.apiPrefix', 'api/v1');
    const host = request.get('host');
    const protocol = request.protocol;
    const photoUrl = `${protocol}://${host}/${apiPrefix}/uploads/customer-avatars/${fileName}`;

    await this.customerRepository.update(customerId, { photoUrl });

    return this.otpService.getCustomerProfile(customerId);
  }

  private tryDeleteStoredAvatar(photoUrl: string) {
    const marker = '/uploads/customer-avatars/';
    const index = photoUrl.indexOf(marker);

    if (index === -1) {
      return;
    }

    const fileName = photoUrl.slice(index + marker.length);
    const filePath = join(process.cwd(), 'uploads', 'customer-avatars', fileName);

    if (existsSync(filePath)) {
      unlinkSync(filePath);
    }
  }
}
