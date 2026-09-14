import 'package:equatable/equatable.dart';
import 'enums.dart';

enum MaintenanceStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.assigned:
        return 'Assigned';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class MaintenanceRequestModel extends Equatable {
  final String id;
  final String roomId;
  final String roomNumber;
  final String title;
  final String description;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final MaintenanceStatus status;
  final TaskPriority priority;
  final double? estimatedCost;
  final double? actualCost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const MaintenanceRequestModel({
    required this.id,
    required this.roomId,
    required this.roomNumber,
    required this.title,
    required this.description,
    this.assignedStaffId,
    this.assignedStaffName,
    this.status = MaintenanceStatus.pending,
    this.priority = TaskPriority.medium,
    this.estimatedCost,
    this.actualCost,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  MaintenanceRequestModel copyWith({
    String? id,
    String? roomId,
    String? roomNumber,
    String? title,
    String? description,
    String? assignedStaffId,
    String? assignedStaffName,
    MaintenanceStatus? status,
    TaskPriority? priority,
    double? estimatedCost,
    double? actualCost,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return MaintenanceRequestModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomNumber: roomNumber ?? this.roomNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomId': roomId,
        'roomNumber': roomNumber,
        'title': title,
        'description': description,
        'assignedStaffId': assignedStaffId,
        'assignedStaffName': assignedStaffName,
        'status': status.name,
        'priority': priority.name,
        'estimatedCost': estimatedCost,
        'actualCost': actualCost,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequestModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      roomNumber: json['roomNumber'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      assignedStaffId: json['assignedStaffId'] as String?,
      assignedStaffName: json['assignedStaffName'] as String?,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MaintenanceStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      actualCost: (json['actualCost'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id, roomId, roomNumber, title, description, assignedStaffId,
        assignedStaffName, status, priority, estimatedCost, actualCost,
        createdAt, updatedAt, completedAt,
      ];
}
