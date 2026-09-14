import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';

class RestaurantAnalyticsScreen extends ConsumerWidget {
  const RestaurantAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = DummyData.menuItems;
    final available = items.where((i) => i.isAvailable).length;
    final avgPrice = items.isEmpty ? 0.0 : items.fold<double>(0, (s, i) => s + i.price) / items.length;
    final categories = items.map((i) => i.category).toSet();
    final byCat = <String, int>{};
    for (final i in items) {
      byCat[i.category] = (byCat[i.category] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Restaurant Analytics')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          _Card('Menu Items', '${items.length}', AppColors.primary),
          const SizedBox(width: 8),
          _Card('Available', '$available', AppColors.success),
          const SizedBox(width: 8),
          _Card('Categories', '${categories.length}', AppColors.info),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _Card('Avg Price', '\$${avgPrice.toStringAsFixed(0)}', AppColors.secondary),
          const SizedBox(width: 8),
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
        ]),
        const SizedBox(height: 24),
        Text('Items by Category', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...byCat.entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
          child: Row(children: [
            Expanded(child: Text(e.key, style: Theme.of(context).textTheme.titleSmall)),
            Text('${e.value} items', style: Theme.of(context).textTheme.bodySmall),
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
        Text(title, style: Theme.of(context).textTheme.labelSmall, textAlign: TextAlign.center),
      ]),
    ));
  }
}
