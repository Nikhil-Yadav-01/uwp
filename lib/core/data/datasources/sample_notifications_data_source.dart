import '../../../features/notifications/domain/models/notification_item.dart';

/// Clean data source providing realistic system alerts and reminders.
/// Written in friendly everyday language.
class SampleNotificationsDataSource {
  const SampleNotificationsDataSource._();

  static List<NotificationItem> getAll() {
    return const [
      NotificationItem(
        id: 'NOTIF-01',
        title: 'Low Stock Alert: Leather Off-Cuts',
        message: 'Only 14.5 kg of Artisan Leather Off-Cuts remain on Shelf A1. Time to reorder.',
        type: NotificationType.lowStock,
        timeAgo: '1h ago',
        isRead: false,
        targetRoute: '/products',
      ),
      NotificationItem(
        id: 'NOTIF-02',
        title: 'Delivery Waiting: 30 New Phones at Dock 2',
        message: 'Apex Electronics shipment passed inspection and is ready to be put on warehouse shelves.',
        type: NotificationType.pendingPutaway,
        timeAgo: '2h ago',
        isRead: false,
        targetRoute: '/inbound',
      ),
      NotificationItem(
        id: 'NOTIF-03',
        title: 'Urgent Order: Hospital Emergency ICU Medicine',
        message: 'Order SO-2026-HOSP-402 is packed and waiting for priority courier pickup.',
        type: NotificationType.pendingDispatch,
        timeAgo: '3h ago',
        isRead: false,
        targetRoute: '/outbound',
      ),
      NotificationItem(
        id: 'NOTIF-04',
        title: 'Freshness Alert: Strawberries Expiring in 2 Days',
        message: '38 boxes of Sweet Mountain Strawberries in Cold Room B need to be delivered soon.',
        type: NotificationType.expiryAlert,
        timeAgo: '5h ago',
        isRead: false,
        targetRoute: '/products',
      ),
      NotificationItem(
        id: 'NOTIF-05',
        title: 'System Ready: Barcode Scanner Laser Connected',
        message: 'Zebra mobile scanner is active and ready for fast warehouse scanning.',
        type: NotificationType.systemInfo,
        timeAgo: '1d ago',
        isRead: true,
        targetRoute: '/scanner',
      ),
    ];
  }
}
