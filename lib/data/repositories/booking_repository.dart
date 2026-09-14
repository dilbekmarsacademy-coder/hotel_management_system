import 'package:uuid/uuid.dart';
import '../models/booking_model.dart';
import '../models/enums.dart';
import '../dummy_data/dummy_data.dart';
import '../../core/constants/app_constants.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> getAllBookings();
  Future<BookingModel?> getBookingById(String id);
  Future<List<BookingModel>> getBookingsByGuest(String guestId);
  Future<List<BookingModel>> getUpcomingBookings(String guestId);
  Future<List<BookingModel>> getCompletedBookings(String guestId);
  Future<List<BookingModel>> getCancelledBookings(String guestId);
  Future<BookingModel> createBooking(BookingModel booking);
  Future<BookingModel> updateBooking(BookingModel booking);
  Future<bool> cancelBooking(String id, String reason);
  Future<double> calculateTotal({
    required double roomPrice,
    required int nights,
    double servicesTotal = 0,
    double discountPercent = 0,
    String? promoCode,
  });
  Future<bool> validatePromoCode(String code);
  Future<double> getPromoDiscount(String code);
}

class DummyBookingRepository implements BookingRepository {
  final _uuid = const Uuid();
  final List<BookingModel> _localBookings = List.from(DummyData.bookings);

  @override
  Future<List<BookingModel>> getAllBookings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_localBookings);
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _localBookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<BookingModel>> getBookingsByGuest(String guestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _localBookings.where((b) => b.guestId == guestId).toList();
  }

  @override
  Future<List<BookingModel>> getUpcomingBookings(String guestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return _localBookings
        .where((b) =>
            b.guestId == guestId &&
            b.status != BookingStatus.cancelled &&
            b.status != BookingStatus.checkedOut &&
            b.checkIn.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.checkIn.compareTo(b.checkIn));
  }

  @override
  Future<List<BookingModel>> getCompletedBookings(String guestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _localBookings
        .where((b) =>
            b.guestId == guestId && b.status == BookingStatus.checkedOut)
        .toList();
  }

  @override
  Future<List<BookingModel>> getCancelledBookings(String guestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _localBookings
        .where((b) =>
            b.guestId == guestId && b.status == BookingStatus.cancelled)
        .toList();
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newBooking = booking.copyWith(
      id: _uuid.v4(),
      bookingCode: 'GL${10000 + _localBookings.length}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _localBookings.insert(0, newBooking);
    return newBooking;
  }

  @override
  Future<BookingModel> updateBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _localBookings.indexWhere((b) => b.id == booking.id);
    if (index == -1) throw Exception('Booking not found');
    final updated = booking.copyWith(updatedAt: DateTime.now());
    _localBookings[index] = updated;
    return updated;
  }

  @override
  Future<bool> cancelBooking(String id, String reason) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _localBookings.indexWhere((b) => b.id == id);
    if (index == -1) return false;
    _localBookings[index] = _localBookings[index].copyWith(
      status: BookingStatus.cancelled,
      cancelledAt: DateTime.now().toIso8601String(),
      cancellationReason: reason,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  @override
  Future<double> calculateTotal({
    required double roomPrice,
    required int nights,
    double servicesTotal = 0,
    double discountPercent = 0,
    String? promoCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final subtotal = (roomPrice * nights) + servicesTotal;
    final tax = subtotal * AppConstants.taxRate;
    final serviceFee = subtotal * AppConstants.serviceFeeRate;
    double discount = subtotal * (discountPercent / 100);

    if (promoCode != null && promoCode.isNotEmpty) {
      final promoDiscount = await getPromoDiscount(promoCode);
      discount += subtotal * (promoDiscount / 100);
    }

    return subtotal + tax + serviceFee - discount;
  }

  @override
  Future<bool> validatePromoCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final validCodes = ['WELCOME10', 'LUXE15', 'SUMMER20', 'VIP25'];
    return validCodes.contains(code.toUpperCase());
  }

  @override
  Future<double> getPromoDiscount(String code) async {
    await Future.delayed(const Duration(milliseconds: 100));
    switch (code.toUpperCase()) {
      case 'WELCOME10':
        return 10;
      case 'LUXE15':
        return 15;
      case 'SUMMER20':
        return 20;
      case 'VIP25':
        return 25;
      default:
        return 0;
    }
  }
}
