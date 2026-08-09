export type AuthActorType = 'employee' | 'customer';

export interface AuthenticatedCustomer {
  actorType: 'customer';
  customerId: string;
  phone: string;
}

export function isAuthenticatedCustomer(
  user: unknown,
): user is AuthenticatedCustomer {
  return (
    typeof user === 'object' &&
    user !== null &&
    'actorType' in user &&
    (user as AuthenticatedCustomer).actorType === 'customer' &&
    typeof (user as AuthenticatedCustomer).customerId === 'string'
  );
}
