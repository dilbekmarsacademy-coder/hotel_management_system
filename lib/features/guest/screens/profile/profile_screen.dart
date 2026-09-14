import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routing/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).state = null;
              context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primary,
                      child: const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 36,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => context.push('/guest/profile/edit'),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Guest User', style: Theme.of(context).textTheme.headlineSmall),
                Text('guest@example.com', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.champagne,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Gold Member', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Stats
          Row(
            children: [
              _StatCard(label: 'Bookings', value: '12'),
              const SizedBox(width: 12),
              _StatCard(label: 'Reviews', value: '5'),
              const SizedBox(width: 12),
              _StatCard(label: 'Points', value: '2,450'),
            ],
          ),
          const SizedBox(height: 28),

          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _MenuTile(icon: Icons.person_outline, title: 'Edit Profile', onTap: () => context.push('/guest/profile/edit')),
          _MenuTile(icon: Icons.lock_outline, title: 'Change Password', onTap: () => context.push('/guest/profile/change-password')),
          _MenuTile(icon: Icons.security, title: 'Security', onTap: () => context.push('/guest/profile/security')),

          const SizedBox(height: 20),
          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _MenuTile(icon: Icons.notifications_outlined, title: 'Notification Settings', onTap: () => context.push('/guest/profile/notifications')),
          _MenuTile(icon: Icons.language, title: 'Language', onTap: () => context.push('/guest/profile/language')),
          _MenuTile(icon: Icons.dark_mode_outlined, title: 'Appearance', onTap: () => context.push('/guest/profile/theme')),
          _MenuTile(icon: Icons.privacy_tip_outlined, title: 'Privacy', onTap: () => context.push('/guest/profile/privacy')),

          const SizedBox(height: 20),
          Text('Support', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _MenuTile(icon: Icons.help_outline, title: 'Help Center', onTap: () => context.push('/guest/profile/help')),
          _MenuTile(icon: Icons.quiz_outlined, title: 'FAQ', onTap: () => context.push('/guest/profile/faq')),
          _MenuTile(icon: Icons.support_agent, title: 'Contact Support', onTap: () => context.push('/guest/profile/contact')),
          _MenuTile(icon: Icons.description_outlined, title: 'Terms & Conditions', onTap: () => context.push('/guest/profile/terms')),
          _MenuTile(icon: Icons.info_outline, title: 'About Hotel', onTap: () => context.push('/guest/profile/about')),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(authStateProvider.notifier).state = null;
                context.go('/login');
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.mediumGrey),
      onTap: onTap,
    );
  }
}
