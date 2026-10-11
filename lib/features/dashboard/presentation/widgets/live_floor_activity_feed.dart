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
          // Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              final titleRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.history_edu_rounded, size: 18, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Live Floor Activity & Audit Trail',
                      style: AppTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );

              final actionButton = InkWell(
                onTap: () => context.push('/ledger'),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Full Ledger',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 6),
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
            ),
          ),
          const SizedBox(height: 12),

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
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Activity List
          ...filtered.map((item) {
            return InkWell(
              onTap: () => context.push(item.route),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface.withValues(alpha: 0.3) : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
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
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  item.refCode,
                                  style: AppTypography.monospace.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: AppTypography.bodyBold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                item.timeAgo,
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.description,
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                              const SizedBox(width: 4),
                              Text(
                                item.operator,
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontSize: 10,
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      labelStyle: AppTypography.caption.copyWith(
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 11,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
