import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/housekeeping_task_model.dart';
import '../../../../data/repositories/housekeeping_repository.dart';

final housekeepingRepositoryProvider = Provider<HousekeepingRepository>((ref) {
  return DummyHousekeepingRepository();
});

final housekeepingTasksProvider = FutureProvider<List<HousekeepingTaskModel>>((ref) async {
  return ref.watch(housekeepingRepositoryProvider).getAllTasks();
});

class HousekeepingDashboardScreen extends ConsumerStatefulWidget {
  const HousekeepingDashboardScreen({super.key});

  @override
  ConsumerState<HousekeepingDashboardScreen> createState() => _HousekeepingDashboardScreenState();
}

class _HousekeepingDashboardScreenState extends ConsumerState<HousekeepingDashboardScreen> {
  HousekeepingTaskStatus? _filterStatus;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(housekeepingTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Housekeeping'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTaskDialog(context),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load tasks'),
              ElevatedButton(
                onPressed: () => ref.invalidate(housekeepingTasksProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tasks) {
          final pending = tasks.where((t) => t.status == HousekeepingTaskStatus.pending).length;
          final inProgress = tasks.where((t) => t.status == HousekeepingTaskStatus.inProgress).length;
          final completed = tasks.where((t) => t.status == HousekeepingTaskStatus.completed || t.status == HousekeepingTaskStatus.inspected).length;
          final assigned = tasks.where((t) => t.status == HousekeepingTaskStatus.assigned).length;

          var filtered = tasks;
          if (_filterStatus != null) {
            filtered = filtered.where((t) => t.status == _filterStatus).toList();
          }
          if (_search.isNotEmpty) {
            final q = _search.toLowerCase();
            filtered = filtered.where((t) =>
                t.roomNumber.toLowerCase().contains(q) ||
                (t.assignedStaffName ?? '').toLowerCase().contains(q)).toList();
          }

          return Column(
            children: [
              // KPI cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _Kpi(label: 'Pending', value: '$pending', color: AppColors.warning),
                    const SizedBox(width: 8),
                    _Kpi(label: 'Assigned', value: '$assigned', color: AppColors.info),
                    const SizedBox(width: 8),
                    _Kpi(label: 'In Progress', value: '$inProgress', color: AppColors.cleaning),
                    const SizedBox(width: 8),
                    _Kpi(label: 'Done', value: '$completed', color: AppColors.success),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by room or staff...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(height: 8),

              // Status filters
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _StatusChip(
                      label: 'All',
                      selected: _filterStatus == null,
                      onTap: () => setState(() => _filterStatus = null),
                    ),
                    ...HousekeepingTaskStatus.values.map((s) => _StatusChip(
                          label: s.displayName,
                          selected: _filterStatus == s,
                          onTap: () => setState(() => _filterStatus = s),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Task list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cleaning_services_outlined, size: 64, color: AppColors.mediumGrey),
                            const SizedBox(height: 16),
                            Text('No tasks found', style: Theme.of(context).textTheme.headlineSmall),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(housekeepingTasksProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final task = filtered[index];
                            return _TaskCard(
                              task: task,
                              onStart: () => _action(() => ref.read(housekeepingRepositoryProvider).startTask(task.id)),
                              onComplete: () => _action(() => ref.read(housekeepingRepositoryProvider).completeTask(task.id)),
                              onInspect: () => _action(() => ref.read(housekeepingRepositoryProvider).inspectTask(task.id)),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _action(Future<void> Function() action) async {
    try {
      await action();
      ref.invalidate(housekeepingTasksProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showCreateTaskDialog(BuildContext context) {
    final roomCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Cleaning Task'),
        content: TextField(
          controller: roomCtrl,
          decoration: const InputDecoration(labelText: 'Room Number', hintText: 'e.g. 1205'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (roomCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final task = HousekeepingTaskModel(
                id: '',
                roomId: 'room_temp',
                roomNumber: roomCtrl.text.trim(),
                scheduledDate: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await ref.read(housekeepingRepositoryProvider).createTask(task);
              ref.invalidate(housekeepingTasksProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task created'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Kpi({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StatusChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.secondary.withOpacity(0.2),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final HousekeepingTaskModel task;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onInspect;

  const _TaskCard({
    required this.task,
    required this.onStart,
    required this.onComplete,
    required this.onInspect,
  });

  Color _statusColor(HousekeepingTaskStatus s) {
    switch (s) {
      case HousekeepingTaskStatus.pending:
        return AppColors.warning;
      case HousekeepingTaskStatus.assigned:
        return AppColors.info;
      case HousekeepingTaskStatus.inProgress:
        return AppColors.cleaning;
      case HousekeepingTaskStatus.completed:
      case HousekeepingTaskStatus.inspected:
        return AppColors.success;
      case HousekeepingTaskStatus.rejected:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Room ${task.roomNumber}', style: Theme.of(context).textTheme.titleSmall),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(task.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  task.status.displayName,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(task.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (task.assignedStaffName != null)
            Text('Assigned: ${task.assignedStaffName}', style: Theme.of(context).textTheme.bodySmall),
          Text(
            'Priority: ${task.priority.displayName}${task.notes != null ? ' • ${task.notes}' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              if (task.status == HousekeepingTaskStatus.pending || task.status == HousekeepingTaskStatus.assigned)
                _ActionBtn(label: 'Start', color: AppColors.info, onTap: onStart),
              if (task.status == HousekeepingTaskStatus.inProgress)
                _ActionBtn(label: 'Complete', color: AppColors.success, onTap: onComplete),
              if (task.status == HousekeepingTaskStatus.completed)
                _ActionBtn(label: 'Inspect', color: AppColors.primary, onTap: onInspect),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }
}
