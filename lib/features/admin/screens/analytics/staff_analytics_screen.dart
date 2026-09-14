import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class StaffAnalyticsScreen extends ConsumerWidget {
  const StaffAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = DummyData.staff;
    final active = staff.where((s) => s.status == StaffStatus.active).length;
    final onLeave = staff.where((s) => s.status == StaffStatus.onLeave).length;
    final byDept = <String, int>{};
    for (final s in staff) {
      byDept[s.department] = (byDept[s.department] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Staff Analytics')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          _Card('Total', '${staff.length}', AppColors.primary),
          const SizedBox(width: 8),
          _Card('Active', '$active', AppColors.success),
          const SizedBox(width: 8),
          _Card('On Leave', '$onLeave', AppColors.warning),
        ]),
        const SizedBox(height: 24),
        Text('By Department', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...byDept.entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
          child: Row(children: [
            Expanded(child: Text(e.key, style: Theme.of(context).textTheme.titleSmall)),
            Text('${e.value}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ]),
        )),
      ]),
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(title, style: Theme.of(context).textTheme.labelSmall),
      ]),
    ));
  }
}
