import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/notification_item.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationsNotifierProvider);
    final notifNotifier = ref.read(notificationsNotifierProvider.notifier);
    final archetype = ref.watch(archetypeProvider).archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final notifications = notifState.filteredNotifications;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < AppSpacing.breakpointMobile;

                  final titleSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Text('Notifications & Operational Alerts', style: AppTypography.headlineLarge),
                          if (notifState.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadii.r4),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '${notifState.unreadCount} Unread',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error),
                              ),
                            ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Live system warnings for stock reorder thresholds, putaway delays & batch expirations',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final markAllBtn = OutlinedButton.icon(
                    onPressed: notifState.unreadCount > 0 ? () => notifNotifier.markAllAsRead() : null,
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Mark All Read'),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        SizedBox(width: double.infinity, child: markAllBtn),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      markAllBtn,
                    ],
                  );
                },
              ),
              AppGap.h20,

              // 2. Filter Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Alerts'),
                      selected: notifState.selectedType == null,
                      onSelected: (_) => notifNotifier.filterByType(null),
                    ),
                    AppGap.w8,
                    ...NotificationType.values.map((type) {
                      final isSelected = notifState.selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(type.icon, size: 14, color: isSelected ? Colors.white : type.color),
                          label: Text(type.label),
                          selected: isSelected,
                          selectedColor: type.color,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => notifNotifier.filterByType(isSelected ? null : type),
                        ),
                      );
                    }),
                    AppGap.w8,
                    FilterChip(
                      label: const Text('Unread Only', style: TextStyle(fontSize: 11)),
                      selected: notifState.unreadOnly,
                      onSelected: (_) => notifNotifier.toggleUnreadOnly(),
                    ),
                  ],
                ),
              ),
              AppGap.h20,

              // 3. Notification Cards List
              if (notifications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: AppPadding.p32,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none_rounded, size: AppSizes.buttonHeightMd, color: colorScheme.primary.withValues(alpha: 0.5)),
                      AppGap.h16,
                      Text('No Notifications', style: AppTypography.headlineSmall),
                      AppGap.h4,
                      Text(
                        'All operational alerts have been cleared.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => AppGap.h12,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return _buildNotificationCard(context, item, notifNotifier, archetype.brandColor, isDark, colorScheme);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItem item,
    NotificationsNotifier notifier,
    Color brandColor,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: item.isRead
            ? colorScheme.surface
            : item.type.color.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(
          color: item.isRead
              ? colorScheme.outline
              : item.type.color.withValues(alpha: 0.35),
          width: item.isRead ? 1 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.r12),
          onTap: () {
            notifier.markAsRead(item.id);
            if (item.targetRoute != null) {
              context.go(item.targetRoute!);
            }
          },
          child: Padding(
            padding: AppPadding.p16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: item.type.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.type.icon, size: 20, color: item.type.color),
                ),
                AppGap.w12,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.title,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                              ),
                            ),
                          ),
                          AppGap.w8,
                          Text(
                            item.timeAgo,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        item.message,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (item.targetRoute != null) ...[
                        AppGap.h8,
                        Row(
                          children: [
                            Text(
                              'View Actionable Module →',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.type.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Read Indicator Pill
                if (!item.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4, left: 8),
                    decoration: BoxDecoration(
                      color: item.type.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
