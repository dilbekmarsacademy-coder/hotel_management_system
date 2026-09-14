import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_management_system/data/services/availability_service.dart';

void main() {
  group('Price calculation production rules', () {
    test('standard 2-night stay', () {
      final p = AvailabilityService.calculatePrice(
        roomPricePerNight: 250,
        nights: 2,
        taxRate: 0.12,
        serviceFeeRate: 0.05,
      );
      expect(p.roomCharges, 500);
      expect(p.tax, closeTo(60, 0.01));
      expect(p.serviceFee, closeTo(25, 0.01));
      expect(p.grandTotal, closeTo(585, 0.01));
    });

    test('with services and restaurant', () {
      final p = AvailabilityService.calculatePrice(
        roomPricePerNight: 100,
        nights: 1,
        servicesTotal: 50,
        restaurantTotal: 30,
        taxRate: 0.10,
        serviceFeeRate: 0,
      );
      expect(p.subtotal, 180);
      expect(p.tax, closeTo(18, 0.01));
      expect(p.grandTotal, closeTo(198, 0.01));
    });

    test('fixed discount reduces taxable base', () {
      final p = AvailabilityService.calculatePrice(
        roomPricePerNight: 200,
        nights: 1,
        discountAmount: 50,
        taxRate: 0.10,
        serviceFeeRate: 0,
      );
      expect(p.discount, 50);
      expect(p.grandTotal, closeTo(165, 0.01)); // (200-50)*1.1
    });
  });
}
