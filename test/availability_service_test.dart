import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_management_system/data/services/availability_service.dart';
import 'package:hotel_management_system/data/models/booking_model.dart';
import 'package:hotel_management_system/data/models/room_model.dart';
import 'package:hotel_management_system/data/models/enums.dart';

void main() {
  group('AvailabilityService.datesOverlap', () {
    test('overlapping ranges return true', () {
      final aStart = DateTime(2026, 6, 1);
      final aEnd = DateTime(2026, 6, 5);
      final bStart = DateTime(2026, 6, 3);
      final bEnd = DateTime(2026, 6, 7);
      expect(AvailabilityService.datesOverlap(aStart, aEnd, bStart, bEnd), isTrue);
    });

    test('adjacent ranges (checkout = checkin) do NOT overlap', () {
      final aStart = DateTime(2026, 6, 1);
      final aEnd = DateTime(2026, 6, 5);
      final bStart = DateTime(2026, 6, 5);
      final bEnd = DateTime(2026, 6, 8);
      expect(AvailabilityService.datesOverlap(aStart, aEnd, bStart, bEnd), isFalse);
    });

    test('non-overlapping ranges return false', () {
      final aStart = DateTime(2026, 6, 1);
      final aEnd = DateTime(2026, 6, 5);
      final bStart = DateTime(2026, 6, 10);
      final bEnd = DateTime(2026, 6, 12);
      expect(AvailabilityService.datesOverlap(aStart, aEnd, bStart, bEnd), isFalse);
    });
  });

  group('AvailabilityService.numberOfNights', () {
    test('calculates nights correctly', () {
      expect(
        AvailabilityService.numberOfNights(DateTime(2026, 6, 1), DateTime(2026, 6, 4)),
        3,
      );
    });

    test('minimum 1 night', () {
      expect(
        AvailabilityService.numberOfNights(DateTime(2026, 6, 1), DateTime(2026, 6, 1)),
        1,
      );
    });
  });

  group('AvailabilityService.calculatePrice', () {
    test('room + tax + service fee', () {
      final price = AvailabilityService.calculatePrice(
        roomPricePerNight: 200,
        nights: 3,
        taxRate: 0.10,
        serviceFeeRate: 0.05,
      );
      expect(price.roomCharges, 600);
      expect(price.subtotal, 600);
      expect(price.tax, 60);
      expect(price.serviceFee, 30);
      expect(price.grandTotal, 690);
    });

    test('applies percent discount before tax', () {
      final price = AvailabilityService.calculatePrice(
        roomPricePerNight: 100,
        nights: 2,
        discountPercent: 10,
        taxRate: 0.10,
        serviceFeeRate: 0,
      );
      // subtotal 200, discount 20, taxable 180, tax 18 → 198
      expect(price.discount, 20);
      expect(price.grandTotal, closeTo(198, 0.01));
    });
  });

  group('AvailabilityService.isRoomAvailable', () {
    final room = RoomModel(
      id: 'r1',
      roomNumber: '101',
      name: 'Test Room',
      type: RoomType.standard,
      description: 'Test',
      pricePerNight: 150,
      capacity: 2,
      floor: 1,
      bedType: BedType.queen,
      status: RoomStatus.available,
      isAvailable: true,
      amenities: const [],
      sizeSqm: 30,
      imageUrls: const [],
      rating: 4.5,
      reviewCount: 10,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    BookingModel booking({
      required DateTime checkIn,
      required DateTime checkOut,
      BookingStatus status = BookingStatus.confirmed,
    }) {
      return BookingModel(
        id: 'b1',
        bookingCode: 'TEST001',
        guestId: 'g1',
        guestName: 'Guest',
        guestEmail: 'g@test.com',
        roomId: 'r1',
        roomName: 'Test Room',
        roomNumber: '101',
        checkIn: checkIn,
        checkOut: checkOut,
        numberOfGuests: 1,
        numberOfNights: checkOut.difference(checkIn).inDays,
        roomPrice: 150,
        taxes: 0,
        serviceFee: 0,
        discount: 0,
        totalPrice: 150,
        status: status,
        paymentStatus: PaymentStatus.completed,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
    }

    test('blocks overlapping confirmed booking', () {
      final available = AvailabilityService.isRoomAvailable(
        room: room,
        checkIn: DateTime(2026, 7, 2),
        checkOut: DateTime(2026, 7, 5),
        existingBookings: [
          booking(checkIn: DateTime(2026, 7, 1), checkOut: DateTime(2026, 7, 4)),
        ],
      );
      expect(available, isFalse);
    });

    test('allows booking starting on previous checkout day', () {
      final available = AvailabilityService.isRoomAvailable(
        room: room,
        checkIn: DateTime(2026, 7, 4),
        checkOut: DateTime(2026, 7, 7),
        existingBookings: [
          booking(checkIn: DateTime(2026, 7, 1), checkOut: DateTime(2026, 7, 4)),
        ],
      );
      expect(available, isTrue);
    });

    test('ignores cancelled bookings', () {
      final available = AvailabilityService.isRoomAvailable(
        room: room,
        checkIn: DateTime(2026, 7, 2),
        checkOut: DateTime(2026, 7, 5),
        existingBookings: [
          booking(
            checkIn: DateTime(2026, 7, 1),
            checkOut: DateTime(2026, 7, 4),
            status: BookingStatus.cancelled,
          ),
        ],
      );
      expect(available, isTrue);
    });

    test('blocks maintenance rooms', () {
      final maintRoom = room.copyWith(status: RoomStatus.maintenance);
      final available = AvailabilityService.isRoomAvailable(
        room: maintRoom,
        checkIn: DateTime(2026, 8, 1),
        checkOut: DateTime(2026, 8, 3),
        existingBookings: const [],
      );
      expect(available, isFalse);
    });
  });
}
