import 'package:equatable/equatable.dart';
import 'enums.dart';

enum HousekeepingTaskStatus {
  pending,
  assigned,
  inProgress,
  completed,
  inspected,
  rejected;

  String get displayName {
    switch (this) {
      case HousekeepingTaskStatus.pending:
        return 'Pending';
      case HousekeepingTaskStatus.assigned:
        return 'Assigned';
      case HousekeepingTaskStatus.inProgress:
        return 'In Progress';
      case HousekeepingTaskStatus.completed:
        return 'Completed';
      case HousekeepingTaskStatus.inspected:
        return 'Inspected';
      case HousekeepingTaskStatus.rejected:
        return 'Rejected';
    }
  }
}

class HousekeepingTaskModel extends Equatable {
  final String id;
  final String roomId;
  final String roomNumber;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final HousekeepingTaskStatus status;
  final TaskPriority priority;
  final String? notes;
  final DateTime scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HousekeepingTaskModel({
    required this.id,
    required this.roomId,
    required this.roomNumber,
    this.assignedStaffId,
    this.assignedStaffName,
    this.status = HousekeepingTaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.notes,
    required this.scheduledDate,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  HousekeepingTaskModel copyWith({
    String? id,
    String? roomId,
    String? roomNumber,
    String? assignedStaffId,
    String? assignedStaffName,
    HousekeepingTaskStatus? status,
    TaskPriority? priority,
    String? notes,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HousekeepingTaskModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'roomNumber': roomNumber,
        'assignedStaffId': assignedStaffId,
        'assignedStaffName': assignedStaffName,
        'status': status.name,
        'priority': priority.name,
        'notes': notes,
        'scheduledDate': scheduledDate.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory HousekeepingTaskModel.fromJson(Map<String, dynamic> json) {
    return HousekeepingTaskModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      roomNumber: json['roomNumber'] as String,
      assignedStaffId: json['assignedStaffId'] as String?,
      assignedStaffName: json['assignedStaffName'] as String?,
      status: HousekeepingTaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HousekeepingTaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      notes: json['notes'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id, roomId, roomNumber, assignedStaffId, assignedStaffName,
        status, priority, notes, scheduledDate, startedAt, completedAt,
        createdAt, updatedAt,
      ];
}
