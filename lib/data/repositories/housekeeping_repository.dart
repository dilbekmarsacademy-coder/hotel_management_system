import 'package:uuid/uuid.dart';
import '../models/housekeeping_task_model.dart';
import '../models/enums.dart';
import '../dummy_data/dummy_data.dart';

abstract class HousekeepingRepository {
  Future<List<HousekeepingTaskModel>> getAllTasks();
  Future<HousekeepingTaskModel?> getTaskById(String id);
  Future<List<HousekeepingTaskModel>> getTasksByStatus(HousekeepingTaskStatus status);
  Future<List<HousekeepingTaskModel>> getTodayTasks();
  Future<HousekeepingTaskModel> createTask(HousekeepingTaskModel task);
  Future<HousekeepingTaskModel> updateTask(HousekeepingTaskModel task);
  Future<bool> deleteTask(String id);
  Future<HousekeepingTaskModel> assignStaff(String taskId, String staffId, String staffName);
  Future<HousekeepingTaskModel> startTask(String taskId);
  Future<HousekeepingTaskModel> completeTask(String taskId);
  Future<HousekeepingTaskModel> inspectTask(String taskId, {bool approved = true});
}

class DummyHousekeepingRepository implements HousekeepingRepository {
  final _uuid = const Uuid();
  late final List<HousekeepingTaskModel> _tasks;

  DummyHousekeepingRepository() {
    final now = DateTime.now();
    _tasks = List.generate(20, (i) {
      final rooms = DummyData.rooms;
      final room = rooms[i % rooms.length];
      final statuses = HousekeepingTaskStatus.values;
      final priorities = TaskPriority.values;
      final staff = DummyData.staff.where((s) => s.position == UserRole.housekeeping).toList();
      final assigned = i % 3 != 0 && staff.isNotEmpty ? staff[i % staff.length] : null;

      return HousekeepingTaskModel(
        id: 'hk_${i + 1}',
        roomId: room.id,
        roomNumber: room.roomNumber,
        assignedStaffId: assigned?.id,
        assignedStaffName: assigned?.fullName,
        status: statuses[i % statuses.length],
        priority: priorities[i % priorities.length],
        notes: i % 4 == 0 ? 'Extra attention needed – checkout room' : null,
        scheduledDate: now.add(Duration(hours: -12 + i * 2)),
        startedAt: i % 3 == 0 ? now.subtract(Duration(hours: 1)) : null,
        completedAt: i % 5 == 0 ? now.subtract(const Duration(minutes: 30)) : null,
        createdAt: now.subtract(Duration(days: 1, hours: i)),
        updatedAt: now.subtract(Duration(hours: i)),
      );
    });
  }

  @override
  Future<List<HousekeepingTaskModel>> getAllTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tasks)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<HousekeepingTaskModel?> getTaskById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<HousekeepingTaskModel>> getTasksByStatus(HousekeepingTaskStatus status) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _tasks.where((t) => t.status == status).toList();
  }

  @override
  Future<List<HousekeepingTaskModel>> getTodayTasks() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    return _tasks.where((t) {
      return t.scheduledDate.year == now.year &&
          t.scheduledDate.month == now.month &&
          t.scheduledDate.day == now.day;
    }).toList();
  }

  @override
  Future<HousekeepingTaskModel> createTask(HousekeepingTaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newTask = task.copyWith(id: _uuid.v4(), createdAt: DateTime.now(), updatedAt: DateTime.now());
    _tasks.insert(0, newTask);
    return newTask;
  }

  @override
  Future<HousekeepingTaskModel> updateTask(HousekeepingTaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) throw Exception('Task not found');
    final updated = task.copyWith(updatedAt: DateTime.now());
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<bool> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _tasks.removeWhere((t) => t.id == id);
    return true;
  }

  @override
  Future<HousekeepingTaskModel> assignStaff(String taskId, String staffId, String staffName) async {
    final task = await getTaskById(taskId);
    if (task == null) throw Exception('Task not found');
    return updateTask(task.copyWith(
      assignedStaffId: staffId,
      assignedStaffName: staffName,
      status: HousekeepingTaskStatus.assigned,
    ));
  }

  @override
  Future<HousekeepingTaskModel> startTask(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) throw Exception('Task not found');
    return updateTask(task.copyWith(
      status: HousekeepingTaskStatus.inProgress,
      startedAt: DateTime.now(),
    ));
  }

  @override
  Future<HousekeepingTaskModel> completeTask(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) throw Exception('Task not found');
    return updateTask(task.copyWith(
      status: HousekeepingTaskStatus.completed,
      completedAt: DateTime.now(),
    ));
  }

  @override
  Future<HousekeepingTaskModel> inspectTask(String taskId, {bool approved = true}) async {
    final task = await getTaskById(taskId);
    if (task == null) throw Exception('Task not found');
    return updateTask(task.copyWith(
      status: approved ? HousekeepingTaskStatus.inspected : HousekeepingTaskStatus.rejected,
    ));
  }
}
