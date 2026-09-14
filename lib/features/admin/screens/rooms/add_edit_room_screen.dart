import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/room_providers.dart';

class AddEditRoomScreen extends ConsumerStatefulWidget {
  final String? roomId;

  const AddEditRoomScreen({super.key, this.roomId});

  bool get isEditing => roomId != null;

  @override
  ConsumerState<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends ConsumerState<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '2');
  final _floorCtrl = TextEditingController(text: '1');
  final _sizeCtrl = TextEditingController(text: '30');

  RoomType _type = RoomType.standard;
  BedType _bedType = BedType.queen;
  RoomStatus _status = RoomStatus.available;
  final List<String> _selectedAmenities = [];
  bool _isFeatured = false;
  bool _isPopular = false;
  bool _saving = false;
  bool _loading = false;

  static const _allAmenities = [
    'Wi-Fi', 'TV', 'Air Conditioning', 'Private Bathroom', 'Minibar',
    'Balcony', 'Jacuzzi', 'Room Service', 'Hair Dryer', 'Safe',
    'Coffee Machine', 'Work Desk', 'Iron', 'Bathrobe', 'Slippers',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadRoom();
  }

  Future<void> _loadRoom() async {
    setState(() => _loading = true);
    final room = await ref.read(roomRepositoryProvider).getRoomById(widget.roomId!);
    if (room != null && mounted) {
      _numberCtrl.text = room.roomNumber;
      _nameCtrl.text = room.name;
      _descCtrl.text = room.description;
      _priceCtrl.text = room.pricePerNight.toStringAsFixed(0);
      _capacityCtrl.text = room.capacity.toString();
      _floorCtrl.text = room.floor.toString();
      _sizeCtrl.text = room.sizeSqm.toString();
      _type = room.type;
      _bedType = room.bedType;
      _status = room.status;
      _selectedAmenities.addAll(room.amenities);
      _isFeatured = room.isFeatured;
      _isPopular = room.isPopular;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _capacityCtrl.dispose();
    _floorCtrl.dispose();
    _sizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final room = RoomModel(
      id: widget.roomId ?? const Uuid().v4(),
      roomNumber: _numberCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      type: _type,
      description: _descCtrl.text.trim(),
      pricePerNight: double.tryParse(_priceCtrl.text) ?? 0,
      capacity: int.tryParse(_capacityCtrl.text) ?? 2,
      floor: int.tryParse(_floorCtrl.text) ?? 1,
      bedType: _bedType,
      status: _status,
      isAvailable: _status == RoomStatus.available,
      amenities: List.from(_selectedAmenities),
      sizeSqm: int.tryParse(_sizeCtrl.text) ?? 30,
      isFeatured: _isFeatured,
      isPopular: _isPopular,
      imageUrls: const [
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
      ],
      rating: 4.5,
      reviewCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final repo = ref.read(roomRepositoryProvider);
      if (widget.isEditing) {
        await repo.updateRoom(room);
      } else {
        await repo.createRoom(room);
      }
      ref.invalidate(allRoomsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? 'Room updated' : 'Room created'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save room: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Room' : 'Add Room'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Basic Info', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberCtrl,
              decoration: const InputDecoration(labelText: 'Room Number *', prefixIcon: Icon(Icons.tag)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Room Name *', prefixIcon: Icon(Icons.hotel)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
            ),
            const SizedBox(height: 20),

            Text('Type & Configuration', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            DropdownButtonFormField<RoomType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Room Type'),
              items: RoomType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BedType>(
              value: _bedType,
              decoration: const InputDecoration(labelText: 'Bed Type'),
              items: BedType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.displayName))).toList(),
              onChanged: (v) => setState(() => _bedType = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RoomStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: RoomStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _floorCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Floor'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price/Night (\$) *', prefixIcon: Icon(Icons.attach_money)),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sizeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Size (m²)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Amenities', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allAmenities.map((a) {
                final selected = _selectedAmenities.contains(a);
                return FilterChip(
                  label: Text(a),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedAmenities.add(a);
                      } else {
                        _selectedAmenities.remove(a);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Featured Room'),
              value: _isFeatured,
              activeColor: AppColors.secondary,
              onChanged: (v) => setState(() => _isFeatured = v),
            ),
            SwitchListTile(
              title: const Text('Popular Room'),
              value: _isPopular,
              activeColor: AppColors.secondary,
              onChanged: (v) => setState(() => _isPopular = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : Text(widget.isEditing ? 'Update Room' : 'Create Room'),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                  onPressed: () => _confirmDelete(context),
                  child: const Text('Delete Room'),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room?'),
        content: Text('Are you sure you want to delete room ${_numberCtrl.text}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.invalidate(allRoomsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room deleted'), backgroundColor: AppColors.success),
              );
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
