import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum NotificationType {
  lowStock,
  pendingPutaway,
  pendingDispatch,
  expiryAlert,
  systemInfo,
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.lowStock:
        return 'Low Stock Alert';
      case NotificationType.pendingPutaway:
        return 'Pending Putaway';
      case NotificationType.pendingDispatch:
        return 'Pending Dispatch';
      case NotificationType.expiryAlert:
        return 'Expiry Countdown';
      case NotificationType.systemInfo:
        return 'System Info';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.lowStock:
        return Icons.warning_amber_rounded;
      case NotificationType.pendingPutaway:
        return Icons.move_to_inbox_rounded;
      case NotificationType.pendingDispatch:
        return Icons.local_shipping_outlined;
      case NotificationType.expiryAlert:
        return Icons.timer_outlined;
      case NotificationType.systemInfo:
        return Icons.info_outline_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.lowStock:
        return AppColors.error;
      case NotificationType.pendingPutaway:
        return AppColors.warning;
      case NotificationType.pendingDispatch:
        return AppColors.info;
      case NotificationType.expiryAlert:
        return const Color(0xFFEC4899); // Pink
      case NotificationType.systemInfo:
        return const Color(0xFF6366F1); // Indigo
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String timeAgo;
  final bool isRead;
  final String? targetRoute;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timeAgo,
    this.isRead = false,
    this.targetRoute,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? timeAgo,
    bool? isRead,
    String? targetRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timeAgo: timeAgo ?? this.timeAgo,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }
}
