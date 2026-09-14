import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/service_model.dart';
import '../../../../data/repositories/service_repository.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return DummyServiceRepository();
});

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  return ref.watch(serviceRepositoryProvider).getAllServices();
});

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Hotel Services')),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load services'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(servicesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text('No services available'));
          }

          final categories = services.map((s) => s.category).toSet().toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(servicesProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final category in categories) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  ...services
                      .where((s) => s.category == category)
                      .map((service) => _ServiceCard(service: service)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _iconFor(service.iconName),
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      service.price == 0
                          ? 'Complimentary'
                          : '\$${service.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (service.durationMinutes > 0) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.schedule,
                          size: 14, color: AppColors.mediumGrey),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: service.isAvailable
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${service.name} booking requested'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              minimumSize: Size.zero,
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String? name) {
    switch (name) {
      case 'local_taxi':
        return Icons.local_taxi;
      case 'spa':
        return Icons.spa;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'pool':
        return Icons.pool;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'room_service':
        return Icons.room_service;
      case 'free_breakfast':
        return Icons.free_breakfast;
      case 'meeting_room':
        return Icons.meeting_room;
      case 'alarm':
        return Icons.alarm;
      case 'hotel':
        return Icons.hotel;
      case 'local_parking':
        return Icons.local_parking;
      case 'child_care':
        return Icons.child_care;
      case 'tour':
        return Icons.tour;
      case 'wine_bar':
        return Icons.wine_bar;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
