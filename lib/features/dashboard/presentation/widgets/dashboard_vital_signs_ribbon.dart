import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/dashboard_stats_provider.dart';

class DashboardVitalSignsRibbon extends ConsumerWidget {
  const DashboardVitalSignsRibbon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardMetricsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final numberFormatter = NumberFormat('#,##,###');

    final cards = [
      _VitalSignData(
        title: "TODAY'S INWARD",
        value: '${numberFormatter.format(stats.todayInwardUnits)} Units',
        subtitle: '${stats.todayInwardOrders} Purchase Orders Received',
        trendText: '+12.4% vs y\'day',
        isPositiveTrend: true,
        metricPill: '${stats.receivingAccuracy}% QC Pass',
        icon: Icons.input_rounded,
        iconColor: AppColors.info,
      ),
      _VitalSignData(
        title: "TODAY'S OUTWARD",
        value: '${numberFormatter.format(stats.todayOutwardUnits)} Units',
        subtitle: '${stats.todayOutwardOrders} Orders Fulfilled',
        trendText: '+8.1% vs target',
        isPositiveTrend: true,
        metricPill: '42m Cycle Time',
        icon: Icons.output_rounded,
        iconColor: AppColors.success,
      ),
      _VitalSignData(
        title: "TOTAL INVENTORY VALUE",
        value: currencyFormatter.format(stats.totalValuation),
        subtitle: '${numberFormatter.format(stats.totalAvailableStockUnits)} Units • ${numberFormatter.format(stats.totalActiveSkus)} SKUs',
        trendText: 'Healthy Depth',
        isPositiveTrend: true,
        metricPill: '${stats.totalWarehouses} Warehouses',
        icon: Icons.inventory_2_rounded,
        iconColor: AppColors.primary,
      ),
      _VitalSignData(
        title: "FULFILLMENT SLA (OTIF)",
        value: '${stats.otifRate}%',
        subtitle: 'On-Time In-Full Dispatch Rate',
        trendText: 'Target: 95%',
        isPositiveTrend: true,
        metricPill: '99.4% Accuracy',
        icon: Icons.verified_rounded,
        iconColor: AppColors.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1150
            ? 4
            : constraints.maxWidth > 650
                ? 2
                : 1;

        final childAspectRatio = crossAxisCount == 1
            ? (constraints.maxWidth < 400 ? 1.95 : 2.6)
            : (crossAxisCount == 2 ? 1.7 : 1.6);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            return _buildVitalCard(cards[index], isDark);
          },
        );
      },
    );
  }

  Widget _buildVitalCard(_VitalSignData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkCard,
                  Color.alphaBlend(data.iconColor.withValues(alpha: 0.06), const Color(0xFF0F172A)),
                ]
              : [
                  Colors.white,
                  Color.alphaBlend(data.iconColor.withValues(alpha: 0.04), const Color(0xFFF8FAFC)),
                ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? data.iconColor.withValues(alpha: 0.22)
              : data.iconColor.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: data.iconColor.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Title + Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    fontSize: 10.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: data.iconColor.withValues(alpha: isDark ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: data.iconColor.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(
                      color: data.iconColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(data.icon, size: 16, color: data.iconColor),
              ),
            ],
          ),

          // Main Metric Value
          Text(
            data.value,
            style: AppTypography.h1.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 23,
              letterSpacing: -0.5,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Subtitle
          Text(
            data.subtitle,
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  data.iconColor.withValues(alpha: 0.3),
                  isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Bottom Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: data.isPositiveTrend
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: data.isPositiveTrend
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.isPositiveTrend ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 13,
                      color: data.isPositiveTrend ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.trendText,
                      style: AppTypography.caption.copyWith(
                        color: data.isPositiveTrend ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.5)
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    data.metricPill,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalSignData {
  final String title;
  final String value;
  final String subtitle;
  final String trendText;
  final bool isPositiveTrend;
  final String metricPill;
  final IconData icon;
  final Color iconColor;

  const _VitalSignData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trendText,
    required this.isPositiveTrend,
    required this.metricPill,
    required this.icon,
    required this.iconColor,
  });
}
