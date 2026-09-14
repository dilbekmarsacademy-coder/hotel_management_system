import 'package:equatable/equatable.dart';
import 'enums.dart';

class BookingModel extends Equatable {
  final String id;
  final String bookingCode;
  final String guestId;
  final String guestName;
  final String guestEmail;
  final String? guestPhone;
  final String roomId;
  final String roomNumber;
  final String roomName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int numberOfGuests;
  final int numberOfNights;
  final double roomPrice;
  final double taxes;
  final double serviceFee;
  final double discount;
  final double totalPrice;
  final PaymentStatus paymentStatus;
  final BookingStatus status;
  final String? specialRequests;
  final String? promoCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancelledAt;
  final String? cancellationReason;

  const BookingModel({
    required this.id,
    required this.bookingCode,
    required this.guestId,
    required this.guestName,
    required this.guestEmail,
    this.guestPhone,
    required this.roomId,
    required this.roomNumber,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.numberOfGuests,
    required this.numberOfNights,
    required this.roomPrice,
    this.taxes = 0,
    this.serviceFee = 0,
    this.discount = 0,
    required this.totalPrice,
    this.paymentStatus = PaymentStatus.pending,
    this.status = BookingStatus.pending,
    this.specialRequests,
    this.promoCode,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  BookingModel copyWith({
    String? id,
    String? bookingCode,
    String? guestId,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? roomId,
    String? roomNumber,
    String? roomName,
    DateTime? checkIn,
    DateTime? checkOut,
    int? numberOfGuests,
    int? numberOfNights,
    double? roomPrice,
    double? taxes,
    double? serviceFee,
    double? discount,
    double? totalPrice,
    PaymentStatus? paymentStatus,
    BookingStatus? status,
    String? specialRequests,
    String? promoCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancelledAt,
    String? cancellationReason,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingCode: bookingCode ?? this.bookingCode,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      roomName: roomName ?? this.roomName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      numberOfNights: numberOfNights ?? this.numberOfNights,
      roomPrice: roomPrice ?? this.roomPrice,
      taxes: taxes ?? this.taxes,
      serviceFee: serviceFee ?? this.serviceFee,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      promoCode: promoCode ?? this.promoCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingCode': bookingCode,
      'guestId': guestId,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'roomId': roomId,
      'roomNumber': roomNumber,
      'roomName': roomName,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'numberOfNights': numberOfNights,
      'roomPrice': roomPrice,
      'taxes': taxes,
      'serviceFee': serviceFee,
      'discount': discount,
      'totalPrice': totalPrice,
      'paymentStatus': paymentStatus.name,
      'status': status.name,
      'specialRequests': specialRequests,
      'promoCode': promoCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      bookingCode: json['bookingCode'] as String,
      guestId: json['guestId'] as String,
      guestName: json['guestName'] as String,
      guestEmail: json['guestEmail'] as String,
      guestPhone: json['guestPhone'] as String?,
      roomId: json['roomId'] as String,
      roomNumber: json['roomNumber'] as String,
      roomName: json['roomName'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      numberOfGuests: json['numberOfGuests'] as int,
      numberOfNights: json['numberOfNights'] as int,
      roomPrice: (json['roomPrice'] as num).toDouble(),
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0,
      serviceFee: (json['serviceFee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      specialRequests: json['specialRequests'] as String?,
      promoCode: json['promoCode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cancelledAt: json['cancelledAt'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingCode,
        guestId,
        guestName,
        guestEmail,
        guestPhone,
        roomId,
        roomNumber,
        roomName,
        checkIn,
        checkOut,
        numberOfGuests,
        numberOfNights,
        roomPrice,
        taxes,
        serviceFee,
        discount,
        totalPrice,
        paymentStatus,
        status,
        specialRequests,
        promoCode,
        createdAt,
        updatedAt,
        cancelledAt,
        cancellationReason,
      ];
}
