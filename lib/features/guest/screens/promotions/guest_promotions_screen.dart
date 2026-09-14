import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';

class GuestPromotionsScreen extends ConsumerWidget {
  const GuestPromotionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promos = DummyData.promotions.where((p) => p.isActive).toList();
    final dateFmt = DateFormat('MMM d');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Promotions & Offers')),
      body: promos.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.local_offer_outlined, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No active promotions', style: Theme.of(context).textTheme.headlineSmall),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promos.length,
              itemBuilder: (context, index) {
                final p = promos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lightGrey)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          p.discountType == 'percentage' ? '${p.discountValue.toInt()}% OFF' : '\$${p.discountValue.toInt()} OFF',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                        ),
                        Text(p.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                      ]),
                    ),
                    Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.description, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('Valid: ${dateFmt.format(p.startDate)} – ${dateFmt.format(p.endDate)}', style: Theme.of(context).textTheme.bodySmall),
                      if (p.promoCode != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.champagne, borderRadius: BorderRadius.circular(8)),
                          child: Text('Code: ${p.promoCode}', style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ),
                      ],
                    ])),
                  ]),
                );
              },
            ),
    );
  }
}
