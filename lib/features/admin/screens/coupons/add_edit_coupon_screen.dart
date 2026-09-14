import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class AddEditCouponScreen extends ConsumerStatefulWidget {
  final String? couponId;
  const AddEditCouponScreen({super.key, this.couponId});

  bool get isEditing => couponId != null;

  @override
  ConsumerState<AddEditCouponScreen> createState() => _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends ConsumerState<AddEditCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _minCtrl = TextEditingController(text: '0');
  final _limitCtrl = TextEditingController(text: '100');
  String _discountType = 'percentage';
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 30));
  bool _active = true;
  bool _saving = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _minCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.isEditing ? 'Coupon updated' : 'Coupon created'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy');
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Coupon' : 'Add Coupon')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          TextFormField(
            controller: _codeCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Coupon Code *', hintText: 'e.g. SUMMER25'),
            validator: (v) => v == null || v.trim().length < 3 ? 'Min 3 characters' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _discountType,
            decoration: const InputDecoration(labelText: 'Discount Type'),
            items: const [
              DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
              DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
            ],
            onChanged: (v) => setState(() => _discountType = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _valueCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: _discountType == 'percentage' ? 'Percentage (%)' : 'Amount (\$)'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (double.tryParse(v) == null) return 'Invalid number';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minimum Booking Amount')),
          const SizedBox(height: 12),
          TextFormField(controller: _limitCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Usage Limit')),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Start Date'),
            subtitle: Text(dateFmt.format(_start)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (d != null) setState(() => _start = d);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End Date'),
            subtitle: Text(dateFmt.format(_end)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _end, firstDate: _start, lastDate: DateTime.now().add(const Duration(days: 730)));
              if (d != null) setState(() => _end = d);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            value: _active,
            activeColor: AppColors.secondary,
            onChanged: (v) => setState(() => _active = v),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : Text(widget.isEditing ? 'Update Coupon' : 'Create Coupon'),
            ),
          ),
        ]),
      ),
    );
  }
}
