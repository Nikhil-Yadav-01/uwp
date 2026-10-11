import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/dashboard_stats_provider.dart';

class VelocityAndCapacityGrid extends ConsumerWidget {
  const VelocityAndCapacityGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardMetricsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildThroughputCard(stats, isDark)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 5, child: _buildCapacityCard(stats, isDark)),
            ],
          );
        } else {
          return Column(
            children: [
              _buildThroughputCard(stats, isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildCapacityCard(stats, isDark),
            ],
          );
        }
      },
    );
  }

  Widget _buildThroughputCard(DashboardMetricsSummary stats, bool isDark) {
    final timeSlots = [
      _TimeSlotData(time: '08:00', inward: 35, outward: 12),
      _TimeSlotData(time: '10:00', inward: 58, outward: 28),
      _TimeSlotData(time: '12:00', inward: 42, outward: 45),
      _TimeSlotData(time: '14:00', inward: 24, outward: 62),
      _TimeSlotData(time: '16:00', inward: 18, outward: 54),
      _TimeSlotData(time: '18:00', inward: 5, outward: 35),
    ];

    final maxVal = 70;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              final titleRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.info),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Shift Velocity & Throughput',
                      style: AppTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );

              final legendRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _legendDot('Inward GRN', AppColors.info),
                  const SizedBox(width: 12),
                  _legendDot('Outward Ship', AppColors.success),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 6),
                    legendRow,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 8),
                  legendRow,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Hourly volume comparison: Dock receiving vs. Order dispatch cadence',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),

          // Visual Bar Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: timeSlots.map((slot) {
              final inHeight = (slot.inward / maxVal) * 120.0;
              final outHeight = (slot.outward / maxVal) * 120.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 14,
                        height: inHeight,
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        width: 14,
                        height: outHeight,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slot.time,
                    style: AppTypography.monospace.copyWith(
                      fontSize: 10,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              final rhythmText = Text(
                'Shift Rhythm: Peak Receiving 10:00 AM • Peak Dispatch 2:00 PM',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );

              final netFlowText = Text(
                'Net Flow: +26 Units In Stock',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rhythmText,
                    const SizedBox(height: 4),
                    netFlowText,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: rhythmText),
                  const SizedBox(width: 8),
                  netFlowText,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(DashboardMetricsSummary stats, bool isDark) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              final titleRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Facility Storage & Bin Density',
                      style: AppTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );

              final hintText = Text(
                'Across 4 Warehouses',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 4),
                    hintText,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 8),
                  hintText,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Physical volumetric capacity and rack bin utilization monitoring',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),

          ...stats.warehouseCapacities.map((wh) {
            final color = wh.occupancyPercent > 80
                ? AppColors.error
                : (wh.occupancyPercent > 50 ? AppColors.primary : AppColors.success);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                wh.warehouseName,
                                style: AppTypography.bodyBold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '(${wh.location})',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${wh.occupiedBins}/${wh.totalBins}',
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${wh.occupancyPercent.toStringAsFixed(0)}%',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: wh.occupancyPercent / 100,
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _TimeSlotData {
  final String time;
  final int inward;
  final int outward;

  const _TimeSlotData({
    required this.time,
    required this.inward,
    required this.outward,
  });
}
