import '../../data/models/enums.dart';
import '../errors/app_exception.dart';

/// Centralized valid booking status transitions.
///
/// Pending ──► Confirmed ──► CheckedIn ──► CheckedOut
///    │            │              │
///    └────────────┴──────────────┴──► Cancelled
/// NoShow only from Confirmed / Pending past check-in window.
class BookingStatusMachine {
  BookingStatusMachine._();

  static const Map<BookingStatus, Set<BookingStatus>> _allowed = {
    BookingStatus.pending: {
      BookingStatus.confirmed,
      BookingStatus.cancelled,
      BookingStatus.noShow,
    },
    BookingStatus.confirmed: {
      BookingStatus.checkedIn,
      BookingStatus.cancelled,
      BookingStatus.noShow,
    },
    BookingStatus.checkedIn: {
      BookingStatus.checkedOut,
      // rare operational cancel after check-in (manager only – enforced in rules)
      BookingStatus.cancelled,
    },
    BookingStatus.checkedOut: {}, // terminal
    BookingStatus.cancelled: {}, // terminal
    BookingStatus.noShow: {}, // terminal
  };

  static bool canTransition(BookingStatus from, BookingStatus to) {
    if (from == to) return true;
    return _allowed[from]?.contains(to) ?? false;
  }

  static void assertTransition(BookingStatus from, BookingStatus to) {
    if (!canTransition(from, to)) {
      throw AppException(
        'Invalid booking status transition: ${from.displayName} → ${to.displayName}',
        code: 'invalid-status-transition',
      );
    }
  }

  static bool canCancel(BookingStatus status) =>
      canTransition(status, BookingStatus.cancelled);

  static bool canCheckIn(BookingStatus status) =>
      canTransition(status, BookingStatus.checkedIn);

  static bool canCheckOut(BookingStatus status) =>
      canTransition(status, BookingStatus.checkedOut);

  /// Room status expected after a booking transition.
  static RoomStatus? impliedRoomStatus(BookingStatus bookingStatus) {
    switch (bookingStatus) {
      case BookingStatus.confirmed:
      case BookingStatus.pending:
        return RoomStatus.reserved;
      case BookingStatus.checkedIn:
        return RoomStatus.occupied;
      case BookingStatus.checkedOut:
        return RoomStatus.cleaning;
      case BookingStatus.cancelled:
      case BookingStatus.noShow:
        return RoomStatus.available;
    }
  }
}
