import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/housekeeping_task_model.dart';
import '../../models/enums.dart';
import '../../converters/firestore_converters.dart';
import '../../../core/errors/app_exception.dart';
import '../housekeeping_repository.dart';

class FirebaseHousekeepingRepository implements HousekeepingRepository {
  FirebaseHousekeepingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('housekeepingTasks');
  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('rooms');

  HousekeepingTaskModel _from(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = Fs.withId(doc);
    return HousekeepingTaskModel(
      id: Fs.stringRequired(m['id']),
      roomId: Fs.stringRequired(m['roomId']),
      roomNumber: Fs.stringRequired(m['roomNumber']),
      assignedStaffId: Fs.string(m['assignedStaffId']),
      assignedStaffName: Fs.string(m['assignedStaffName']),
      status: Fs.enumByName(
        HousekeepingTaskStatus.values,
        m['status'],
        fallback: HousekeepingTaskStatus.pending,
      ),
      priority: Fs.enumByName(
        TaskPriority.values,
        m['priority'],
        fallback: TaskPriority.medium,
      ),
      notes: Fs.string(m['notes']),
      scheduledDate: Fs.dateTimeRequired(m['scheduledDate']),
      startedAt: Fs.dateTime(m['startedAt']),
      completedAt: Fs.dateTime(m['completedAt']),
      createdAt: Fs.dateTimeRequired(m['createdAt']),
      updatedAt: Fs.dateTimeRequired(m['updatedAt']),
    );
  }

  Map<String, dynamic> _to(HousekeepingTaskModel t) => {
        'roomId': t.roomId,
        'roomNumber': t.roomNumber,
        'assignedStaffId': t.assignedStaffId,
        'assignedStaffName': t.assignedStaffName,
        'status': t.status.name,
        'priority': t.priority.name,
        'notes': t.notes,
        'scheduledDate': Fs.timestamp(t.scheduledDate),
        'startedAt': Fs.timestamp(t.startedAt),
        'completedAt': Fs.timestamp(t.completedAt),
        'createdAt': Fs.timestamp(t.createdAt),
        'updatedAt': Fs.timestamp(t.updatedAt),
      };

  @override
  Future<List<HousekeepingTaskModel>> getAllTasks() async {
    try {
      final snap = await _tasks.orderBy('createdAt', descending: true).get();
      return snap.docs.map(_from).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<HousekeepingTaskModel?> getTaskById(String id) async {
    try {
      final doc = await _tasks.doc(id).get();
      if (!doc.exists) return null;
      return _from(doc);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<HousekeepingTaskModel>> getTasksByStatus(
    HousekeepingTaskStatus status,
  ) async {
    try {
      final snap = await _tasks.where('status', isEqualTo: status.name).get();
      return snap.docs.map(_from).toList();
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<List<HousekeepingTaskModel>> getTodayTasks() async {
    final all = await getAllTasks();
    final now = DateTime.now();
    return all
        .where((t) =>
            t.scheduledDate.year == now.year &&
            t.scheduledDate.month == now.month &&
            t.scheduledDate.day == now.day)
        .toList();
  }

  @override
  Future<HousekeepingTaskModel> createTask(HousekeepingTaskModel task) async {
    try {
      final id = task.id.isEmpty ? _uuid.v4() : task.id;
      final data = _to(task);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _tasks.doc(id).set(data);
      // Mark room as cleaning when task is created post-checkout
      if (task.roomId.isNotEmpty) {
        await _rooms.doc(task.roomId).update({
          'status': RoomStatus.cleaning.name,
          'isAvailable': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return task.copyWith(id: id);
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<HousekeepingTaskModel> updateTask(HousekeepingTaskModel task) async {
    try {
      final data = _to(task);
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _tasks.doc(task.id).update(data);
      return task;
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<bool> deleteTask(String id) async {
    try {
      await _tasks.doc(id).delete();
      return true;
    } catch (e, st) {
      throw ErrorMapper.map(e, stack: st);
    }
  }

  @override
  Future<HousekeepingTaskModel> assignStaff(
    String taskId,
    String staffId,
    String staffName,
  ) async {
    final task = await getTaskById(taskId);
    if (task == null) throw const AppException('Task not found', code: 'not-found');
    return updateTask(task.copyWith(
      assignedStaffId: staffId,
      assignedStaffName: staffName,
      status: HousekeepingTaskStatus.assigned,
    ));
  }

  @override
  Future<HousekeepingTaskModel> startTask(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) throw const AppException('Task not found', code: 'not-found');
    return updateTask(task.copyWith(
      status: HousekeepingTaskStatus.inProgress,
      startedAt: DateTime.now(),
    ));
  }

  @override
  Future<HousekeepingTaskModel> completeTask(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) throw const AppException('Task not found', code: 'not-found');
    final updated = await updateTask(task.copyWith(
      status: HousekeepingTaskStatus.completed,
      completedAt: DateTime.now(),
    ));
    // Room → available only if not in maintenance
    if (task.roomId.isNotEmpty) {
      final roomDoc = await _rooms.doc(task.roomId).get();
      final status = roomDoc.data()?['status']?.toString();
      if (status != RoomStatus.maintenance.name) {
        await _rooms.doc(task.roomId).update({
          'status': RoomStatus.available.name,
          'isAvailable': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    return updated;
  }

  @override
  Future<HousekeepingTaskModel> inspectTask(
    String taskId, {
    bool approved = true,
  }) async {
    final task = await getTaskById(taskId);
    if (task == null) throw const AppException('Task not found', code: 'not-found');
    return updateTask(task.copyWith(
      status: approved
          ? HousekeepingTaskStatus.inspected
          : HousekeepingTaskStatus.rejected,
    ));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTasks() {
    return _tasks.orderBy('createdAt', descending: true).snapshots();
  }
}
