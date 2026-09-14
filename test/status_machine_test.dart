import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_management_system/core/domain/booking_status_machine.dart';
import 'package:hotel_management_system/core/domain/room_status_machine.dart';
import 'package:hotel_management_system/data/models/enums.dart';
import 'package:hotel_management_system/core/errors/app_exception.dart';

void main() {
  group('BookingStatusMachine', () {
    test('pending → confirmed allowed', () {
      expect(
        BookingStatusMachine.canTransition(
          BookingStatus.pending,
          BookingStatus.confirmed,
        ),
        isTrue,
      );
    });

    test('checkedOut → checkedIn rejected', () {
      expect(
        BookingStatusMachine.canTransition(
          BookingStatus.checkedOut,
          BookingStatus.checkedIn,
        ),
        isFalse,
      );
    });

    test('cancelled is terminal', () {
      expect(
        BookingStatusMachine.canTransition(
          BookingStatus.cancelled,
          BookingStatus.confirmed,
        ),
        isFalse,
      );
    });

    test('assertTransition throws on invalid', () {
      expect(
        () => BookingStatusMachine.assertTransition(
          BookingStatus.checkedOut,
          BookingStatus.pending,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('implied room status after check-in is occupied', () {
      expect(
        BookingStatusMachine.impliedRoomStatus(BookingStatus.checkedIn),
        RoomStatus.occupied,
      );
    });

    test('implied room status after checkout is cleaning', () {
      expect(
        BookingStatusMachine.impliedRoomStatus(BookingStatus.checkedOut),
        RoomStatus.cleaning,
      );
    });
  });

  group('RoomStatusMachine', () {
    test('available → reserved allowed', () {
      expect(
        RoomStatusMachine.canTransition(
          RoomStatus.available,
          RoomStatus.reserved,
        ),
        isTrue,
      );
    });

    test('occupied → available rejected (must go via cleaning)', () {
      expect(
        RoomStatusMachine.canTransition(
          RoomStatus.occupied,
          RoomStatus.available,
        ),
        isFalse,
      );
    });

    test('after housekeeping with maintenance stays maintenance', () {
      final next = RoomStatusMachine.afterHousekeepingComplete(
        current: RoomStatus.cleaning,
        hasActiveMaintenance: true,
      );
      expect(next, RoomStatus.maintenance);
    });

    test('after housekeeping without maintenance becomes available', () {
      final next = RoomStatusMachine.afterHousekeepingComplete(
        current: RoomStatus.cleaning,
        hasActiveMaintenance: false,
      );
      expect(next, RoomStatus.available);
    });

    test('maintenance is not bookable', () {
      expect(RoomStatusMachine.isBookable(RoomStatus.maintenance), isFalse);
      expect(RoomStatusMachine.isBookable(RoomStatus.available), isTrue);
    });
  });
}
