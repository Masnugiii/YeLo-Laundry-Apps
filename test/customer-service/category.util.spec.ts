import {
  categoryConfidence,
  formatSubject,
  parseCategory,
  stripCategoryPrefix,
} from '../../src/customer-service/utils/category.util';

describe('customer-service category util', () => {
  it('parses category prefix from subject', () => {
    expect(parseCategory('[CS:KOMPLAIN] Baju bernoda')).toBe('KOMPLAIN');
    expect(parseCategory('Tanpa prefix')).toBe('LAINNYA');
  });

  it('strips and formats category prefix', () => {
    expect(stripCategoryPrefix('[CS:ORDER_BARU] Order express')).toBe(
      'Order express',
    );
    expect(formatSubject('TRACKING_ORDER', 'Status laundry')).toBe(
      '[CS:TRACKING_ORDER] Status laundry',
    );
  });

  it('returns confidence based on category detection', () => {
    expect(categoryConfidence('KOMPLAIN')).toBe(85);
    expect(categoryConfidence('LAINNYA')).toBe(0);
  });
});
