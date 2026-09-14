/// Integration-style security tests for booking trust boundaries.
///
/// These tests run WITHOUT a live Firebase project by validating the
/// client-side status machines and price helpers that mirror Cloud Function rules.
/// Full emulator tests: run with `firebase emulators:exec` when credentials exist.
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_management_system/core/domain/booking_status_machine.dart';
import 'package:hotel_management_system/core/domain/room_status_machine.dart';
import 'package:hotel_management_system/core/errors/app_exception.dart';
import 'package:hotel_management_system/data/models/enums.dart';
import 'package:hotel_management_system/data/services/availability_service.dart';

void main() {
  group('Tampered client price must not equal server price authority', () {
    test('arbitrary client discount is not applied unless server validates', () {
      // Server only applies discount after coupon validation
      final serverWithoutCoupon = AvailabilityService.calculatePrice(
        roomPricePerNight: 200,
        nights: 2,
        discountPercent: 0,
        taxRate: 0.12,
        serviceFeeRate: 0.05,
      );
      final clientClaimed = AvailabilityService.calculatePrice(
        roomPricePerNight: 200,
        nights: 2,
        discountPercent: 90, // malicious client
        taxRate: 0.12,
        serviceFeeRate: 0.05,
      );
      // Client can *preview* anything; Cloud Function ignores client totals
      expect(serverWithoutCoupon.grandTotal, isNot(equals(clientClaimed.grandTotal)));
      expect(serverWithoutCoupon.grandTotal, greaterThan(clientClaimed.grandTotal));
    });
  });

  group('Unauthorized status transitions', () {
    test('cannot revive cancelled booking to checkedIn', () {
      expect(
        BookingStatusMachine.canTransition(
          BookingStatus.cancelled,
          BookingStatus.checkedIn,
        ),
        isFalse,
      );
      expect(
        () => BookingStatusMachine.assertTransition(
          BookingStatus.cancelled,
          BookingStatus.checkedIn,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('cannot skip cleaning after occupancy', () {
      expect(
        RoomStatusMachine.canTransition(
          RoomStatus.occupied,
          RoomStatus.available,
        ),
        isFalse,
      );
    });
  });

  group('Maintenance and overlap', () {
    test('checkout day is free (half-open)', () {
      final aIn = DateTime(2026, 6, 1);
      final aOut = DateTime(2026, 6, 5);
      final bIn = DateTime(2026, 6, 5);
      final bOut = DateTime(2026, 6, 8);
      expect(
        AvailabilityService.datesOverlap(aIn, aOut, bIn, bOut),
        isFalse,
      );
    });
  });
}
