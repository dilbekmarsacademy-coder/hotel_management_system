import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/staff_model.dart';
import '../../../../data/models/enums.dart';

final adminStaffProvider = FutureProvider<List<StaffModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return List.from(DummyData.staff);
});

class AdminStaffListScreen extends ConsumerWidget {
  const AdminStaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(adminStaffProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add staff form')),
              );
            },
          ),
        ],
      ),
      body: staffAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load staff'),
              ElevatedButton(onPressed: () => ref.invalidate(adminStaffProvider), child: const Text('Retry')),
            ],
          ),
        ),
        data: (staff) {
          if (staff.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge_outlined, size: 64, color: AppColors.mediumGrey),
                  const SizedBox(height: 16),
                  Text('No staff members', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminStaffProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: staff.length,
              itemBuilder: (context, index) {
                final s = staff[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(s.firstName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.fullName, style: Theme.of(context).textTheme.titleSmall),
                            Text('${s.position.displayName} • ${s.department}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: s.status == StaffStatus.active
                              ? AppColors.successLight
                              : s.status == StaffStatus.onLeave
                                  ? AppColors.warningLight
                                  : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.status.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: s.status == StaffStatus.active
                                ? AppColors.success
                                : s.status == StaffStatus.onLeave
                                    ? AppColors.warning
                                    : AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
