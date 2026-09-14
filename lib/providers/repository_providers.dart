import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_config.dart';
import '../data/repositories/room_repository.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/housekeeping_repository.dart';
import '../data/repositories/firebase/firebase_room_repository.dart';
import '../data/repositories/firebase/firebase_booking_repository.dart';
import '../data/repositories/firebase/firebase_service_repository.dart';
import '../data/repositories/firebase/firebase_restaurant_repository.dart';
import '../data/repositories/firebase/firebase_housekeeping_repository.dart';
import '../data/repositories/firebase/firebase_user_repository.dart';
import '../data/repositories/firebase/firebase_payment_repository.dart';
import '../data/repositories/firebase/firebase_coupon_repository.dart';
import '../data/repositories/firebase/firebase_notification_repository.dart';

bool get _fb => AppConfig.useFirebaseDataEffective;

RoomRepository createRoomRepository() =>
    _fb ? FirebaseRoomRepository() : DummyRoomRepository();

BookingRepository createBookingRepository() =>
    _fb ? FirebaseBookingRepository() : DummyBookingRepository();

ServiceRepository createServiceRepository() =>
    _fb ? FirebaseServiceRepository() : DummyServiceRepository();

RestaurantRepository createRestaurantRepository() =>
    _fb ? FirebaseRestaurantRepository() : DummyRestaurantRepository();

HousekeepingRepository createHousekeepingRepository() =>
    _fb ? FirebaseHousekeepingRepository() : DummyHousekeepingRepository();

UserRepository createUserRepository() =>
    _fb ? FirebaseUserRepository() : DummyUserRepository();

PaymentRepository createPaymentRepository() =>
    _fb ? FirebasePaymentRepository() : DummyPaymentRepository();

FirebaseCouponRepository? createCouponRepository() =>
    _fb ? FirebaseCouponRepository() : null;

FirebaseNotificationRepository? createNotificationRepository() =>
    _fb ? FirebaseNotificationRepository() : null;

final roomRepositoryProvider =
    Provider<RoomRepository>((ref) => createRoomRepository());

final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) => createBookingRepository());

final serviceRepositoryProvider =
    Provider<ServiceRepository>((ref) => createServiceRepository());

final restaurantRepositoryProvider =
    Provider<RestaurantRepository>((ref) => createRestaurantRepository());

final housekeepingRepositoryProvider =
    Provider<HousekeepingRepository>((ref) => createHousekeepingRepository());

final userRepositoryProvider =
    Provider<UserRepository>((ref) => createUserRepository());

final paymentRepositoryProvider =
    Provider<PaymentRepository>((ref) => createPaymentRepository());
