import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_config.dart';
import '../../core/errors/app_exception.dart';
import 'booking_transaction_service.dart';
import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';
import '../repositories/room_repository.dart';

/// Calls the `createBooking` Cloud Function when Firebase data mode is on.
/// Falls back to [BookingTransactionService] in Demo mode.
class CloudBookingClient {
  CloudBookingClient({
    required this.bookingRepository,
    required this.roomRepository,
  });

  final BookingRepository bookingRepository;
  final RoomRepository roomRepository;

  Future<BookingModel> create({
    required BookingModel draft,
    List<String>? serviceIds,
  }) async {
    if (!AppConfig.useFirebaseDataEffective) {
      final local = BookingTransactionService(
        bookingRepository: bookingRepository,
        roomRepository: roomRepository,
      );
      return local.createBookingSafely(draft);
    }

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createBooking');
      final result = await callable.call(<String, dynamic>{
        'roomId': draft.roomId,
        'checkIn': draft.checkIn.toIso8601String(),
        'checkOut': draft.checkOut.toIso8601String(),
        'guestCount': draft.numberOfGuests,
        'guestName': draft.guestName,
        'guestEmail': draft.guestEmail,
        'guestPhone': draft.guestPhone,
        'specialRequests': draft.specialRequests,
        'promoCode': draft.promoCode,
        'serviceIds': serviceIds ?? [],
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['success'] != true) {
        throw const AppException('Booking could not be created');
      }

      final bookingId = data['bookingId'] as String;
      final loaded = await bookingRepository.getBookingById(bookingId);
      if (loaded != null) return loaded;

      // Fallback reconstruct from response
      final pricing = Map<String, dynamic>.from(data['pricing'] as Map? ?? {});
      return draft.copyWith(
        id: bookingId,
        bookingCode: data['bookingCode'] as String? ?? draft.bookingCode,
        totalPrice: (pricing['grandTotal'] as num?)?.toDouble() ?? draft.totalPrice,
        taxes: (pricing['tax'] as num?)?.toDouble() ?? draft.taxes,
        serviceFee: (pricing['serviceFee'] as num?)?.toDouble() ?? draft.serviceFee,
        discount: (pricing['discount'] as num?)?.toDouble() ?? draft.discount,
      );
    } on FirebaseFunctionsException catch (e) {
      if (kDebugMode) debugPrint('[CloudBooking] ${e.code}: ${e.message}');
      throw AppException(
        e.message ?? 'Booking failed',
        code: e.code,
        cause: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Booking failed. Please try again.', cause: e);
    }
  }
}
