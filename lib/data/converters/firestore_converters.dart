import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized Firestore value conversion helpers.
/// Keep all Timestamp / enum / nullable parsing out of UI code.
class Fs {
  Fs._();

  static DateTime? dateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  static DateTime dateTimeRequired(dynamic value, {DateTime? fallback}) {
    return dateTime(value) ?? fallback ?? DateTime.now();
  }

  static Timestamp? timestamp(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }

  static String? string(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static String stringRequired(dynamic value, {String fallback = ''}) {
    return string(value) ?? fallback;
  }

  static double doubleVal(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  static int intVal(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static bool boolVal(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return fallback;
  }

  static List<String> stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static T enumByName<T extends Enum>(
    List<T> values,
    dynamic raw, {
    required T fallback,
  }) {
    if (raw == null) return fallback;
    final name = raw.toString();
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  /// Merge document id into map for fromJson factories.
  static Map<String, dynamic> withId(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return {...data, 'id': doc.id};
  }

  static Map<String, dynamic> withIdFromData(
    String id,
    Map<String, dynamic> data,
  ) {
    return {...data, 'id': id};
  }
}
