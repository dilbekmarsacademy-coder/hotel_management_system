import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/room_providers.dart';

class AdminRoomListScreen extends ConsumerStatefulWidget {
  const AdminRoomListScreen({super.key});

  @override
  ConsumerState<AdminRoomListScreen> createState() => _AdminRoomListScreenState();
}

class _AdminRoomListScreenState extends ConsumerState<AdminRoomListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  RoomStatus? _statusFilter;
  String _sortBy = 'number';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Room Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/rooms/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by number, name, type...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // Status filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null),
                ),
                ...RoomStatus.values.map((s) => _FilterChip(
                      label: s.displayName,
                      selected: _statusFilter == s,
                      onTap: () => setState(() => _statusFilter = s),
                    )),
              ],
            ),
          ),
          Expanded(
            child: roomsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    const Text('Failed to load rooms'),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(allRoomsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                var filtered = rooms;
                if (_search.isNotEmpty) {
                  final q = _search.toLowerCase();
                  filtered = filtered.where((r) =>
                      r.roomNumber.toLowerCase().contains(q) ||
                      r.name.toLowerCase().contains(q) ||
                      r.type.displayName.toLowerCase().contains(q)).toList();
                }
                if (_statusFilter != null) {
                  filtered = filtered.where((r) => r.status == _statusFilter).toList();
                }
                switch (_sortBy) {
                  case 'price':
                    filtered.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
                    break;
                  case 'rating':
                    filtered.sort((a, b) => b.rating.compareTo(a.rating));
                    break;
                  default:
                    filtered.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hotel_outlined, size: 64, color: AppColors.mediumGrey),
                        const SizedBox(height: 16),
                        Text('No rooms found', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allRoomsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final room = filtered[index];
                      return _AdminRoomTile(
                        room: room,
                        onTap: () => context.push('/admin/rooms/${room.id}'),
                        onStatusChange: (status) async {
                          try {
                            await ref.read(roomRepositoryProvider).updateRoom(
                                  room.copyWith(
                                    status: status,
                                    isAvailable: status == RoomStatus.available,
                                    updatedAt: DateTime.now(),
                                  ),
                                );
                            ref.invalidate(allRoomsProvider);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Room ${room.roomNumber} → ${status.displayName}')),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update room: $e')),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/rooms/add'),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.primary),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.secondary.withOpacity(0.2),
      ),
    );
  }
}

class _AdminRoomTile extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onTap;
  final ValueChanged<RoomStatus> onStatusChange;

  const _AdminRoomTile({
    required this.room,
    required this.onTap,
    required this.onStatusChange,
  });

  Color _statusColor(RoomStatus s) {
    switch (s) {
      case RoomStatus.available:
        return AppColors.available;
      case RoomStatus.occupied:
        return AppColors.occupied;
      case RoomStatus.reserved:
        return AppColors.reserved;
      case RoomStatus.cleaning:
        return AppColors.cleaning;
      case RoomStatus.maintenance:
        return AppColors.maintenance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor(room.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  room.roomNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _statusColor(room.status),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.name, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    '${room.type.displayName} • Floor ${room.floor} • \$${room.pricePerNight.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            PopupMenuButton<RoomStatus>(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(room.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  room.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(room.status),
                  ),
                ),
              ),
              onSelected: onStatusChange,
              itemBuilder: (_) => RoomStatus.values.map((s) {
                return PopupMenuItem(value: s, child: Text(s.displayName));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
