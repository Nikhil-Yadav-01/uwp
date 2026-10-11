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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkCard,
                  const Color(0xFF131D2E),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8FAFC),
                ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark
              ? AppColors.primary.withValues(alpha: 0.2)
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
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.6) : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(alpha: 0.25),
                          ),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'LIVE SYNC',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            fontSize: 10,
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
                    label: 'PO Inbound',
                    icon: Icons.add_shopping_cart_rounded,
                    color: AppColors.primary,
                    onTap: () => context.push('/inbound'),
                  ),
                  _actionButton(
                    context: context,
                    label: 'Scan GRN',
                    icon: Icons.qr_code_scanner_rounded,
                    color: AppColors.info,
                    onTap: () => context.push('/scanner'),
                  ),
                  _actionButton(
                    context: context,
                    label: 'Pick Wave',
                    icon: Icons.bolt_rounded,
                    color: AppColors.warning,
                    onTap: () => context.push('/outbound'),
                  ),
                  _actionButton(
                    context: context,
                    label: 'Stock Move',
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.18), color),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
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
