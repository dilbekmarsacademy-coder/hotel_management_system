enum UserRole {
  guest,
  admin,
  manager,
  receptionist,
  housekeeping,
  restaurantStaff,
  maintenance;

  String get displayName {
    switch (this) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.housekeeping:
        return 'Housekeeping';
      case UserRole.restaurantStaff:
        return 'Restaurant Staff';
      case UserRole.maintenance:
        return 'Maintenance';
    }
  }
}

enum RoomStatus {
  available,
  reserved,
  occupied,
  cleaning,
  maintenance;

  String get displayName {
    switch (this) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.reserved:
        return 'Reserved';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.cleaning:
        return 'Cleaning';
      case RoomStatus.maintenance:
        return 'Maintenance';
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  checkedOut,
  cancelled,
  noShow;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.checkedOut:
        return 'Checked Out';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  online,
  bankTransfer,
  wallet;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.online:
        return 'Online Payment';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.wallet:
        return 'Digital Wallet';
    }
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  delivering,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum HousekeepingStatus {
  dirty,
  cleaning,
  clean,
  inspected,
  maintenance;

  String get displayName {
    switch (this) {
      case HousekeepingStatus.dirty:
        return 'Dirty';
      case HousekeepingStatus.cleaning:
        return 'Cleaning';
      case HousekeepingStatus.clean:
        return 'Clean';
      case HousekeepingStatus.inspected:
        return 'Inspected';
      case HousekeepingStatus.maintenance:
        return 'Maintenance';
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  paymentReceived,
  checkInReminder,
  checkOutReminder,
  roomReady,
  serviceCompleted,
  orderUpdate,
  specialOffer,
  system;

  String get displayName {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case NotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case NotificationType.paymentReceived:
        return 'Payment Received';
      case NotificationType.checkInReminder:
        return 'Check-in Reminder';
      case NotificationType.checkOutReminder:
        return 'Check-out Reminder';
      case NotificationType.roomReady:
        return 'Room Ready';
      case NotificationType.serviceCompleted:
        return 'Service Completed';
      case NotificationType.orderUpdate:
        return 'Order Update';
      case NotificationType.specialOffer:
        return 'Special Offer';
      case NotificationType.system:
        return 'System';
    }
  }
}

enum StaffStatus {
  active,
  onLeave,
  inactive;

  String get displayName {
    switch (this) {
      case StaffStatus.active:
        return 'Active';
      case StaffStatus.onLeave:
        return 'On Leave';
      case StaffStatus.inactive:
        return 'Inactive';
    }
  }
}

enum RoomType {
  standard,
  deluxe,
  suite,
  presidential,
  family,
  executive;

  String get displayName {
    switch (this) {
      case RoomType.standard:
        return 'Standard';
      case RoomType.deluxe:
        return 'Deluxe';
      case RoomType.suite:
        return 'Suite';
      case RoomType.presidential:
        return 'Presidential Suite';
      case RoomType.family:
        return 'Family Room';
      case RoomType.executive:
        return 'Executive';
    }
  }
}

enum BedType {
  single,
  twin,
  double,
  queen,
  king,
  californiaKing;

  String get displayName {
    switch (this) {
      case BedType.single:
        return 'Single';
      case BedType.twin:
        return 'Twin';
      case BedType.double:
        return 'Double';
      case BedType.queen:
        return 'Queen';
      case BedType.king:
        return 'King';
      case BedType.californiaKing:
        return 'California King';
    }
  }
}
