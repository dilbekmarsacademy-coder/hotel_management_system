import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'admin_dashboard_screen.dart';
import 'rooms/admin_room_list_screen.dart';
import 'bookings/admin_booking_list_screen.dart';
import 'guests/admin_guest_list_screen.dart';
import 'staff/admin_staff_list_screen.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final screens = [
      const AdminDashboardScreen(),
      const AdminRoomListScreen(),
      const AdminBookingListScreen(),
      const AdminGuestListScreen(),
      const AdminStaffListScreen(),
      _MoreMenu(onLogout: () => context.go('/login')),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              extended: MediaQuery.of(context).size.width >= 1100,
              backgroundColor: AppColors.primary,
              selectedIconTheme: const IconThemeData(color: AppColors.secondary),
              unselectedIconTheme: const IconThemeData(color: AppColors.mediumGrey),
              selectedLabelTextStyle: const TextStyle(color: AppColors.secondary),
              unselectedLabelTextStyle: const TextStyle(color: AppColors.mediumGrey),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(Icons.hotel, color: AppColors.secondary, size: 32),
                    const SizedBox(height: 8),
                    Text(AppConstants.appName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(Icons.hotel_outlined), selectedIcon: Icon(Icons.hotel), label: Text('Rooms')),
                NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: Text('Bookings')),
                NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Guests')),
                NavigationRailDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: Text('Staff')),
                NavigationRailDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: Text('More')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[_selectedIndex.clamp(0, 4)],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex.clamp(0, 4),
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.hotel_outlined), selectedIcon: Icon(Icons.hotel), label: 'Rooms'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Guests'),
          NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: 'Staff'),
        ],
      ),
    );
  }
}

class _MoreMenu extends StatelessWidget {
  final VoidCallback onLogout;
  const _MoreMenu({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData, String)>[
      ('Housekeeping', Icons.cleaning_services, '/admin/housekeeping'),
      ('Maintenance', Icons.build, '/admin/maintenance'),
      ('Restaurant Admin', Icons.restaurant, '/admin/restaurant'),
      ('Payments', Icons.payment, '/admin/payments'),
      ('Reports', Icons.bar_chart, '/admin/reports'),
      ('Analytics', Icons.analytics, '/admin/analytics'),
      ('Reception', Icons.desk, '/admin/reception'),
      ('Invoices', Icons.receipt_long, '/admin/invoices'),
      ('Promotions', Icons.local_offer, '/admin/promotions'),
      ('Coupons', Icons.confirmation_number, '/admin/coupons'),
      ('Loyalty', Icons.card_giftcard, '/admin/loyalty'),
      ('Calendar', Icons.calendar_month, '/admin/calendar'),
      ('Settings', Icons.settings_outlined, '/admin/settings'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ...items.map((item) => ListTile(
                leading: Icon(item.$2, color: AppColors.primary),
                title: Text(item.$1),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(item.$3),
              )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
