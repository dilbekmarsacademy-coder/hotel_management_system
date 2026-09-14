import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class HotelSettingsScreen extends ConsumerStatefulWidget {
  const HotelSettingsScreen({super.key});

  @override
  ConsumerState<HotelSettingsScreen> createState() => _HotelSettingsScreenState();
}

class _HotelSettingsScreenState extends ConsumerState<HotelSettingsScreen> {
  final _nameCtrl = TextEditingController(text: AppConstants.hotelName);
  final _addressCtrl = TextEditingController(text: AppConstants.hotelAddress);
  final _phoneCtrl = TextEditingController(text: AppConstants.hotelPhone);
  final _emailCtrl = TextEditingController(text: AppConstants.hotelEmail);
  final _checkInCtrl = TextEditingController(text: AppConstants.defaultCheckInTime);
  final _checkOutCtrl = TextEditingController(text: AppConstants.defaultCheckOutTime);
  final _taxCtrl = TextEditingController(text: '${(AppConstants.taxRate * 100).toInt()}');
  final _serviceFeeCtrl = TextEditingController(text: '${(AppConstants.serviceFeeRate * 100).toInt()}');
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _checkInCtrl.dispose();
    _checkOutCtrl.dispose();
    _taxCtrl.dispose();
    _serviceFeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Hotel Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hotel Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Hotel Name')),
          const SizedBox(height: 12),
          TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
          const SizedBox(height: 12),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 24),

          Text('Check-in / Check-out', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _checkInCtrl, decoration: const InputDecoration(labelText: 'Check-in Time'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _checkOutCtrl, decoration: const InputDecoration(labelText: 'Check-out Time'))),
            ],
          ),
          const SizedBox(height: 24),

          Text('Taxes & Fees', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: _taxCtrl, decoration: const InputDecoration(labelText: 'Tax Rate (%)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _serviceFeeCtrl, decoration: const InputDecoration(labelText: 'Service Fee (%)'), keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 24),

          Text('Currency', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Row(
              children: [
                Text('${AppConstants.currencyCode} (${AppConstants.currencySymbol})', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text('Default', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Save Settings'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
