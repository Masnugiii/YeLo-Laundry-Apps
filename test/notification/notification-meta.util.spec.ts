import {
  NOTIFICATION_CUSTOMER_INDEX_PREFIX,
  NOTIFICATION_EMPLOYEE_INDEX_PREFIX,
} from '../../src/notification/constants/notification.constants';
import {
  buildCustomerIndexKey,
  buildEmployeeIndexKey,
  extractNotificationIdFromIndexKey,
} from '../../src/notification/utils/notification-meta.util';

describe('notification-meta.util', () => {
  const notificationId = 'a1e41e97-0e88-4940-81bf-09a0eba08ddd';
  const customerId = '5635a18e-c477-499a-86e6-4513378be8f9';
  const employeeId = 'cf41a552-0177-4ba8-913b-d1544a88ee47';

  it('extracts notification id from customer index keys', () => {
    const key = buildCustomerIndexKey(customerId, notificationId);
    const prefix = `${NOTIFICATION_CUSTOMER_INDEX_PREFIX}${customerId}.`;

    expect(extractNotificationIdFromIndexKey(prefix, key)).toBe(notificationId);
  });

  it('extracts notification id from employee index keys', () => {
    const key = buildEmployeeIndexKey(employeeId, notificationId);
    const prefix = `${NOTIFICATION_EMPLOYEE_INDEX_PREFIX}${employeeId}.`;

    expect(extractNotificationIdFromIndexKey(prefix, key)).toBe(notificationId);
  });
});
