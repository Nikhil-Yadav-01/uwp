import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/inventory/domain/models/stock_adjustment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'adjustment_detail_modal.dart';

/// Responsive card displaying a Stock Adjustment / Recount Record.
class StockAdjustmentCard extends StatelessWidget {
  final StockAdjustment adjustment;

  const StockAdjustmentCard({
    super.key,
    required this.adjustment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isLoss = adjustment.varianceQuantity < 0;
    final varianceColor = isLoss ? AppColors.error : AppColors.success;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: InkWell(
        onTap: () => AdjustmentDetailModal.show(context, adjustment: adjustment),
        borderRadius: BorderRadius.circular(AppRadii.r12),
        child: Container(
          padding: AppPadding.p16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Adjustment Number, Reason Badge, and Calculated Variance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(adjustment.reason.icon, size: 12, color: varianceColor),
                              AppGap.w4,
                              Text(
                                adjustment.reason.displayName,
                                style: AppTypography.labelSmall.copyWith(
                                  color: varianceColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppGap.w8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${adjustment.varianceQuantity >= 0 ? "+" : ""}${adjustment.varianceQuantity} ${adjustment.uom}',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: varianceColor,
                        ),
                      ),
                      Text(
                        'Physical: ${adjustment.physicalQuantity} ${adjustment.uom}',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),

              // 2. Product Name, SKU, Warehouse & Bin Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: varianceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Icon(Icons.tune_rounded, color: varianceColor, size: AppSizes.iconSm + 2),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adjustment.productName,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppGap.h4,
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            Text(
                              'SKU: ${adjustment.sku}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              '• ${adjustment.warehouseName}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(AppRadii.r4),
                              ),
                              child: Text(
                                adjustment.locationId,
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppGap.h12,

              // 3. Footer: Auditor & Timestamp
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline_rounded, size: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      AppGap.w4,
                      Text(
                        'Auditor: ${adjustment.createdBy}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded, size: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      AppGap.w4,
                      Text(
                        adjustment.createdAt.toString().substring(0, 16),
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
