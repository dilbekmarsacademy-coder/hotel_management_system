import '../models/enums.dart';
import '../repositories/firebase/firebase_notification_repository.dart';
import '../../core/constants/app_config.dart';

/// In-app + optional FCM push abstraction.
/// Demo mode only uses local/in-memory style via repository when Firebase is on.
abstract class NotificationService {
  Future<void> notifyBookingConfirmed({
    required String userId,
    required String bookingCode,
    required String roomName,
  });

  Future<void> notifyBookingCancelled({
    required String userId,
    required String bookingCode,
  });

  Future<void> notifyCheckInReminder({
    required String userId,
    required String bookingCode,
  });

  Future<void> notifyOrderUpdate({
    required String userId,
    required String orderId,
    required String status,
  });

  Future<void> notifyPaymentReceived({
    required String userId,
    required double amount,
  });
}

class DemoNotificationService implements NotificationService {
  final List<Map<String, String>> log = [];

  Future<void> _log(String type, String userId, String title) async {
    log.add({'type': type, 'userId': userId, 'title': title});
  }

  @override
  Future<void> notifyBookingConfirmed({
    required String userId,
    required String bookingCode,
    required String roomName,
  }) =>
      _log('bookingConfirmed', userId, 'Booking $bookingCode confirmed for $roomName');

  @override
  Future<void> notifyBookingCancelled({
    required String userId,
    required String bookingCode,
  }) =>
      _log('bookingCancelled', userId, 'Booking $bookingCode cancelled');

  @override
  Future<void> notifyCheckInReminder({
    required String userId,
    required String bookingCode,
  }) =>
      _log('checkIn', userId, 'Check-in reminder for $bookingCode');

  @override
  Future<void> notifyOrderUpdate({
    required String userId,
    required String orderId,
    required String status,
  }) =>
      _log('order', userId, 'Order $orderId is now $status');

  @override
  Future<void> notifyPaymentReceived({
    required String userId,
    required double amount,
  }) =>
      _log('payment', userId, 'Payment of \$${amount.toStringAsFixed(2)} received');
}

class FirestoreNotificationService implements NotificationService {
  FirestoreNotificationService(this._repo);

  final FirebaseNotificationRepository _repo;

  @override
  Future<void> notifyBookingConfirmed({
    required String userId,
    required String bookingCode,
    required String roomName,
  }) {
    return _repo.create(
      userId: userId,
      title: 'Booking Confirmed',
      body: 'Your stay ($bookingCode) for $roomName is confirmed.',
      type: NotificationType.bookingConfirmed,
      data: {'bookingCode': bookingCode},
    );
  }

  @override
  Future<void> notifyBookingCancelled({
    required String userId,
    required String bookingCode,
  }) {
    return _repo.create(
      userId: userId,
      title: 'Booking Cancelled',
      body: 'Booking $bookingCode has been cancelled.',
      type: NotificationType.bookingCancelled,
      data: {'bookingCode': bookingCode},
    );
  }

  @override
  Future<void> notifyCheckInReminder({
    required String userId,
    required String bookingCode,
  }) {
    return _repo.create(
      userId: userId,
      title: 'Check-in Reminder',
      body: 'Your check-in for $bookingCode is coming up.',
      type: NotificationType.checkInReminder,
      data: {'bookingCode': bookingCode},
    );
  }

  @override
  Future<void> notifyOrderUpdate({
    required String userId,
    required String orderId,
    required String status,
  }) {
    return _repo.create(
      userId: userId,
      title: 'Order Update',
      body: 'Your order is now $status.',
      type: NotificationType.orderUpdate,
      data: {'orderId': orderId, 'status': status},
    );
  }

  @override
  Future<void> notifyPaymentReceived({
    required String userId,
    required double amount,
  }) {
    return _repo.create(
      userId: userId,
      title: 'Payment Received',
      body: 'We received \$${amount.toStringAsFixed(2)}.',
      type: NotificationType.paymentReceived,
    );
  }
}

NotificationService createNotificationService() {
  if (AppConfig.useFirebaseDataEffective) {
    return FirestoreNotificationService(FirebaseNotificationRepository());
  }
  return DemoNotificationService();
}
