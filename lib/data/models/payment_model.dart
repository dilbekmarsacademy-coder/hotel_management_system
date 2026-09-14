import 'package:equatable/equatable.dart';
import 'enums.dart';

class PaymentModel extends Equatable {
  final String id;
  final String transactionId;
  final String bookingId;
  final String guestId;
  final String guestName;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  const PaymentModel({
    required this.id,
    required this.transactionId,
    required this.bookingId,
    required this.guestId,
    required this.guestName,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    this.notes,
    required this.createdAt,
    this.completedAt,
  });

  PaymentModel copyWith({
    String? id,
    String? transactionId,
    String? bookingId,
    String? guestId,
    String? guestName,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      bookingId: bookingId ?? this.bookingId,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'bookingId': bookingId,
      'guestId': guestId,
      'guestName': guestName,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      bookingId: json['bookingId'] as String,
      guestId: json['guestId'] as String,
      guestName: json['guestName'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        transactionId,
        bookingId,
        guestId,
        guestName,
        amount,
        method,
        status,
        notes,
        createdAt,
        completedAt,
      ];
}
