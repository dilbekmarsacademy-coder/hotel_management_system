import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/enums.dart';
import '../../../../providers/room_providers.dart';

class ReservedRoomsScreen extends ConsumerWidget {
  const ReservedRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(allRoomsProvider);
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Reserved Rooms')),
      body: roomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Failed to load')),
        data: (rooms) {
          final list = rooms.where((r) => r.status == RoomStatus.reserved).toList();
          if (list.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.bookmark_outline, size: 64, color: AppColors.mediumGrey),
              const SizedBox(height: 16),
              Text('No reserved rooms', style: Theme.of(context).textTheme.headlineSmall),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final r = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
                child: Row(children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.reserved.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(r.roomNumber, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.reserved, fontSize: 12)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: Theme.of(context).textTheme.titleSmall),
                    Text('${r.type.displayName} • Floor ${r.floor} • \$${r.pricePerNight.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall),
                  ])),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
