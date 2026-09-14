import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/dummy_data/dummy_data.dart';
import '../../../data/models/room_model.dart';

class GuestHomeScreen extends ConsumerWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredRooms = DummyData.rooms.where((r) => r.isFeatured).take(6).toList();
    final popularRooms = DummyData.rooms.where((r) => r.isPopular).take(6).toList();
    final services = DummyData.services.take(6).toList();
    final reviews = DummyData.reviews.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          // App Bar with Banner
          // ... more content will be generated
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Featured Rooms', 'See All'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: featuredRooms.length,
                itemBuilder: (context, index) {
                  return _RoomCard(room: featuredRooms[index]);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Popular Rooms', 'See All'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popularRooms.length,
                itemBuilder: (context, index) {
                  return _RoomCard(room: popularRooms[index]);
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Hotel Services', 'See All'),
          ),
          SliverToBoxAdapter(child: _buildServicesGrid(context, services)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'Guest Reviews', 'See All'),
          ),
          SliverToBoxAdapter(child: _buildReviews(context, reviews)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hotel, color: AppColors.secondary, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        AppConstants.hotelName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Experience\nLuxury Living',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover our world-class rooms and services',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.85),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.mediumGrey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search rooms, services...',
                    border: InputBorder.none,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune, color: AppColors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, List services) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.spa,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviews(BuildContext context, List reviews) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        review.guestName[0],
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        review.guestName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    review.comment,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CachedNetworkImage(
              imageUrl: room.imageUrls.isNotEmpty
                  ? room.imageUrls.first
                  : AppConstants.placeholderRoomImage,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 140,
                color: AppColors.lightGrey,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 140,
                color: AppColors.lightGrey,
                child: const Icon(Icons.hotel, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '${room.rating.toStringAsFixed(1)} (${room.reviewCount})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      '\$${room.pricePerNight.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* End of GuestHomeScreen */
