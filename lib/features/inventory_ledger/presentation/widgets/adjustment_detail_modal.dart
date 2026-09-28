import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/inventory/domain/models/stock_adjustment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';

/// Modal dialog for inspecting full Stock Adjustment, physical recount variance, and sign-offs.
class AdjustmentDetailModal extends StatelessWidget {
  final StockAdjustment adjustment;

  const AdjustmentDetailModal({
    super.key,
    required this.adjustment,
  });

  static Future<void> show(BuildContext context, {required StockAdjustment adjustment}) {
    return ModalShell.show(
      context: context,
      maxWidth: 640,
      child: AdjustmentDetailModal(adjustment: adjustment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isLoss = adjustment.varianceQuantity < 0;
    final varianceColor = isLoss ? AppColors.error : AppColors.success;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: varianceColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(
                    adjustment.reason.icon,
                    color: varianceColor,
                    size: AppSizes.iconMd,
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Text(
                            adjustment.adjustmentNumber,
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: adjustment.adjustmentNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied ${adjustment.adjustmentNumber} to clipboard'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(Icons.copy_rounded, size: 13, color: colorScheme.primary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: varianceColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                              border: Border.all(color: varianceColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              adjustment.reason.displayName,
                              style: AppTypography.labelSmall.copyWith(
                                color: varianceColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Logged ${adjustment.createdAt.toString().substring(0, 10)} • Auditor: ${adjustment.createdBy}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            // 2. 3-Count Variance Comparison Grid (System Qty vs Physical Count vs Calculated Variance)
            Container(
              padding: AppPadding.p16,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: colorScheme.outline),
              ),
              child: isNarrow
                  ? Column(
                      children: [
                        _buildCountTile('SYSTEM COUNT', '${adjustment.systemQuantity} ${adjustment.uom}', AppColors.info, isDark),
                        AppGap.h8,
                        _buildCountTile('PHYSICAL AUDIT', '${adjustment.physicalQuantity} ${adjustment.uom}', colorScheme.primary, isDark),
                        AppGap.h8,
                        _buildCountTile('CALCULATED VARIANCE', '${adjustment.varianceQuantity >= 0 ? "+" : ""}${adjustment.varianceQuantity} ${adjustment.uom}', varianceColor, isDark),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildCountTile('SYSTEM COUNT', '${adjustment.systemQuantity} ${adjustment.uom}', AppColors.info, isDark)),
                        Container(height: 40, width: 1, color: colorScheme.outline),
                        Expanded(child: _buildCountTile('PHYSICAL AUDIT', '${adjustment.physicalQuantity} ${adjustment.uom}', colorScheme.primary, isDark)),
                        Container(height: 40, width: 1, color: colorScheme.outline),
                        Expanded(child: _buildCountTile('CALCULATED VARIANCE', '${adjustment.varianceQuantity >= 0 ? "+" : ""}${adjustment.varianceQuantity} ${adjustment.uom}', varianceColor, isDark)),
                      ],
                    ),
            ),
            AppGap.h16,

            // 3. Item Specification Card
            Container(
              padding: AppPadding.p12,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: AppSizes.iconSm, color: colorScheme.primary),
                      AppGap.w8,
                      Text(
                        'Product & Location Details',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  AppGap.h8,
                  Text(
                    adjustment.productName,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppGap.h4,
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        'SKU: ${adjustment.sku}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        'Warehouse: ${adjustment.warehouseName}',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        'Location: ${adjustment.locationId}',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppGap.h12,

            // 4. Auditor Notes & Supervisor Approval
            Container(
              padding: AppPadding.p12,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: AppSizes.iconSm, color: AppColors.info),
                      AppGap.w8,
                      Text(
                        'Audit Sign-Off & Verification',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  AppGap.h8,
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        'Logged By: ${adjustment.createdBy}',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (adjustment.approvedBy != null)
                        Text(
                          'Approved By: ${adjustment.approvedBy}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  if (adjustment.notes != null && adjustment.notes!.isNotEmpty) ...[
                    AppGap.h8,
                    Text(
                      'Auditor Explanation: ${adjustment.notes}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h20,

            // 5. Action Footer
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                label: const Text('Close'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountTile(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        AppGap.h4,
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
