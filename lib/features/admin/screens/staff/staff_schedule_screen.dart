import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class StaffScheduleScreen extends ConsumerWidget {
  const StaffScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = DummyData.staff.where((s) => s.status == StaffStatus.active).toList();
    final shifts = ['Morning (6AM–2PM)', 'Afternoon (2PM–10PM)', 'Night (10PM–6AM)'];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Staff Schedule')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staff.length,
        itemBuilder: (context, index) {
          final s = staff[index];
          final shift = shifts[index % shifts.length];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
            child: Row(children: [
              CircleAvatar(radius: 22, backgroundColor: AppColors.primary, child: Text(s.firstName[0], style: const TextStyle(color: Colors.white))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.fullName, style: Theme.of(context).textTheme.titleSmall),
                Text('${s.position.displayName} • ${s.department}', style: Theme.of(context).textTheme.bodySmall),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: Text(shift, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
          );
        },
      ),
    );
  }
}
