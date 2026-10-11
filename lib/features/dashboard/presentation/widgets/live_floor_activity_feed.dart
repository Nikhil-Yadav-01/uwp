import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class LiveFloorActivityFeed extends ConsumerStatefulWidget {
  const LiveFloorActivityFeed({super.key});

  @override
  ConsumerState<LiveFloorActivityFeed> createState() => _LiveFloorActivityFeedState();
}

class _LiveFloorActivityFeedState extends ConsumerState<LiveFloorActivityFeed> {
  String _selectedFilter = 'ALL';

  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      id: 'ACT-01',
      refCode: 'GRN-000245',
      type: 'INBOUND',
      title: 'Goods Inward Received',
      description: '50 units HP Laptop 15 received against PO-10001 from ABC Traders.',
      operator: 'Rahul Sharma (Dock 2)',
      timeAgo: '15m ago',
      color: AppColors.info,
      route: '/inbound',
    ),
    _ActivityItem(
      id: 'ACT-02',
      refCode: 'WAVE-0012',
      type: 'OUTBOUND',
      title: 'Batch Wave Picking Completed',
      description: 'Wave #4 (24 orders) picked from Aisle A01 & A02 with 100% barcode accuracy.',
      operator: 'Amit Kumar (Floor)',
      timeAgo: '32m ago',
      color: AppColors.primary,
      route: '/outbound',
    ),
    _ActivityItem(
      id: 'ACT-03',
      refCode: 'SO-0456',
      type: 'OUTBOUND',
      title: 'Packing Session Weighed & Labeled',
      description: '12 items verified, packaged into Box #2 (4.2 kg) for Amazon fulfillment.',
      operator: 'Priya Singh (Pack Stn 1)',
      timeAgo: '48m ago',
      color: AppColors.secondary,
      route: '/outbound',
    ),
    _ActivityItem(
      id: 'ACT-04',
      refCode: 'DSP-000623',
      type: 'DISPATCH',
      title: 'Carrier Handover Manifest Closed',
      description: '110 units loaded onto BlueDart Air (Tracking AWB #987654321).',
      operator: 'Neha Verma (Gate 4)',
      timeAgo: '1h 10m ago',
      color: AppColors.success,
      route: '/outbound',
    ),
    _ActivityItem(
      id: 'ACT-05',
      refCode: 'ADJ-0043',
      type: 'ADJUSTMENT',
      title: 'Cycle Count Audit Adjustment',
      description: 'Bin A01-02-04 variance adjusted: -2 units (box damaged during forklift transit).',
      operator: 'Admin Supervisor',
      timeAgo: '2h 05m ago',
      color: AppColors.warning,
      route: '/ledger',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _activities.where((act) {
      if (_selectedFilter == 'ALL') return true;
      return act.type == _selectedFilter;
    }).toList();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? AppColors.darkCard : Colors.white,
            isDark
                ? Color.alphaBlend(AppColors.secondary.withValues(alpha: 0.05), AppColors.darkCard)
                : Color.alphaBlend(AppColors.secondary.withValues(alpha: 0.03), AppColors.lightCard),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.22)
              : AppColors.secondary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 24,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              final titleRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.25),
                          AppColors.secondary.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.history_edu_rounded, size: 18, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Live Floor Activity & Audit Trail',
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );

              final actionButton = InkWell(
                onTap: () => context.push('/ledger'),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Full Ledger',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primary),
                    ],
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 8),
                    actionButton,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleRow),
                  const SizedBox(width: 8),
                  actionButton,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Chronological feed of physical stock receipts, wave picks, packing, and carrier dispatches',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Event Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('ALL', 'All Events', isDark),
                const SizedBox(width: 6),
                _filterChip('INBOUND', 'Inbound Dock', isDark),
                const SizedBox(width: 6),
                _filterChip('OUTBOUND', 'Outbound Fulfillment', isDark),
                const SizedBox(width: 6),
                _filterChip('DISPATCH', 'Carrier Dispatch', isDark),
                const SizedBox(width: 6),
                _filterChip('ADJUSTMENT', 'Adjustments', isDark),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Activity List
          ...filtered.map((item) {
            return InkWell(
              onTap: () => context.push(item.route),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.45)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isDark
                        ? item.color.withValues(alpha: 0.18)
                        : item.color.withValues(alpha: 0.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item.color.withValues(alpha: 0.22),
                            item.color.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: item.color.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(Icons.flash_on_rounded, size: 14, color: item.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: item.color.withValues(alpha: 0.25),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  item.refCode,
                                  style: AppTypography.monospace.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: item.color,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: AppTypography.bodyBold.copyWith(
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                item.timeAgo,
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.operator,
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label, bool isDark) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _ActivityItem {
  final String id;
  final String refCode;
  final String type;
  final String title;
  final String description;
  final String operator;
  final String timeAgo;
  final Color color;
  final String route;

  const _ActivityItem({
    required this.id,
    required this.refCode,
    required this.type,
    required this.title,
    required this.description,
    required this.operator,
    required this.timeAgo,
    required this.color,
    required this.route,
  });
}
