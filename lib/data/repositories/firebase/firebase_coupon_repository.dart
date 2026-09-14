import 'package:cloud_firestore/cloud_firestore.dart';
import '../../converters/firestore_converters.dart';
import '../../../core/errors/app_exception.dart';

class CouponValidationResult {
  final bool valid;
  final String? message;
  final String discountType; // percentage | fixed
  final double discountValue;
  final String? couponId;

  const CouponValidationResult({
    required this.valid,
    this.message,
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.couponId,
  });
}

class FirebaseCouponRepository {
  FirebaseCouponRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('coupons');

  /// Server-trusted validation – never trust client-supplied discount amounts.
  Future<CouponValidationResult> validate({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final snap = await _col
          .where('code', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        return const CouponValidationResult(
          valid: false,
          message: 'Invalid coupon code',
        );
      }

      final doc = snap.docs.first;
      final m = doc.data();

      if (Fs.boolVal(m['active'], fallback: true) == false) {
        return const CouponValidationResult(
          valid: false,
          message: 'This coupon is no longer active',
        );
      }

      final start = Fs.dateTime(m['startDate']);
      final end = Fs.dateTime(m['expiryDate']) ?? Fs.dateTime(m['endDate']);
      final now = DateTime.now();
      if (start != null && now.isBefore(start)) {
        return const CouponValidationResult(
          valid: false,
          message: 'This coupon is not active yet',
        );
      }
      if (end != null && now.isAfter(end)) {
        return const CouponValidationResult(
          valid: false,
          message: 'This coupon has expired',
        );
      }

      final minSpend = Fs.doubleVal(m['minimumSpend']);
      if (orderAmount < minSpend) {
        return CouponValidationResult(
          valid: false,
          message: 'Minimum spend of \$${minSpend.toStringAsFixed(0)} required',
        );
      }

      final limit = m['usageLimit'] as int?;
      final used = Fs.intVal(m['usageCount']);
      if (limit != null && used >= limit) {
        return const CouponValidationResult(
          valid: false,
          message: 'This coupon has reached its usage limit',
        );
      }

      return CouponValidationResult(
        valid: true,
        discountType: Fs.stringRequired(m['discountType'], fallback: 'percentage'),
        discountValue: Fs.doubleVal(m['discountValue']),
        couponId: doc.id,
      );
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  /// Increment usage after successful booking (call inside transaction when possible).
  Future<void> recordUsage(String couponId) async {
    try {
      await _col.doc(couponId).update({
        'usageCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<List<Map<String, dynamic>>> listActive() async {
    try {
      final snap = await _col.where('active', isEqualTo: true).get();
      return snap.docs.map((d) => Fs.withId(d)).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<String> create(Map<String, dynamic> data) async {
    try {
      final ref = _col.doc();
      data['code'] = (data['code'] as String).toUpperCase();
      data['usageCount'] = 0;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
      return ref.id;
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _col.doc(id).update(data);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }
}
