import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/enums.dart';

class PaymentAnalyticsScreen extends ConsumerWidget {
  const PaymentAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = DummyData.payments;
    final completed = payments.where((p) => p.status == PaymentStatus.completed).toList();
    final total = completed.fold<double>(0, (s, p) => s + p.amount);
    final failed = payments.where((p) => p.status == PaymentStatus.failed).length;
    final successRate = payments.isEmpty ? 0.0 : completed.length / payments.length * 100;

    final byMethod = <PaymentMethod, double>{};
    for (final p in completed) {
      byMethod[p.method] = (byMethod[p.method] ?? 0) + p.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Payment Analytics')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          _Card('Revenue', '\$${total.toStringAsFixed(0)}', AppColors.success),
          const SizedBox(width: 8),
          _Card('Success Rate', '${successRate.toStringAsFixed(0)}%', AppColors.info),
          const SizedBox(width: 8),
          _Card('Failed', '$failed', AppColors.error),
        ]),
        const SizedBox(height: 24),
        Text('By Payment Method', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...byMethod.entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
          child: Row(children: [
            Expanded(child: Text(e.key.displayName, style: Theme.of(context).textTheme.titleSmall)),
            Text('\$${e.value.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
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
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(title, style: Theme.of(context).textTheme.labelSmall),
      ]),
    ));
  }
}
