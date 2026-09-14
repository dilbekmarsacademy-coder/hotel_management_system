import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/room_model.dart';
import '../../../data/models/enums.dart';
import '../../../providers/room_providers.dart';

class RoomListScreen extends ConsumerStatefulWidget {
  const RoomListScreen({super.key});

  @override
  ConsumerState<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends ConsumerState<RoomListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(filteredRoomsProvider);
    final filter = ref.watch(roomFilterProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(compareRoomsProvider).isNotEmpty,
              label: Text('${ref.watch(compareRoomsProvider).length}'),
              child: const Icon(Icons.compare_arrows),
            ),
            onPressed: () {
              if (ref.read(compareRoomsProvider).isNotEmpty) {
                context.push('/guest/compare');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(roomFilterProvider.notifier).setQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(roomFilterProvider.notifier).setQuery(value);
              },
            ),
          ),

          // Sort chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SortChip(
                  label: 'Recommended',
                  selected: filter.sortBy == 'recommended',
                  onTap: () => ref
                      .read(roomFilterProvider.notifier)
                      .setSortBy('recommended'),
                ),
                _SortChip(
                  label: 'Price ↑',
                  selected: filter.sortBy == 'price_low',
                  onTap: () => ref
                      .read(roomFilterProvider.notifier)
                      .setSortBy('price_low'),
                ),
                _SortChip(
                  label: 'Price ↓',
                  selected: filter.sortBy == 'price_high',
                  onTap: () => ref
                      .read(roomFilterProvider.notifier)
                      .setSortBy('price_high'),
                ),
                _SortChip(
                  label: 'Top Rated',
                  selected: filter.sortBy == 'rating',
                  onTap: () =>
                      ref.read(roomFilterProvider.notifier).setSortBy('rating'),
                ),
              ],
            ),
          ),

          // Active filters
          if (filter.type != null ||
              filter.availableOnly ||
              filter.amenities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 8,
                children: [
                  if (filter.type != null)
                    Chip(
                      label: Text(filter.type!.displayName),
                      onDeleted: () =>
                          ref.read(roomFilterProvider.notifier).setType(null),
                    ),
                  if (filter.availableOnly)
                    Chip(
                      label: const Text('Available only'),
                      onDeleted: () => ref
                          .read(roomFilterProvider.notifier)
                          .setAvailableOnly(false),
                    ),
                  ...filter.amenities.map(
                    (a) => Chip(
                      label: Text(a),
                      onDeleted: () => ref
                          .read(roomFilterProvider.notifier)
                          .toggleAmenity(a),
                    ),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: roomsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('Failed to load rooms'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(filteredRoomsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: AppColors.mediumGrey),
                        const SizedBox(height: 16),
                        Text(
                          'No rooms found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () =>
                              ref.read(roomFilterProvider.notifier).reset(),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredRoomsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final isFav = favorites.contains(room.id);
                      return _RoomListTile(
                        room: room,
                        isFavorite: isFav,
                        onTap: () => context.push('/guest/rooms/${room.id}'),
                        onFavorite: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(room.id),
                        onCompare: () => ref
                            .read(compareRoomsProvider.notifier)
                            .toggle(room.id),
                        isCompared: ref
                            .watch(compareRoomsProvider)
                            .contains(room.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _FilterBottomSheet(),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.secondary.withOpacity(0.2),
        checkmarkColor: AppColors.secondary,
      ),
    );
  }
}

class _RoomListTile extends StatelessWidget {
  final RoomModel room;
  final bool isFavorite;
  final bool isCompared;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onCompare;

  const _RoomListTile({
    required this.room,
    required this.isFavorite,
    required this.isCompared,
    required this.onTap,
    required this.onFavorite,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: room.imageUrls.isNotEmpty
                        ? room.imageUrls.first
                        : AppConstants.placeholderRoomImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 180,
                      color: AppColors.lightGrey,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _IconBtn(
                        icon: isCompared
                            ? Icons.check_circle
                            : Icons.compare_arrows,
                        color: isCompared ? AppColors.success : null,
                        onTap: onCompare,
                      ),
                      const SizedBox(width: 8),
                      _IconBtn(
                        icon: isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : null,
                        onTap: onFavorite,
                      ),
                    ],
                  ),
                ),
                if (room.isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${room.pricePerNight.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '/night',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${room.rating.toStringAsFixed(1)} (${room.reviewCount})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.people_outline,
                          size: 16, color: AppColors.mediumGrey),
                      const SizedBox(width: 4),
                      Text(
                        '${room.capacity} guests',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.king_bed_outlined,
                          size: 16, color: AppColors.mediumGrey),
                      const SizedBox(width: 4),
                      Text(
                        room.bedType.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: room.amenities.take(4).map((a) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          a,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color ?? AppColors.primary),
      ),
    );
  }
}

class _FilterBottomSheet extends ConsumerWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(roomFilterProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mediumGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(roomFilterProvider.notifier).reset();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text('Room Type', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: RoomType.values.map((type) {
                    final selected = filter.type == type;
                    return FilterChip(
                      label: Text(type.displayName),
                      selected: selected,
                      onSelected: (v) {
                        ref
                            .read(roomFilterProvider.notifier)
                            .setType(v ? type : null);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Price Range: \$${filter.minPrice.toInt()} - \$${filter.maxPrice.toInt()}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                RangeSlider(
                  values: RangeValues(filter.minPrice, filter.maxPrice),
                  min: 0,
                  max: 2000,
                  divisions: 40,
                  activeColor: AppColors.secondary,
                  labels: RangeLabels(
                    '\$${filter.minPrice.toInt()}',
                    '\$${filter.maxPrice.toInt()}',
                  ),
                  onChanged: (values) {
                    ref
                        .read(roomFilterProvider.notifier)
                        .setPriceRange(values.start, values.end);
                  },
                ),
                const SizedBox(height: 16),
                Text('Min Capacity',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 3, 4, 5, 6].map((c) {
                    return ChoiceChip(
                      label: Text('$c+'),
                      selected: filter.minCapacity == c,
                      onSelected: (_) {
                        ref
                            .read(roomFilterProvider.notifier)
                            .setMinCapacity(c);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Min Rating',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [0.0, 3.0, 3.5, 4.0, 4.5].map((r) {
                    return ChoiceChip(
                      label: Text(r == 0 ? 'Any' : '$r+'),
                      selected: filter.minRating == r,
                      onSelected: (_) {
                        ref.read(roomFilterProvider.notifier).setMinRating(r);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Available only'),
                  value: filter.availableOnly,
                  activeColor: AppColors.secondary,
                  onChanged: (v) {
                    ref
                        .read(roomFilterProvider.notifier)
                        .setAvailableOnly(v);
                  },
                ),
                const SizedBox(height: 16),
                Text('Amenities',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Wi-Fi',
                    'TV',
                    'Air Conditioning',
                    'Minibar',
                    'Balcony',
                    'Jacuzzi',
                    'Room Service',
                    'Safe',
                  ].map((a) {
                    return FilterChip(
                      label: Text(a),
                      selected: filter.amenities.contains(a),
                      onSelected: (_) {
                        ref
                            .read(roomFilterProvider.notifier)
                            .toggleAmenity(a);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
