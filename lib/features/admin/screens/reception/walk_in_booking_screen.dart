import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/room_providers.dart';

class WalkInBookingScreen extends ConsumerStatefulWidget {
  const WalkInBookingScreen({super.key});

  @override
  ConsumerState<WalkInBookingScreen> createState() => _WalkInBookingScreenState();
}

class _WalkInBookingScreenState extends ConsumerState<WalkInBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 1));
  int _guests = 1;
  String? _selectedRoomId;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a room')));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Walk-in booking created'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Walk-in Booking')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Guest Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email *'), keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Invalid' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          Text('Stay Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Check-in'),
              subtitle: Text(dateFmt.format(_checkIn)),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _checkIn, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setState(() => _checkIn = d);
              },
            )),
            Expanded(child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Check-out'),
              subtitle: Text(dateFmt.format(_checkOut)),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _checkOut, firstDate: _checkIn.add(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setState(() => _checkOut = d);
              },
            )),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Guests: '),
            IconButton(onPressed: _guests > 1 ? () => setState(() => _guests--) : null, icon: const Icon(Icons.remove)),
            Text('$_guests'),
            IconButton(onPressed: () => setState(() => _guests++), icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 20),
          Text('Select Room', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          roomsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Text('Failed to load rooms'),
            data: (rooms) {
              final available = rooms.where((r) => r.status == RoomStatus.available).toList();
              return Column(children: available.take(10).map((r) {
                final selected = _selectedRoomId == r.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRoomId = r.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.secondary.withOpacity(0.1) : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppColors.secondary : AppColors.lightGrey, width: selected ? 2 : 1),
                    ),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r.roomNumber} – ${r.name}', style: Theme.of(context).textTheme.titleSmall),
                        Text('${r.type.displayName} • \$${r.pricePerNight.toStringAsFixed(0)}/night', style: Theme.of(context).textTheme.bodySmall),
                      ])),
                      if (selected) const Icon(Icons.check_circle, color: AppColors.secondary),
                    ]),
                  ),
                );
              }).toList());
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Create Booking'),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}
