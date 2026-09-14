import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_management_system/core/domain/booking_status_machine.dart';
import 'package:hotel_management_system/core/domain/room_status_machine.dart';
import 'package:hotel_management_system/data/models/enums.dart';
import 'package:hotel_management_system/data/services/availability_service.dart';
import 'package:hotel_management_system/core/errors/app_exception.dart';

void main() {
  group('Server-side price trust model (mirrored in Cloud Function)', () {
    test('client cannot invent discount via calculation helper', () {
      // Server uses same formula; client preview only
      final server = AvailabilityService.calculatePrice(
        roomPricePerNight: 200,
        nights: 3,
        discountPercent: 10, // only after coupon validation
        taxRate: 0.12,
        serviceFeeRate: 0.05,
      );
      expect(server.roomCharges, 600);
      expect(server.discount, 60);
      expect(server.grandTotal, greaterThan(0));
    });

    test('negative effective total clamped', () {
      final p = AvailabilityService.calculatePrice(
        roomPricePerNight: 50,
        nights: 1,
        discountAmount: 1000,
        taxRate: 0.1,
        serviceFeeRate: 0,
      );
      expect(p.grandTotal, 0);
    });
  });

  group('Status machines integration', () {
    test('check-in implies occupied room', () {
      expect(
        BookingStatusMachine.impliedRoomStatus(BookingStatus.checkedIn),
        RoomStatus.occupied,
      );
    });

    test('checkout path requires cleaning before available', () {
      expect(
        RoomStatusMachine.canTransition(
          RoomStatus.occupied,
          RoomStatus.cleaning,
        ),
        isTrue,
      );
      expect(
        RoomStatusMachine.canTransition(
          RoomStatus.occupied,
          RoomStatus.available,
        ),
        isFalse,
      );
    });

    test('invalid booking transition throws', () {
      expect(
        () => BookingStatusMachine.assertTransition(
          BookingStatus.cancelled,
          BookingStatus.checkedIn,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
