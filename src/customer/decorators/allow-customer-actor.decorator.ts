import { SetMetadata } from '@nestjs/common';

export const ALLOW_CUSTOMER_ACTOR_KEY = 'allowCustomerActor';

export const AllowCustomerActor = () =>
  SetMetadata(ALLOW_CUSTOMER_ACTOR_KEY, true);
