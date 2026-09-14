import '../../data/models/enums.dart';
import '../errors/app_exception.dart';

/// Centralized valid room status transitions.
///
/// Available ──► Reserved ──► Occupied ──► Cleaning ──► Available
///    │                                              ▲
///    └──────────────► Maintenance ──────────────────┘
/// Out of service is represented as Maintenance with operational notes.
class RoomStatusMachine {
  RoomStatusMachine._();

  static const Map<RoomStatus, Set<RoomStatus>> _allowed = {
    RoomStatus.available: {
      RoomStatus.reserved,
      RoomStatus.occupied, // walk-in
      RoomStatus.cleaning,
      RoomStatus.maintenance,
    },
    RoomStatus.reserved: {
      RoomStatus.occupied,
      RoomStatus.available, // cancel
      RoomStatus.maintenance,
    },
    RoomStatus.occupied: {
      RoomStatus.cleaning, // checkout
      RoomStatus.maintenance,
    },
    RoomStatus.cleaning: {
      RoomStatus.available,
      RoomStatus.maintenance,
      RoomStatus.occupied, // rare re-assign
    },
    RoomStatus.maintenance: {
      RoomStatus.available,
      RoomStatus.cleaning,
    },
  };

  static bool canTransition(RoomStatus from, RoomStatus to) {
    if (from == to) return true;
    return _allowed[from]?.contains(to) ?? false;
  }

  static void assertTransition(RoomStatus from, RoomStatus to) {
    if (!canTransition(from, to)) {
      throw AppException(
        'Invalid room status transition: ${from.displayName} → ${to.displayName}',
        code: 'invalid-room-transition',
      );
    }
  }

  static bool isBookable(RoomStatus status) =>
      status == RoomStatus.available || status == RoomStatus.reserved;

  /// After housekeeping completes, only return Available if not blocked.
  static RoomStatus afterHousekeepingComplete({
    required RoomStatus current,
    required bool hasActiveMaintenance,
  }) {
    if (hasActiveMaintenance) return RoomStatus.maintenance;
    if (current == RoomStatus.cleaning || current == RoomStatus.available) {
      return RoomStatus.available;
    }
    return current;
  }
}
