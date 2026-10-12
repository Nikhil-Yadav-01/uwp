import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/datasources/sample_data_source.dart';
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
          NotificationsState(
            notifications: SampleDataSource.getNotifications(),
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
