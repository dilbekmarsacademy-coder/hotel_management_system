import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/room_providers.dart';
import '../../../providers/booking_providers.dart';

class RoomDetailsScreen extends ConsumerStatefulWidget {
  final String roomId;

  const RoomDetailsScreen({super.key, required this.roomId});

  @override
  ConsumerState<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends ConsumerState<RoomDetailsScreen> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomByIdProvider(widget.roomId));
    final favorites = ref.watch(favoritesProvider);

    return roomAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load room'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(roomByIdProvider(widget.roomId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (room) {
        if (room == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Room not found')),
          );
        }

        final isFav = favorites.contains(room.id);

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          body: CustomScrollView(
            slivers: [
              // Image gallery
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isFav ? AppColors.error : AppColors.primary,
                      ),
                    ),
                    onPressed: () =>
                        ref.read(favoritesProvider.notifier).toggle(room.id),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_outlined, size: 20),
                    ),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 360,
                          viewportFraction: 1,
                          onPageChanged: (index, _) {
                            setState(() => _currentImage = index);
                          },
                        ),
                        items: (room.imageUrls.isEmpty
                                ? [AppConstants.placeholderRoomImage]
                                : room.imageUrls)
                            .map((url) {
                          return GestureDetector(
                            onTap: () => context.push(
                              '/guest/rooms/${room.id}/gallery',
                              extra: room.imageUrls,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (_, __) => Container(
                                color: AppColors.lightGrey,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            room.imageUrls.length.clamp(1, 10),
                            (i) => Container(
                              width: _currentImage == i ? 20 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: _currentImage == i
                                    ? AppColors.secondary
                                    : AppColors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            '\$${room.pricePerNight.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      Text(
                        'per night',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 18, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            '${room.rating.toStringAsFixed(1)} (${room.reviewCount} reviews)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: room.isAvailable
                                  ? AppColors.successLight
                                  : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              room.isAvailable ? 'Available' : 'Unavailable',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: room.isAvailable
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Quick info
                      Row(
                        children: [
                          _InfoChip(
                              icon: Icons.people_outline,
                              label: '${room.capacity} Guests'),
                          _InfoChip(
                              icon: Icons.king_bed_outlined,
                              label: room.bedType.displayName),
                          _InfoChip(
                              icon: Icons.square_foot,
                              label: '${room.sizeSqm} m²'),
                          _InfoChip(
                              icon: Icons.layers_outlined,
                              label: 'Floor ${room.floor}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        room.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: AppColors.darkGrey,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Amenities',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: room.amenities.map((a) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.lightGrey),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _amenityIcon(a),
                                  size: 18,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(a,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // Check-in info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.login,
                              title: 'Check-in',
                              value: AppConstants.defaultCheckInTime,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.logout,
                              title: 'Check-out',
                              value: AppConstants.defaultCheckOutTime,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.meeting_room_outlined,
                              title: 'Room Number',
                              value: room.roomNumber,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${room.pricePerNight.toStringAsFixed(0)}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    Text(
                      'per night',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: room.isAvailable
                        ? () {
                            ref
                                .read(bookingFlowProvider.notifier)
                                .selectRoom(room);
                            context.push('/guest/booking/dates');
                          }
                        : null,
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _amenityIcon(String name) {
    switch (name.toLowerCase()) {
      case 'wi-fi':
        return Icons.wifi;
      case 'tv':
        return Icons.tv;
      case 'air conditioning':
        return Icons.ac_unit;
      case 'minibar':
        return Icons.local_bar;
      case 'balcony':
        return Icons.balcony;
      case 'jacuzzi':
        return Icons.hot_tub;
      case 'room service':
        return Icons.room_service;
      case 'safe':
        return Icons.lock_outline;
      case 'coffee machine':
        return Icons.coffee;
      default:
        return Icons.check_circle_outline;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}
