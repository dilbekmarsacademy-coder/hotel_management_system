import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/booking_model.dart';
import '../../models/enums.dart';
import '../../services/availability_service.dart';
import '../booking_repository.dart';
import '../../../core/constants/app_constants.dart';

class FirebaseBookingRepository implements BookingRepository {
  FirebaseBookingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  @override
  Future<List<BookingModel>> getAllBookings() async {
    final snap = await _bookings.orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => BookingModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  @override
  Future<BookingModel?> getBookingById(String id) async {
    final doc = await _bookings.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return BookingModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<List<BookingModel>> getBookingsByGuest(String guestId) async {
    final snap = await _bookings.where('guestId', isEqualTo: guestId).get();
    return snap.docs
        .map((d) => BookingModel.fromJson({...d.data(), 'id': d.id}))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<BookingModel>> getUpcomingBookings(String guestId) async {
    final all = await getBookingsByGuest(guestId);
    final now = DateTime.now();
    return all
        .where((b) =>
            b.status != BookingStatus.cancelled &&
            b.status != BookingStatus.checkedOut &&
            b.checkIn.isAfter(now.subtract(const Duration(days: 1))))
        .toList();
  }

  @override
  Future<List<BookingModel>> getCompletedBookings(String guestId) async {
    final all = await getBookingsByGuest(guestId);
    return all.where((b) => b.status == BookingStatus.checkedOut).toList();
  }

  @override
  Future<List<BookingModel>> getCancelledBookings(String guestId) async {
    final all = await getBookingsByGuest(guestId);
    return all.where((b) => b.status == BookingStatus.cancelled).toList();
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final id = booking.id.isEmpty ? _uuid.v4() : booking.id;
    final code = booking.bookingCode.isEmpty
        ? 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : booking.bookingCode;
    final data = booking.copyWith(
      id: id,
      bookingCode: code,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _bookings.doc(id).set(data.toJson());
    return data;
  }

  @override
  Future<BookingModel> updateBooking(BookingModel booking) async {
    final updated = booking.copyWith(updatedAt: DateTime.now());
    await _bookings.doc(booking.id).update(updated.toJson());
    return updated;
  }

  @override
  Future<bool> cancelBooking(String id, String reason) async {
    await _bookings.doc(id).update({
      'status': BookingStatus.cancelled.name,
      'cancellationReason': reason,
      'updatedAt': DateTime.now().toIso8601String(),
    });
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
    double promoExtra = 0;
    if (promoCode != null && promoCode.isNotEmpty) {
      promoExtra = await getPromoDiscount(promoCode);
    }
    final breakdown = AvailabilityService.calculatePrice(
      roomPricePerNight: roomPrice,
      nights: nights,
      servicesTotal: servicesTotal,
      taxRate: AppConstants.taxRate,
      serviceFeeRate: AppConstants.serviceFeeRate,
      discountPercent: discountPercent + promoExtra,
    );
    return breakdown.grandTotal;
  }

  @override
  Future<bool> validatePromoCode(String code) async {
    final snap = await _db
        .collection('coupons')
        .where('code', isEqualTo: code.toUpperCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) {
      // Fallback known codes
      return ['WELCOME10', 'LUXE15', 'SUMMER20', 'VIP25']
          .contains(code.toUpperCase());
    }
    final data = snap.docs.first.data();
    final end = DateTime.tryParse(data['endDate']?.toString() ?? '');
    if (end != null && end.isBefore(DateTime.now())) return false;
    return true;
  }

  @override
  Future<double> getPromoDiscount(String code) async {
    final snap = await _db
        .collection('coupons')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      if (data['discountType'] == 'percentage') {
        return (data['discountValue'] as num?)?.toDouble() ?? 0;
      }
    }
    const map = {
      'WELCOME10': 10.0,
      'LUXE15': 15.0,
      'SUMMER20': 20.0,
      'VIP25': 25.0,
    };
    return map[code.toUpperCase()] ?? 0;
  }
}
