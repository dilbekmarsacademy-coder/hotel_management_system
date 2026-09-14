import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment_model.dart';
import '../../models/enums.dart';
import '../../converters/firestore_converters.dart';
import '../../../core/errors/app_exception.dart';

abstract class PaymentRepository {
  Future<List<PaymentModel>> getAll();
  Future<PaymentModel?> getById(String id);
  Future<List<PaymentModel>> getByBooking(String bookingId);
  Future<List<PaymentModel>> getByGuest(String guestId);
  Future<PaymentModel> create(PaymentModel payment);
  Future<PaymentModel> updateStatus(String id, PaymentStatus status);
  Future<PaymentModel> markRefunded(String id, {String? notes});
}

class DummyPaymentRepository implements PaymentRepository {
  final List<PaymentModel> _items = [];

  @override
  Future<List<PaymentModel>> getAll() async => List.from(_items);

  @override
  Future<PaymentModel?> getById(String id) async {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PaymentModel>> getByBooking(String bookingId) async =>
      _items.where((p) => p.bookingId == bookingId).toList();

  @override
  Future<List<PaymentModel>> getByGuest(String guestId) async =>
      _items.where((p) => p.guestId == guestId).toList();

  @override
  Future<PaymentModel> create(PaymentModel payment) async {
    _items.add(payment);
    return payment;
  }

  @override
  Future<PaymentModel> updateStatus(String id, PaymentStatus status) async {
    final i = _items.indexWhere((p) => p.id == id);
    if (i < 0) throw const AppException('Payment not found');
    final updated = PaymentModel(
      id: _items[i].id,
      transactionId: _items[i].transactionId,
      bookingId: _items[i].bookingId,
      guestId: _items[i].guestId,
      guestName: _items[i].guestName,
      amount: _items[i].amount,
      method: _items[i].method,
      status: status,
      notes: _items[i].notes,
      createdAt: _items[i].createdAt,
      completedAt: status == PaymentStatus.completed ? DateTime.now() : null,
    );
    _items[i] = updated;
    return updated;
  }

  @override
  Future<PaymentModel> markRefunded(String id, {String? notes}) async {
    return updateStatus(id, PaymentStatus.refunded);
  }
}

class FirebasePaymentRepository implements PaymentRepository {
  FirebasePaymentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _uuid = const Uuid();
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('payments');

  PaymentModel _from(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = Fs.withId(doc);
    return PaymentModel(
      id: Fs.stringRequired(m['id']),
      transactionId: Fs.stringRequired(m['transactionId']),
      bookingId: Fs.stringRequired(m['bookingId']),
      guestId: Fs.stringRequired(m['guestId']),
      guestName: Fs.stringRequired(m['guestName']),
      amount: Fs.doubleVal(m['amount']),
      method: Fs.enumByName(
        PaymentMethod.values,
        m['method'],
        fallback: PaymentMethod.creditCard,
      ),
      status: Fs.enumByName(
        PaymentStatus.values,
        m['status'],
        fallback: PaymentStatus.pending,
      ),
      notes: Fs.string(m['notes']),
      createdAt: Fs.dateTimeRequired(m['createdAt']),
      completedAt: Fs.dateTime(m['completedAt']),
    );
  }

  @override
  Future<List<PaymentModel>> getAll() async {
    try {
      final snap = await _col.orderBy('createdAt', descending: true).get();
      return snap.docs.map(_from).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<PaymentModel?> getById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists) return null;
      return _from(doc);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<PaymentModel>> getByBooking(String bookingId) async {
    try {
      final snap = await _col.where('bookingId', isEqualTo: bookingId).get();
      return snap.docs.map(_from).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<PaymentModel>> getByGuest(String guestId) async {
    try {
      final snap = await _col.where('guestId', isEqualTo: guestId).get();
      return snap.docs.map(_from).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<PaymentModel> create(PaymentModel payment) async {
    try {
      final id = payment.id.isEmpty ? _uuid.v4() : payment.id;
      final tx = payment.transactionId.isEmpty
          ? 'TXN${DateTime.now().millisecondsSinceEpoch}'
          : payment.transactionId;
      await _col.doc(id).set({
        'transactionId': tx,
        'bookingId': payment.bookingId,
        'guestId': payment.guestId,
        'guestName': payment.guestName,
        'amount': payment.amount,
        'method': payment.method.name,
        'status': payment.status.name,
        'notes': payment.notes,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': payment.status == PaymentStatus.completed
            ? FieldValue.serverTimestamp()
            : null,
      });
      return payment.copyWith(id: id, transactionId: tx);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<PaymentModel> updateStatus(String id, PaymentStatus status) async {
    // Never allow client to set Paid without a verified payment provider callback.
    // Reception/Admin only (rules-enforced).
    try {
      final data = <String, dynamic>{
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (status == PaymentStatus.completed) {
        data['completedAt'] = FieldValue.serverTimestamp();
      }
      await _col.doc(id).update(data);
      final doc = await _col.doc(id).get();
      return _from(doc);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<PaymentModel> markRefunded(String id, {String? notes}) async {
    try {
      await _col.doc(id).update({
        'status': PaymentStatus.refunded.name,
        if (notes != null) 'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final doc = await _col.doc(id).get();
      return _from(doc);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }
}
