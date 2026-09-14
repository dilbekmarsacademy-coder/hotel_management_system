import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/enums.dart';

final adminPaymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 350));
  return List.from(DummyData.payments);
});

class AdminPaymentDashboard extends ConsumerStatefulWidget {
  const AdminPaymentDashboard({super.key});

  @override
  ConsumerState<AdminPaymentDashboard> createState() => _AdminPaymentDashboardState();
}

class _AdminPaymentDashboardState extends ConsumerState<AdminPaymentDashboard> {
  PaymentStatus? _statusFilter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(adminPaymentsProvider);
    final dateFmt = DateFormat('MMM d, HH:mm');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Payments')),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load payments'),
              ElevatedButton(onPressed: () => ref.invalidate(adminPaymentsProvider), child: const Text('Retry')),
            ],
          ),
        ),
        data: (payments) {
          final totalRevenue = payments.where((p) => p.status == PaymentStatus.completed).fold<double>(0, (s, p) => s + p.amount);
          final pending = payments.where((p) => p.status == PaymentStatus.pending).length;
          final completed = payments.where((p) => p.status == PaymentStatus.completed).length;
          final failed = payments.where((p) => p.status == PaymentStatus.failed).length;

          var filtered = payments;
          if (_statusFilter != null) filtered = filtered.where((p) => p.status == _statusFilter).toList();
          if (_search.isNotEmpty) {
            final q = _search.toLowerCase();
            filtered = filtered.where((p) =>
                p.guestName.toLowerCase().contains(q) ||
                p.transactionId.toLowerCase().contains(q)).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('Total Revenue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text('\$${totalRevenue.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MiniKpi('Completed', '$completed', AppColors.success),
                        const SizedBox(width: 8),
                        _MiniKpi('Pending', '$pending', AppColors.warning),
                        const SizedBox(width: 8),
                        _MiniKpi('Failed', '$failed', AppColors.error),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Search payments...', prefixIcon: Icon(Icons.search), isDense: true),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _FChip('All', _statusFilter == null, () => setState(() => _statusFilter = null)),
                    ...PaymentStatus.values.map((s) => _FChip(s.displayName, _statusFilter == s, () => setState(() => _statusFilter = s))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No payments found'))
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(adminPaymentsProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final p = filtered[index];
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
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.payment, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.guestName, style: Theme.of(context).textTheme.titleSmall),
                                        Text('${p.method.displayName} • ${dateFmt.format(p.createdAt)}', style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('\$${p.amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.secondary)),
                                      Text(p.status.displayName, style: Theme.of(context).textTheme.labelSmall),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniKpi(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _FChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FChip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(label: Text(label, style: const TextStyle(fontSize: 12)), selected: selected, onSelected: (_) => onTap(), selectedColor: AppColors.secondary.withOpacity(0.2)),
    );
  }
}
