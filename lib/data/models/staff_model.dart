import 'package:equatable/equatable.dart';
import 'enums.dart';

class StaffModel extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? photoUrl;
  final UserRole position;
  final StaffStatus status;
  final String department;
  final DateTime hireDate;
  final double salary;
  final List<String> schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StaffModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.position,
    this.status = StaffStatus.active,
    required this.department,
    required this.hireDate,
    this.salary = 0,
    this.schedule = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  StaffModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? photoUrl,
    UserRole? position,
    StaffStatus? status,
    String? department,
    DateTime? hireDate,
    double? salary,
    List<String>? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      position: position ?? this.position,
      status: status ?? this.status,
      department: department ?? this.department,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'position': position.name,
      'status': status.name,
      'department': department,
      'hireDate': hireDate.toIso8601String(),
      'salary': salary,
      'schedule': schedule,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photoUrl'] as String?,
      position: UserRole.values.firstWhere(
        (e) => e.name == json['position'],
        orElse: () => UserRole.receptionist,
      ),
      status: StaffStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StaffStatus.active,
      ),
      department: json['department'] as String,
      hireDate: DateTime.parse(json['hireDate'] as String),
      salary: (json['salary'] as num?)?.toDouble() ?? 0,
      schedule: List<String>.from(json['schedule'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        email,
        phone,
        photoUrl,
        position,
        status,
        department,
        hireDate,
        salary,
        schedule,
        createdAt,
        updatedAt,
      ];
}
