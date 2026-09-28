import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/inventory/domain/models/inventory_transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'transaction_detail_modal.dart';

/// Modern, structured, and responsive card displaying an immutable Stock Ledger Transaction.
class StockLedgerTransactionCard extends StatelessWidget {
  final InventoryTransaction transaction;

  const StockLedgerTransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isAdd = transaction.transactionType.isAddition;
    final badgeColor = transaction.transactionType.badgeColor;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: InkWell(
        onTap: () => TransactionDetailModal.show(context, transaction: transaction),
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
                  // 1. Header: Type Badge, Ref Tag, and Delta Quantity
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadii.r4),
                                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                transaction.transactionType.displayName,
                                style: AppTypography.labelSmall.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppRadii.r4),
                              ),
                              child: Text(
                                '${transaction.referenceType} #${transaction.referenceId}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
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
                            '${isAdd ? "+" : "-"}${transaction.quantity} ${transaction.uom}',
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isAdd ? AppColors.success : (transaction.transactionType == InventoryTransactionType.damage ? AppColors.error : AppColors.warning),
                            ),
                          ),
                          Text(
                            'Bal: ${transaction.balanceAfter} ${transaction.uom}',
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

                  // 2. Body: Product Name, SKU, Warehouse & Bin Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                        child: Icon(Icons.inventory_2_outlined, color: colorScheme.primary, size: AppSizes.iconSm + 2),
                      ),
                      AppGap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.productName,
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'SKU: ${transaction.sku}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    AppGap.w4,
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: transaction.sku));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Copied ${transaction.sku} to clipboard'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.copy_rounded, size: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                    ),
                                  ],
                                ),
                                Text(
                                  '• ${transaction.warehouseName}',
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
                                    transaction.locationId,
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

                  // 3. Footer: Recorded by & Timestamp
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
                            transaction.createdBy,
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
                            transaction.createdAt.toString().substring(0, 16),
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
