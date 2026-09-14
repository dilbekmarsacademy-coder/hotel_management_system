import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/housekeeping_task_model.dart';
import '../housekeeping/housekeeping_dashboard_screen.dart';

class HousekeepingAnalyticsScreen extends ConsumerWidget {
  const HousekeepingAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(housekeepingTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Housekeeping Analytics')),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load')),
        data: (tasks) {
          final pending = tasks.where((t) => t.status == HousekeepingTaskStatus.pending).length;
          final inProgress = tasks.where((t) => t.status == HousekeepingTaskStatus.inProgress).length;
          final completed = tasks.where((t) => t.status == HousekeepingTaskStatus.completed || t.status == HousekeepingTaskStatus.inspected).length;
          final completionRate = tasks.isEmpty ? 0.0 : completed / tasks.length * 100;

          return ListView(padding: const EdgeInsets.all(16), children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Text('Completion Rate', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                Text('${completionRate.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              _Card('Total', '${tasks.length}', AppColors.primary),
              const SizedBox(width: 8),
              _Card('Pending', '$pending', AppColors.warning),
              const SizedBox(width: 8),
              _Card('In Progress', '$inProgress', AppColors.info),
              const SizedBox(width: 8),
              _Card('Done', '$completed', AppColors.success),
            ]),
            const SizedBox(height: 24),
            Text('Status Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...HousekeepingTaskStatus.values.map((s) {
              final count = tasks.where((t) => t.status == s).length;
              final pct = tasks.isEmpty ? 0.0 : count / tasks.length;
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
                SizedBox(width: 90, child: Text(s.displayName, style: Theme.of(context).textTheme.bodySmall)),
                Expanded(child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.lightGrey, color: AppColors.secondary, minHeight: 8, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Text('$count', style: Theme.of(context).textTheme.labelMedium),
              ]));
            }),
          ]);
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title, value;
  final Color color;
  const _Card(this.title, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(title, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
      ]),
    ));
  }
}
