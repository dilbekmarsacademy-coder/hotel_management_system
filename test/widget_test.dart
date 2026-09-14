import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_management_system/core/domain/booking_status_machine.dart';
import 'package:hotel_management_system/data/models/enums.dart';

void main() {
  test('BookingStatusMachine allows pending → confirmed', () {
    expect(
      BookingStatusMachine.canTransition(
        BookingStatus.pending,
        BookingStatus.confirmed,
      ),
      isTrue,
    );
  });
}
