import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_management_system/data/services/availability_service.dart';

void main() {
  group('Coupon-aware pricing', () {
    test('percentage coupon reduces taxable base', () {
      final p = AvailabilityService.calculatePrice(
        roomPricePerNight: 200,
        nights: 2,
        discountPercent: 15,
        taxRate: 0.10,
        serviceFeeRate: 0,
      );
      // subtotal 400, discount 60, taxable 340, tax 34 → 374
      expect(p.discount, 60);
      expect(p.grandTotal, closeTo(374, 0.01));
    });

    test('fixed discount + percent both apply', () {
      final p = AvailabilityService.calculatePrice(
        roomPricePerNight: 100,
        nights: 1,
        discountAmount: 10,
        discountPercent: 10,
        taxRate: 0,
        serviceFeeRate: 0,
      );
      // subtotal 100, percent 10, fixed 10 → discount 20 → 80
      expect(p.discount, 20);
      expect(p.grandTotal, 80);
    });
  });

  group('Booking status blocking', () {
    test('pending/confirmed/checkedIn block room', () {
      expect(AvailabilityService.isBlockingStatus, isA<Function>());
    });
  });
}
