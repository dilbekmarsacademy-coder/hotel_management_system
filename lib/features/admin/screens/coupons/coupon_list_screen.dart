import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';

class CouponListScreen extends ConsumerWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = DummyData.coupons;
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Coupons'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add coupon form')));
        })],
      ),
      body: coupons.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.confirmation_number_outlined, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No coupons', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final c = coupons[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(c.code, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.5))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.isActive ? AppColors.successLight : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(c.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.isActive ? AppColors.success : AppColors.darkGrey)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(c.description, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          c.discountType == 'percentage' ? '${c.discountValue.toInt()}% OFF' : '\$${c.discountValue.toInt()} OFF',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                      const Spacer(),
                      Text('${c.usedCount}/${c.usageLimit ?? '∞'} used', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    const SizedBox(height: 4),
                    Text('Valid: ${dateFmt.format(c.startDate)} – ${dateFmt.format(c.endDate)}', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                );
              },
            ),
    );
  }
}
