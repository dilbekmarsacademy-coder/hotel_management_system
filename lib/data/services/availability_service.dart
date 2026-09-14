import '../models/booking_model.dart';
import '../models/enums.dart';
import '../models/room_model.dart';

/// Production-grade availability & pricing logic.
/// Used by both Dummy and Firebase repositories.
class AvailabilityService {
  /// True if [rangeAStart, rangeAEnd) overlaps [rangeBStart, rangeBEnd).
  /// Standard hotel rule: checkout day is free for new check-in.
  static bool datesOverlap(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    final aS = DateTime(aStart.year, aStart.month, aStart.day);
    final aE = DateTime(aEnd.year, aEnd.month, aEnd.day);
    final bS = DateTime(bStart.year, bStart.month, bStart.day);
    final bE = DateTime(bEnd.year, bEnd.month, bEnd.day);
    return aS.isBefore(bE) && bS.isBefore(aE);
  }

  /// Active booking statuses that block a room.
  static bool isBlockingStatus(BookingStatus status) {
    return status == BookingStatus.pending ||
        status == BookingStatus.confirmed ||
        status == BookingStatus.checkedIn;
  }

  /// Room is bookable for [checkIn, checkOut) if:
  /// - Room is not Out of Service / Maintenance (unless override)
  /// - No overlapping active booking on that room
  static bool isRoomAvailable({
    required RoomModel room,
    required DateTime checkIn,
    required DateTime checkOut,
    required List<BookingModel> existingBookings,
    String? excludeBookingId,
  }) {
    if (checkOut.isBefore(checkIn) || checkOut.isAtSameMomentAs(checkIn)) {
      return false;
    }

    // Structural unavailability
    if (room.status == RoomStatus.maintenance) {
      return false;
    }

    for (final b in existingBookings) {
      if (excludeBookingId != null && b.id == excludeBookingId) continue;
      if (b.roomId != room.id) continue;
      if (!isBlockingStatus(b.status)) continue;
      if (datesOverlap(checkIn, checkOut, b.checkIn, b.checkOut)) {
        return false;
      }
    }
    return true;
  }

  /// Filter rooms available for a date range.
  static List<RoomModel> filterAvailableRooms({
    required List<RoomModel> rooms,
    required DateTime checkIn,
    required DateTime checkOut,
    required List<BookingModel> existingBookings,
  }) {
    return rooms
        .where(
          (r) => isRoomAvailable(
            room: r,
            checkIn: checkIn,
            checkOut: checkOut,
            existingBookings: existingBookings,
          ),
        )
        .toList();
  }

  /// Number of nights between check-in and check-out.
  static int numberOfNights(DateTime checkIn, DateTime checkOut) {
    final a = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final b = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final nights = b.difference(a).inDays;
    return nights < 1 ? 1 : nights;
  }

  /// Full price breakdown.
  static PriceBreakdown calculatePrice({
    required double roomPricePerNight,
    required int nights,
    double servicesTotal = 0,
    double restaurantTotal = 0,
    double taxRate = 0.12,
    double serviceFeeRate = 0.05,
    double discountAmount = 0,
    double discountPercent = 0,
  }) {
    final roomCharges = roomPricePerNight * nights;
    final subtotal = roomCharges + servicesTotal + restaurantTotal;
    final percentDiscount = subtotal * (discountPercent / 100);
    final totalDiscount = discountAmount + percentDiscount;
    final taxable = (subtotal - totalDiscount).clamp(0, double.infinity);
    final tax = taxable * taxRate;
    final serviceFee = taxable * serviceFeeRate;
    final grandTotal = taxable + tax + serviceFee;

    return PriceBreakdown(
      roomCharges: roomCharges,
      servicesTotal: servicesTotal,
      restaurantTotal: restaurantTotal,
      subtotal: subtotal,
      discount: totalDiscount,
      tax: tax,
      serviceFee: serviceFee,
      grandTotal: grandTotal,
      nights: nights,
    );
  }
}

class PriceBreakdown {
  final double roomCharges;
  final double servicesTotal;
  final double restaurantTotal;
  final double subtotal;
  final double discount;
  final double tax;
  final double serviceFee;
  final double grandTotal;
  final int nights;

  const PriceBreakdown({
    required this.roomCharges,
    required this.servicesTotal,
    required this.restaurantTotal,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.serviceFee,
    required this.grandTotal,
    required this.nights,
  });
}
