import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'guest_home_screen.dart';
import 'room_list_screen.dart';
import 'my_bookings_screen.dart';

class GuestShell extends ConsumerStatefulWidget {
  const GuestShell({super.key});

  @override
  ConsumerState<GuestShell> createState() => _GuestShellState();
}

class _GuestShellState extends ConsumerState<GuestShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          GuestHomeScreen(),
          RoomListScreen(),
          MyBookingsScreen(),
          _ExploreTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.secondary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.hotel_outlined),
            selectedIcon: Icon(Icons.hotel),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExploreCard(
            icon: Icons.restaurant,
            title: 'Restaurant',
            subtitle: 'Order food to your room',
            onTap: () => context.push('/guest/restaurant'),
          ),
          _ExploreCard(
            icon: Icons.spa,
            title: 'Services',
            subtitle: 'Spa, gym, transfers & more',
            onTap: () => context.push('/guest/services'),
          ),
          _ExploreCard(
            icon: Icons.favorite_outline,
            title: 'Favorites',
            subtitle: 'Your saved rooms',
            onTap: () => context.push('/guest/favorites'),
          ),
          _ExploreCard(
            icon: Icons.star_outline,
            title: 'Reviews',
            subtitle: 'Guest experiences',
            onTap: () => context.push('/guest/reviews'),
          ),
          _ExploreCard(
            icon: Icons.card_giftcard,
            title: 'Loyalty & Rewards',
            subtitle: 'Points, coupons & offers',
            onTap: () => context.push('/guest/loyalty'),
          ),
        ],
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExploreCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mediumGrey),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: const Text('G',
                      style: TextStyle(
                          fontSize: 32,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                Text('Guest User',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('guest@example.com',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.darkGrey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _tile(context, Icons.person_outline, 'Edit Profile'),
          _tile(context, Icons.lock_outline, 'Change Password'),
          _tile(context, Icons.notifications_outlined, 'Notification Settings'),
          _tile(context, Icons.language, 'Language'),
          _tile(context, Icons.dark_mode_outlined, 'Appearance'),
          _tile(context, Icons.help_outline, 'Help Center'),
          _tile(context, Icons.info_outline, 'About Hotel'),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title) {
    final routes = {
      'Notification Settings': '/guest/notifications',
      'Language': '/guest/profile',
      'Appearance': '/guest/profile',
      'Help Center': '/guest/profile/help',
      'About Hotel': '/guest/profile/about',
    };
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        final r = routes[title];
        if (r != null) context.push(r);
      },
    );
  }
}
