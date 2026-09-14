import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/enums.dart';
import '../../../routing/app_router.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = [
      _RoleOption(
        role: UserRole.guest,
        title: 'Guest',
        subtitle: 'Book rooms, order food, request services',
        icon: Icons.person_outline,
        route: '/guest',
      ),
      _RoleOption(
        role: UserRole.admin,
        title: 'Administrator',
        subtitle: 'Full system access and management',
        icon: Icons.admin_panel_settings_outlined,
        route: '/admin',
      ),
      _RoleOption(
        role: UserRole.manager,
        title: 'Manager',
        subtitle: 'Analytics, reports, and operations',
        icon: Icons.analytics_outlined,
        route: '/admin',
      ),
      _RoleOption(
        role: UserRole.receptionist,
        title: 'Receptionist',
        subtitle: 'Check-in, check-out, bookings',
        icon: Icons.desk_outlined,
        route: '/admin',
      ),
      _RoleOption(
        role: UserRole.housekeeping,
        title: 'Housekeeping',
        subtitle: 'Cleaning tasks and room status',
        icon: Icons.cleaning_services_outlined,
        route: '/admin',
      ),
      _RoleOption(
        role: UserRole.restaurantStaff,
        title: 'Restaurant Staff',
        subtitle: 'Orders, kitchen, menu management',
        icon: Icons.restaurant_outlined,
        route: '/admin',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Select Role'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: roles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final option = roles[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.read(authStateProvider.notifier).state = option.role;
                context.go(option.route);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.lightGrey,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                      child: Icon(
                        option.icon,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.darkGrey,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.mediumGrey,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoleOption {
  final UserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const _RoleOption({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
