import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/dashboard_stats_provider.dart';

class ExecutiveCommandBar extends ConsumerWidget {
  const ExecutiveCommandBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(dashboardFilterProvider);
    final filterNotifier = ref.read(dashboardFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960;

              final leftControls = Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Facility Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filter.selectedWarehouseId,
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        isDense: true,
                        style: AppTypography.bodyBold.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                        onChanged: (val) {
                          if (val != null) filterNotifier.setWarehouse(val);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Row(
                              children: [
                                Icon(Icons.apartment_rounded, size: 16, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('All Facilities (4 Warehouses)'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'WH-001',
                            child: Row(
                              children: [
                                Icon(Icons.warehouse_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('WH-001: Delhi Central Hub'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'WH-002',
                            child: Row(
                              children: [
                                Icon(Icons.warehouse_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('WH-002: Mumbai Regional'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'WH-003',
                            child: Row(
                              children: [
                                Icon(Icons.warehouse_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('WH-003: Bangalore Fulfillment'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'WH-004',
                            child: Row(
                              children: [
                                Icon(Icons.warehouse_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('WH-004: Pune Transit'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Timeframe Segmented Control
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: DashboardTimeframe.values.map((tf) {
                          final isSelected = filter.timeframe == tf;
                          return InkWell(
                            onTap: () => filterNotifier.setTimeframe(tf),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: Text(
                                tf.label,
                                style: AppTypography.caption.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Live Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE SYNC',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final rightActions = Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _actionButton(
                    context: context,
                    label: '+ PO Inbound',
                    icon: Icons.add_shopping_cart_rounded,
                    color: AppColors.primary,
                    onTap: () => context.push('/inbound'),
                  ),
                  _actionButton(
                    context: context,
                    label: '📥 Scan GRN',
                    icon: Icons.qr_code_scanner_rounded,
                    color: AppColors.info,
                    onTap: () => context.push('/scanner'),
                  ),
                  _actionButton(
                    context: context,
                    label: '⚡ Pick Wave',
                    icon: Icons.bolt_rounded,
                    color: AppColors.warning,
                    onTap: () => context.push('/outbound'),
                  ),
                  _actionButton(
                    context: context,
                    label: '⇄ Stock Move',
                    icon: Icons.sync_alt_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.push('/ledger'),
                  ),
                ],
              );

              if (isDesktop) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: leftControls),
                    const SizedBox(width: 16),
                    rightActions,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftControls,
                    const SizedBox(height: AppSpacing.sm),
                    rightActions,
                  ],
                );
              }
            },
          ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
