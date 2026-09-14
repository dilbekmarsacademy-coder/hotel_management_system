import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/room_providers.dart';

class CompareRoomsScreen extends ConsumerWidget {
  const CompareRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareIds = ref.watch(compareRoomsProvider);
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Compare Rooms'),
        actions: [
          if (compareIds.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(compareRoomsProvider.notifier).clear(),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load rooms')),
        data: (allRooms) {
          final rooms = allRooms.where((r) => compareIds.contains(r.id)).toList();

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compare_arrows, size: 72, color: AppColors.mediumGrey),
                  const SizedBox(height: 16),
                  Text('No rooms to compare', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Add up to 3 rooms from the room list', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/guest'),
                    child: const Text('Browse Rooms'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rooms.map((room) {
                return Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: room.imageUrls.isNotEmpty ? room.imageUrls.first : AppConstants.placeholderRoomImage,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => ref.read(compareRoomsProvider.notifier).toggle(room.id),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(room.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 2),
                      const SizedBox(height: 12),
                      _CompareRow(label: 'Price', value: '\$${room.pricePerNight.toStringAsFixed(0)}/night'),
                      _CompareRow(label: 'Type', value: room.type.displayName),
                      _CompareRow(label: 'Capacity', value: '${room.capacity} guests'),
                      _CompareRow(label: 'Bed', value: room.bedType.displayName),
                      _CompareRow(label: 'Size', value: '${room.sizeSqm} m²'),
                      _CompareRow(label: 'Floor', value: '${room.floor}'),
                      _CompareRow(label: 'Rating', value: '${room.rating.toStringAsFixed(1)} ★'),
                      _CompareRow(label: 'Available', value: room.isAvailable ? 'Yes' : 'No'),
                      const SizedBox(height: 8),
                      Text('Amenities', style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: room.amenities.take(6).map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(a, style: const TextStyle(fontSize: 10)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/guest/rooms/${room.id}'),
                          child: const Text('View'),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String value;
  const _CompareRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
