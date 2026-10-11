import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/dashboard_stats_provider.dart';

class UrgentExceptionsPanel extends ConsumerWidget {
  const UrgentExceptionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardMetricsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final exceptions = [
      _ExceptionItemData(
        severity: _Severity.critical,
        title: '${stats.lowStockCount} SKUs Below Reorder Level',
        description: 'Critical items at or below safety stock. Immediate PO issuance recommended.',
        metricBadge: 'CRITICAL',
        badgeColor: AppColors.error,
        actionLabel: 'Reorder Stock',
        actionIcon: Icons.add_shopping_cart_rounded,
        onAction: () => context.push('/products'),
      ),
      _ExceptionItemData(
        severity: _Severity.warning,
        title: '${stats.pendingPutawayCount} Items Pending Putaway',
        description: 'Dock receiving queue: cleared QC inspection and waiting for rack placement > 2h.',
        metricBadge: 'DOCK CONGESTION',
        badgeColor: AppColors.warning,
        actionLabel: 'Assign Racks',
        actionIcon: Icons.move_to_inbox_rounded,
        onAction: () => context.push('/inbound'),
      ),
      _ExceptionItemData(
        severity: _Severity.attention,
        title: '${stats.pendingPickingCount} Orders Awaiting Wave Pick',
        description: 'Customer orders approved for picking. 14 orders flagged for same-day SLA delivery.',
        metricBadge: 'SLA EXPEDITE',
        badgeColor: AppColors.secondary,
        actionLabel: 'Create Wave',
        actionIcon: Icons.bolt_rounded,
        onAction: () => context.push('/outbound'),
      ),
      _ExceptionItemData(
        severity: _Severity.info,
        title: '${stats.readyToDispatchCount} Shipments Ready at Bay 3',
        description: 'Parcels packed, weighed, and verified. Awaiting courier manifest scan.',
        metricBadge: 'DISPATCH READY',
        badgeColor: AppColors.info,
        actionLabel: 'View Manifest',
        actionIcon: Icons.local_shipping_outlined,
        onAction: () => context.push('/outbound'),
      ),
    ];

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkCard,
                  Color.alphaBlend(AppColors.error.withValues(alpha: 0.05), const Color(0xFF0F172A)),
                ]
              : [
                  Colors.white,
                  Color.alphaBlend(AppColors.error.withValues(alpha: 0.03), const Color(0xFFF8FAFC)),
                ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.error.withValues(alpha: 0.25)
              : AppColors.error.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              final titleWidget = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.crisis_alert_rounded, size: 18, color: AppColors.error),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Urgent Action & Exception Center',
                      style: AppTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );

              final badgeWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '${stats.lowStockCount + stats.pendingPutawayCount} ACTIONABLE ITEMS',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 10,
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 8),
                    badgeWidget,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 8),
                  badgeWidget,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Operational bottlenecks requiring supervisor authorization and floor intervention',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Exception Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth > 700;

              if (isTwoColumn) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildExceptionCard(exceptions[0], isDark),
                          const SizedBox(height: AppSpacing.sm),
                          _buildExceptionCard(exceptions[2], isDark),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        children: [
                          _buildExceptionCard(exceptions[1], isDark),
                          const SizedBox(height: AppSpacing.sm),
                          _buildExceptionCard(exceptions[3], isDark),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: exceptions.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildExceptionCard(e, isDark),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExceptionCard(_ExceptionItemData item, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: item.badgeColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: item.badgeColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: item.badgeColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppSpacing.radiusMd)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: item.badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: item.badgeColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            item.metricBadge,
                            style: AppTypography.caption.copyWith(
                              color: item.badgeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: item.onAction,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.actionLabel,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(item.actionIcon, size: 13, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: AppTypography.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Severity { critical, warning, attention, info }

class _ExceptionItemData {
  final _Severity severity;
  final String title;
  final String description;
  final String metricBadge;
  final Color badgeColor;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const _ExceptionItemData({
    required this.severity,
    required this.title,
    required this.description,
    required this.metricBadge,
    required this.badgeColor,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });
}
