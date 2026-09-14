import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_management_system/data/models/enums.dart';
import '../data/models/booking_model.dart';
import '../data/models/room_model.dart';
import '../data/repositories/booking_repository.dart';
import 'repository_providers.dart';
import '../data/repositories/room_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return createBookingRepository();
});

// Booking flow state
class BookingFlowState {
  final RoomModel? selectedRoom;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int adults;
  final int children;
  final String guestFirstName;
  final String guestLastName;
  final String guestEmail;
  final String guestPhone;
  final String specialRequests;
  final String promoCode;
  final double promoDiscount;
  final List<String> selectedServiceIds;
  final double servicesTotal;
  final String paymentMethod;
  final bool isProcessing;
  final String? error;

  const BookingFlowState({
    this.selectedRoom,
    this.checkIn,
    this.checkOut,
    this.adults = 1,
    this.children = 0,
    this.guestFirstName = '',
    this.guestLastName = '',
    this.guestEmail = '',
    this.guestPhone = '',
    this.specialRequests = '',
    this.promoCode = '',
    this.promoDiscount = 0,
    this.selectedServiceIds = const [],
    this.servicesTotal = 0,
    this.paymentMethod = 'creditCard',
    this.isProcessing = false,
    this.error,
  });

  int get nights {
    if (checkIn == null || checkOut == null) return 0;
    return checkOut!.difference(checkIn!).inDays;
  }

  int get totalGuests => adults + children;

  double get roomSubtotal {
    if (selectedRoom == null || nights == 0) return 0;
    return selectedRoom!.pricePerNight * nights;
  }

  double get tax => roomSubtotal * 0.12;
  double get serviceFee => roomSubtotal * 0.05;
  double get discountAmount => roomSubtotal * (promoDiscount / 100);
  double get total =>
      roomSubtotal + tax + serviceFee + servicesTotal - discountAmount;

  BookingFlowState copyWith({
    RoomModel? selectedRoom,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    String? guestFirstName,
    String? guestLastName,
    String? guestEmail,
    String? guestPhone,
    String? specialRequests,
    String? promoCode,
    double? promoDiscount,
    List<String>? selectedServiceIds,
    double? servicesTotal,
    String? paymentMethod,
    bool? isProcessing,
    String? error,
    bool clearError = false,
    bool clearRoom = false,
  }) {
    return BookingFlowState(
      selectedRoom: clearRoom ? null : (selectedRoom ?? this.selectedRoom),
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      guestFirstName: guestFirstName ?? this.guestFirstName,
      guestLastName: guestLastName ?? this.guestLastName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      specialRequests: specialRequests ?? this.specialRequests,
      promoCode: promoCode ?? this.promoCode,
      promoDiscount: promoDiscount ?? this.promoDiscount,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      servicesTotal: servicesTotal ?? this.servicesTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BookingFlowNotifier extends StateNotifier<BookingFlowState> {
  final BookingRepository _bookingRepo;
  final RoomRepository _roomRepo;

  BookingFlowNotifier(this._bookingRepo, this._roomRepo)
      : super(const BookingFlowState());

  void selectRoom(RoomModel room) {
    state = state.copyWith(selectedRoom: room);
  }

  void setDates(DateTime checkIn, DateTime checkOut) {
    state = state.copyWith(checkIn: checkIn, checkOut: checkOut);
  }

  void setGuests({int? adults, int? children}) {
    state = state.copyWith(
      adults: adults,
      children: children,
    );
  }

  void setGuestInfo({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    state = state.copyWith(
      guestFirstName: firstName,
      guestLastName: lastName,
      guestEmail: email,
      guestPhone: phone,
    );
  }

  void setSpecialRequests(String requests) {
    state = state.copyWith(specialRequests: requests);
  }

  Future<bool> applyPromoCode(String code) async {
    final valid = await _bookingRepo.validatePromoCode(code);
    if (valid) {
      final discount = await _bookingRepo.getPromoDiscount(code);
      state = state.copyWith(promoCode: code, promoDiscount: discount);
      return true;
    }
    state = state.copyWith(error: 'Invalid promo code');
    return false;
  }

  void clearPromo() {
    state = state.copyWith(promoCode: '', promoDiscount: 0);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<bool> checkRoomAvailability() async {
    if (state.selectedRoom == null ||
        state.checkIn == null ||
        state.checkOut == null) {
      return false;
    }
    return _roomRepo.checkAvailability(
      state.selectedRoom!.id,
      state.checkIn!,
      state.checkOut!,
    );
  }

  Future<BookingModel?> submitBooking() async {
    if (state.selectedRoom == null ||
        state.checkIn == null ||
        state.checkOut == null) {
      state = state.copyWith(error: 'Missing required information');
      return null;
    }

    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final available = await checkRoomAvailability();
      if (!available) {
        state = state.copyWith(
          isProcessing: false,
          error: 'Room is no longer available for selected dates',
        );
        return null;
      }

      final booking = BookingModel(
        id: '',
        bookingCode: '',
        guestId: 'guest_1',
        guestName: '${state.guestFirstName} ${state.guestLastName}',
        guestEmail: state.guestEmail,
        guestPhone: state.guestPhone,
        roomId: state.selectedRoom!.id,
        roomNumber: state.selectedRoom!.roomNumber,
        roomName: state.selectedRoom!.name,
        checkIn: state.checkIn!,
        checkOut: state.checkOut!,
        numberOfGuests: state.totalGuests,
        numberOfNights: state.nights,
        roomPrice: state.selectedRoom!.pricePerNight,
        taxes: state.tax,
        serviceFee: state.serviceFee,
        discount: state.discountAmount,
        totalPrice: state.total,
        paymentStatus: PaymentStatus.completed,
        status: BookingStatus.confirmed,
        specialRequests:
            state.specialRequests.isEmpty ? null : state.specialRequests,
        promoCode: state.promoCode.isEmpty ? null : state.promoCode,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _bookingRepo.createBooking(booking);
      state = state.copyWith(isProcessing: false);
      return created;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const BookingFlowState();
  }
}

final bookingFlowProvider =
    StateNotifierProvider<BookingFlowNotifier, BookingFlowState>((ref) {
  return BookingFlowNotifier(
    ref.watch(bookingRepositoryProvider),
    ref.watch(roomRepositoryProvider),
  );
});

final guestBookingsProvider =
    FutureProvider.family<List<BookingModel>, String>((ref, guestId) async {
  return ref.watch(bookingRepositoryProvider).getBookingsByGuest(guestId);
});

final upcomingBookingsProvider =
    FutureProvider.family<List<BookingModel>, String>((ref, guestId) async {
  return ref.watch(bookingRepositoryProvider).getUpcomingBookings(guestId);
});
