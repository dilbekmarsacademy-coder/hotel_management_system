import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';

class PromotionsListScreen extends ConsumerWidget {
  const PromotionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promos = DummyData.promotions;
    final dateFmt = DateFormat('MMM d');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Promotions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/admin/coupons/add'); // promo form reuses coupon admin entry for Demo
            },
          ),
        ],
      ),
      body: promos.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.local_offer_outlined, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No promotions', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promos.length,
              itemBuilder: (context, index) {
                final p = promos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(p.title, style: Theme.of(context).textTheme.titleSmall)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.isActive ? AppColors.successLight : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.isActive ? AppColors.success : AppColors.darkGrey)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(p.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          p.discountType == 'percentage' ? '${p.discountValue.toInt()}% OFF' : '\$${p.discountValue.toInt()} OFF',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                      const Spacer(),
                      Text('${dateFmt.format(p.startDate)} – ${dateFmt.format(p.endDate)}', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    if (p.promoCode != null) ...[
                      const SizedBox(height: 8),
                      Text('Code: ${p.promoCode}', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ]),
                );
              },
            ),
    );
  }
}
