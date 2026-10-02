import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_item.dart';

class NotificationsState {
  final List<NotificationItem> notifications;
  final NotificationType? selectedType;
  final bool unreadOnly;

  const NotificationsState({
    required this.notifications,
    this.selectedType,
    this.unreadOnly = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get filteredNotifications {
    return notifications.where((n) {
      if (selectedType != null && n.type != selectedType) return false;
      if (unreadOnly && n.isRead) return false;
      return true;
    }).toList();
  }

  NotificationsState copyWith({
    List<NotificationItem>? notifications,
    NotificationType? selectedType,
    bool clearType = false,
    bool? unreadOnly,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      unreadOnly: unreadOnly ?? this.unreadOnly,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier()
      : super(
          const NotificationsState(
            notifications: [
              NotificationItem(
                id: 'NOTIF-01',
                title: 'Low Stock Alert: SKU/LAP-HP-15',
                message: 'SKU LAP-HP-15 has fallen below reorder level (3 units remaining in Bin A01-01-02).',
                type: NotificationType.lowStock,
                timeAgo: '2h ago',
                isRead: false,
                targetRoute: '/products',
              ),
              NotificationItem(
                id: 'NOTIF-02',
                title: 'Pending Putaway: 47 Items Waiting',
                message: 'Inbound GRN-0012 goods cleared QC inspection gate and need immediate putaway to racks.',
                type: NotificationType.pendingPutaway,
                timeAgo: '3h ago',
                isRead: false,
                targetRoute: '/inbound',
              ),
              NotificationItem(
                id: 'NOTIF-03',
                title: 'Pending Dispatch: 23 Orders Ready',
                message: 'Fulfillment wave #04 is picked and waiting at packing station for carrier scan manifests.',
                type: NotificationType.pendingDispatch,
                timeAgo: '5h ago',
                isRead: false,
                targetRoute: '/outbound',
              ),
              NotificationItem(
                id: 'NOTIF-04',
                title: 'Batch Expiry Alert: 12 Batches in 30 Days',
                message: 'Perishable lot #GR-2026-B9 in Cold Vault Zone B reaches shelf expiration in 14 days.',
                type: NotificationType.expiryAlert,
                timeAgo: '1d ago',
                isRead: true,
                targetRoute: '/ledger',
              ),
              NotificationItem(
                id: 'NOTIF-05',
                title: 'System Firmware: Zebra PDA Laser Active',
                message: 'Zebra DataWedge broadcast intent bridge connected with hardware laser active.',
                type: NotificationType.systemInfo,
                timeAgo: '2d ago',
                isRead: true,
                targetRoute: '/scanner',
              ),
            ],
          ),
        );

  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllAsRead() {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void filterByType(NotificationType? type) {
    if (type == null) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
  }

  void toggleUnreadOnly() {
    state = state.copyWith(unreadOnly: !state.unreadOnly);
  }
}

final notificationsNotifierProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});
