import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/dashboard_stats_provider.dart';

class OperationalPipelineFlow extends ConsumerWidget {
  const OperationalPipelineFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardMetricsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      _PipelineNode(
        stageNumber: '01',
        label: 'Purchase Orders',
        count: '${stats.openPurchaseOrders}',
        statusNote: 'Approved / In-Transit',
        icon: Icons.receipt_long_rounded,
        accentColor: AppColors.primary,
        route: '/inbound',
      ),
      _PipelineNode(
        stageNumber: '02',
        label: 'Dock Receiving (GRN)',
        count: '${stats.dockReceivingCount}',
        statusNote: 'Unloading at Bay 1 & 2',
        icon: Icons.local_shipping_rounded,
        accentColor: AppColors.info,
        route: '/inbound',
      ),
      _PipelineNode(
        stageNumber: '03',
        label: 'QC Inspection Gate',
        count: '${stats.qcPendingCount}',
        statusNote: 'Sampling & Defect Check',
        icon: Icons.fact_check_rounded,
        accentColor: AppColors.warning,
        route: '/inbound',
      ),
      _PipelineNode(
        stageNumber: '04',
        label: 'Directed Putaway',
        count: '${stats.putawayTaskCount}',
        statusNote: 'Shortest Rack Path',
        icon: Icons.move_to_inbox_rounded,
        accentColor: AppColors.secondary,
        route: '/inbound',
      ),
      _PipelineNode(
        stageNumber: '05',
        label: 'Active Storage',
        count: '${(stats.totalAvailableStockUnits / 1000).toStringAsFixed(1)}k',
        statusNote: '1,840 Bins Occupied',
        icon: Icons.inventory_2_rounded,
        accentColor: AppColors.accent,
        route: '/locations',
      ),
      _PipelineNode(
        stageNumber: '06',
        label: 'Wave Picking',
        count: '${stats.activePickingWaves}',
        statusNote: 'Batch Waves Active',
        icon: Icons.shopping_basket_rounded,
        accentColor: AppColors.primary,
        route: '/outbound',
      ),
      _PipelineNode(
        stageNumber: '07',
        label: 'Packing Station',
        count: '${stats.packingSessionsCount}',
        statusNote: 'Scan & Weight Check',
        icon: Icons.inventory_rounded,
        accentColor: AppColors.info,
        route: '/outbound',
      ),
      _PipelineNode(
        stageNumber: '08',
        label: 'Carrier Dispatch',
        count: '${stats.totalDispatchedToday}',
        statusNote: 'Handed to Courier',
        icon: Icons.send_rounded,
        accentColor: AppColors.success,
        route: '/outbound',
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
                  Color.alphaBlend(AppColors.primary.withValues(alpha: 0.05), const Color(0xFF0F172A)),
                ]
              : [
                  Colors.white,
                  Color.alphaBlend(AppColors.primary.withValues(alpha: 0.03), const Color(0xFFF8FAFC)),
                ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.primary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.06 : 0.04),
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
          // Section Title
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final titleWidget = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.alt_route_rounded, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Dock-to-Door Operational Velocity Pipeline',
                      style: AppTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );

              final hintWidget = Text(
                'Live Physical Flow • Tap any node to inspect',
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
                    titleWidget,
                    const SizedBox(height: 4),
                    hintWidget,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 8),
                  hintWidget,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Horizontal scrolling pipeline tracker
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  );
                }

                final step = steps[i ~/ 2];
                return InkWell(
                  onTap: () => context.push(step.route),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    width: 145,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                Color.alphaBlend(step.accentColor.withValues(alpha: 0.12), AppColors.darkSurface),
                                AppColors.darkSurface.withValues(alpha: 0.6),
                              ]
                            : [
                                Color.alphaBlend(step.accentColor.withValues(alpha: 0.08), Colors.white),
                                AppColors.lightSurface,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: step.accentColor.withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: step.accentColor.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: step.accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: step.accentColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                step.stageNumber,
                                style: AppTypography.monospace.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: step.accentColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: step.accentColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: step.accentColor.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(step.icon, size: 12, color: step.accentColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.count,
                          style: AppTypography.h2.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.label,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.statusNote,
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineNode {
  final String stageNumber;
  final String label;
  final String count;
  final String statusNote;
  final IconData icon;
  final Color accentColor;
  final String route;

  const _PipelineNode({
    required this.stageNumber,
    required this.label,
    required this.count,
    required this.statusNote,
    required this.icon,
    required this.accentColor,
    required this.route,
  });
}
