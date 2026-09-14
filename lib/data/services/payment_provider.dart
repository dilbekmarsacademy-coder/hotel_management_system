import '../models/enums.dart';

/// Abstract payment gateway. Real Stripe/etc. can implement this later.
/// Never set PaymentStatus.completed from the client without a trusted
/// provider callback or staff-verified cash/card terminal result.
abstract class PaymentProvider {
  Future<PaymentIntentResult> createIntent({
    required double amount,
    required String currency,
    required String bookingId,
    required String guestId,
    Map<String, dynamic>? metadata,
  });

  Future<PaymentConfirmResult> confirmPayment({
    required String intentId,
    required PaymentMethod method,
  });

  Future<PaymentConfirmResult> refund({
    required String transactionId,
    required double amount,
  });
}

class PaymentIntentResult {
  final bool success;
  final String? intentId;
  final String? clientSecret;
  final String? errorMessage;

  const PaymentIntentResult({
    required this.success,
    this.intentId,
    this.clientSecret,
    this.errorMessage,
  });
}

class PaymentConfirmResult {
  final bool success;
  final String? transactionId;
  final PaymentStatus status;
  final String? errorMessage;

  const PaymentConfirmResult({
    required this.success,
    this.transactionId,
    this.status = PaymentStatus.pending,
    this.errorMessage,
  });
}

/// Demo / mock provider – simulates success after short delay.
/// Does NOT write Firestore payment status as Paid by itself;
/// callers still go through PaymentRepository with staff/trusted path.
class MockPaymentProvider implements PaymentProvider {
  @override
  Future<PaymentIntentResult> createIntent({
    required double amount,
    required String currency,
    required String bookingId,
    required String guestId,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (amount <= 0) {
      return const PaymentIntentResult(
        success: false,
        errorMessage: 'Invalid amount',
      );
    }
    return PaymentIntentResult(
      success: true,
      intentId: 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
      clientSecret: 'mock_secret',
    );
  }

  @override
  Future<PaymentConfirmResult> confirmPayment({
    required String intentId,
    required PaymentMethod method,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return PaymentConfirmResult(
      success: true,
      transactionId: 'txn_mock_${DateTime.now().millisecondsSinceEpoch}',
      status: PaymentStatus.completed,
    );
  }

  @override
  Future<PaymentConfirmResult> refund({
    required String transactionId,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PaymentConfirmResult(
      success: true,
      transactionId: transactionId,
      status: PaymentStatus.refunded,
    );
  }
}
