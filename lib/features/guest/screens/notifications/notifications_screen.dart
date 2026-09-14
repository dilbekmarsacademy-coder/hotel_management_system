import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../data/dummy_data/dummy_data.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/models/enums.dart';

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super(List.from(DummyData.notifications));

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void delete(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final unread = ref.watch(notificationsProvider.notifier).unreadCount;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 72, color: AppColors.mediumGrey),
                  const SizedBox(height: 16),
                  Text('No notifications', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => ref.read(notificationsProvider.notifier).delete(n.id),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(notificationsProvider.notifier).markAsRead(n.id);
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => _NotificationDetail(notification: n),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isRead ? AppColors.white : AppColors.champagne.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: n.isRead ? AppColors.lightGrey : AppColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _colorForType(n.type).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_iconForType(n.type), color: _colorForType(n.type), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    if (!n.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.body,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeago.format(n.createdAt),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
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

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_outline;
      case NotificationType.bookingCancelled:
        return Icons.cancel_outlined;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.checkInReminder:
      case NotificationType.checkOutReminder:
        return Icons.access_time;
      case NotificationType.roomReady:
        return Icons.hotel;
      case NotificationType.orderUpdate:
        return Icons.restaurant;
      case NotificationType.specialOffer:
        return Icons.local_offer;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
      case NotificationType.paymentReceived:
        return AppColors.success;
      case NotificationType.bookingCancelled:
        return AppColors.error;
      case NotificationType.specialOffer:
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }
}

class _NotificationDetail extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationDetail({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(timeago.format(notification.createdAt), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Text(notification.body, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
