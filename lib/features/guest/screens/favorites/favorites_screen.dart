import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/room_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider);
    final roomsAsync = ref.watch(allRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Favorite Rooms')),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load favorites'),
              ElevatedButton(
                onPressed: () => ref.invalidate(allRoomsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allRooms) {
          final favorites = allRooms.where((r) => favoriteIds.contains(r.id)).toList();

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 72, color: AppColors.mediumGrey),
                  const SizedBox(height: 16),
                  Text('No favorites yet', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tap the heart on any room to save it', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/guest'),
                    child: const Text('Browse Rooms'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final room = favorites[index];
              return GestureDetector(
                onTap: () => context.push('/guest/rooms/${room.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                        child: CachedNetworkImage(
                          imageUrl: room.imageUrls.isNotEmpty ? room.imageUrls.first : AppConstants.placeholderRoomImage,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(room.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 4),
                                  Text('${room.rating.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodySmall),
                                  const Spacer(),
                                  Text('\$${room.pricePerNight.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => context.push('/guest/rooms/${room.id}'),
                                    child: const Text('View'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref.read(favoritesProvider.notifier).toggle(room.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Removed from favorites'), duration: Duration(seconds: 1)),
                                      );
                                    },
                                    child: const Text('Remove', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
