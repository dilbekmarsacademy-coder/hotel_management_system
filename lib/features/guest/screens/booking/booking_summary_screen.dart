import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/booking_providers.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  final _promoCtrl = TextEditingController();
  bool _applyingPromo = false;
  String? _promoMessage;

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _applyingPromo = true;
      _promoMessage = null;
    });
    final ok =
        await ref.read(bookingFlowProvider.notifier).applyPromoCode(code);
    setState(() {
      _applyingPromo = false;
      _promoMessage = ok ? 'Promo applied!' : 'Invalid promo code';
    });
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(bookingFlowProvider);
    final dateFmt = DateFormat('EEE, MMM d, yyyy');

    if (flow.selectedRoom == null ||
        flow.checkIn == null ||
        flow.checkOut == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Missing booking information')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Booking Summary')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Room card
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flow.selectedRoom!.name,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Room ${flow.selectedRoom!.roomNumber} • ${flow.selectedRoom!.type.displayName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dates & Guests
          _SectionCard(
            child: Column(
              children: [
                _RowItem(
                  icon: Icons.login,
                  label: 'Check-in',
                  value: dateFmt.format(flow.checkIn!),
                ),
                const Divider(height: 20),
                _RowItem(
                  icon: Icons.logout,
                  label: 'Check-out',
                  value: dateFmt.format(flow.checkOut!),
                ),
                const Divider(height: 20),
                _RowItem(
                  icon: Icons.nights_stay_outlined,
                  label: 'Nights',
                  value: '${flow.nights}',
                ),
                const Divider(height: 20),
                _RowItem(
                  icon: Icons.people_outline,
                  label: 'Guests',
                  value: '${flow.totalGuests} (${flow.adults} adults${flow.children > 0 ? ', ${flow.children} children' : ''})',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Guest info
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guest', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('${flow.guestFirstName} ${flow.guestLastName}'),
                Text(flow.guestEmail,
                    style: Theme.of(context).textTheme.bodySmall),
                if (flow.guestPhone.isNotEmpty)
                  Text(flow.guestPhone,
                      style: Theme.of(context).textTheme.bodySmall),
                if (flow.specialRequests.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Requests: ${flow.specialRequests}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Promo
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Promo Code',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Enter code (e.g. WELCOME10)',
                          isDense: true,
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _applyingPromo ? null : _applyPromo,
                      child: _applyingPromo
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Apply'),
                    ),
                  ],
                ),
                if (_promoMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _promoMessage!,
                    style: TextStyle(
                      color: _promoMessage!.contains('applied')
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (flow.promoCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      label: Text('${flow.promoCode} (-${flow.promoDiscount.toInt()}%)'),
                      onDeleted: () {
                        ref.read(bookingFlowProvider.notifier).clearPromo();
                        _promoCtrl.clear();
                        setState(() => _promoMessage = null);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Price breakdown
          _SectionCard(
            child: Column(
              children: [
                _PriceRow(
                  label: 'Room (${flow.nights} nights)',
                  value: flow.roomSubtotal,
                ),
                _PriceRow(label: 'Taxes (12%)', value: flow.tax),
                _PriceRow(label: 'Service Fee (5%)', value: flow.serviceFee),
                if (flow.discountAmount > 0)
                  _PriceRow(
                    label: 'Discount',
                    value: -flow.discountAmount,
                    isDiscount: true,
                  ),
                const Divider(height: 24),
                Row(
                  children: [
                    Text('Total',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '\$${flow.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.push('/guest/booking/payment'),
              child: Text('Proceed to Payment • \$${flow.total.toStringAsFixed(2)}'),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: child,
    );
  }
}

class _RowItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RowItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            '${isDiscount ? '-' : ''}\$${value.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDiscount ? AppColors.success : null,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
