import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class LoyaltyHistoryScreen extends StatelessWidget {
  const LoyaltyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    final transactions = [
      ('Stay at Deluxe Suite', 450, true, DateTime.now().subtract(const Duration(days: 5))),
      ('Restaurant order', 80, true, DateTime.now().subtract(const Duration(days: 12))),
      ('Redeemed free breakfast', -200, false, DateTime.now().subtract(const Duration(days: 20))),
      ('Stay at Executive Room', 320, true, DateTime.now().subtract(const Duration(days: 35))),
      ('Spa service', 60, true, DateTime.now().subtract(const Duration(days: 40))),
      ('Redeemed room upgrade', -500, false, DateTime.now().subtract(const Duration(days: 50))),
      ('Stay at Presidential Suite', 800, true, DateTime.now().subtract(const Duration(days: 60))),
      ('Welcome bonus', 100, true, DateTime.now().subtract(const Duration(days: 90))),
    ];
    final balance = transactions.fold<int>(0, (s, t) => s + (t.$3 ? t.$2 : -t.$2.abs()));

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Loyalty Points History')),
      body: Column(children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text('Current Balance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
            Text('$balance pts', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final (desc, pts, isEarn, date) = transactions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isEarn ? AppColors.successLight : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(isEarn ? Icons.add : Icons.remove, color: isEarn ? AppColors.success : AppColors.error, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(desc, style: Theme.of(context).textTheme.titleSmall),
                    Text(dateFmt.format(date), style: Theme.of(context).textTheme.bodySmall),
                  ])),
                  Text(
                    '${isEarn ? '+' : '-'}$pts',
                    style: TextStyle(fontWeight: FontWeight.w700, color: isEarn ? AppColors.success : AppColors.error),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
