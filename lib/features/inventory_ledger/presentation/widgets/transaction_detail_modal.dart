import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/inventory/domain/models/inventory_transaction.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';

/// Modal dialog for inspecting complete immutable audit trail metadata of a Stock Transaction.
class TransactionDetailModal extends StatelessWidget {
  final InventoryTransaction transaction;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
  });

  static Future<void> show(BuildContext context, {required InventoryTransaction transaction}) {
    return ModalShell.show(
      context: context,
      maxWidth: 640,
      child: TransactionDetailModal(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isAdd = transaction.transactionType.isAddition;
    final badgeColor = transaction.transactionType.badgeColor;

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
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(
                    isAdd ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                    color: badgeColor,
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
                            transaction.transactionType.displayName,
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '${isAdd ? "+" : "-"}${transaction.quantity} ${transaction.uom}',
                              style: AppTypography.labelSmall.copyWith(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Transaction ID: ${transaction.transactionId}',
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

            // 2. 4-Metric Grid
            _buildMetricGrid(context, transaction, isDark, colorScheme, isNarrow),
            AppGap.h16,

            // 3. Product & SKU Specification Card
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
                      Icon(Icons.inventory_2_outlined, size: AppSizes.iconSm, color: colorScheme.primary),
                      AppGap.w8,
                      Text(
                        'Item Specification',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  AppGap.h8,
                  Text(
                    transaction.productName,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppGap.h4,
                  Row(
                    children: [
                      Text(
                        'SKU: ${transaction.sku}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      AppGap.w8,
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: transaction.sku));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied SKU ${transaction.sku} to clipboard'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(Icons.copy_rounded, size: 12, color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppGap.h12,

            // 4. Warehouse & Bin Location Card
            Container(
              padding: AppPadding.p12,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WAREHOUSE DEPOT',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        AppGap.h4,
                        Text(
                          transaction.warehouseName,
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: colorScheme.outline,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BIN / RACK LOCATION',
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        AppGap.h4,
                        Text(
                          transaction.locationId,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h12,

            // 5. Audit Trail & User Sign-off
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
                      Icon(Icons.verified_user_outlined, size: AppSizes.iconSm, color: AppColors.info),
                      AppGap.w8,
                      Text(
                        'Audit Trail & Sign-off',
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
                        'Recorded By: ${transaction.createdBy}',
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Timestamp: ${transaction.createdAt.toString().substring(0, 19)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                    AppGap.h8,
                    Text(
                      'Audit Notes: ${transaction.notes}',
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

            // 6. Action Footer
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

  Widget _buildMetricGrid(
    BuildContext context,
    InventoryTransaction tx,
    bool isDark,
    ColorScheme colorScheme,
    bool isNarrow,
  ) {
    final isAdd = tx.transactionType.isAddition;
    final badgeColor = tx.transactionType.badgeColor;

    final items = [
      {
        'label': 'QUANTITY DELTA',
        'value': '${isAdd ? "+" : "-"}${tx.quantity} ${tx.uom}',
        'icon': isAdd ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        'color': badgeColor,
      },
      {
        'label': 'BALANCE AFTER',
        'value': '${tx.balanceAfter} ${tx.uom}',
        'icon': Icons.account_balance_wallet_outlined,
        'color': colorScheme.primary,
      },
      {
        'label': 'REFERENCE TYPE',
        'value': tx.referenceType,
        'icon': Icons.receipt_long_outlined,
        'color': AppColors.info,
      },
      {
        'label': 'DOCUMENT REF',
        'value': '#${tx.referenceId}',
        'icon': Icons.tag_rounded,
        'color': colorScheme.secondary,
      },
    ];

    if (isNarrow) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricTile(items[0], isDark, colorScheme)),
              AppGap.w8,
              Expanded(child: _buildMetricTile(items[1], isDark, colorScheme)),
            ],
          ),
          AppGap.h8,
          Row(
            children: [
              Expanded(child: _buildMetricTile(items[2], isDark, colorScheme)),
              AppGap.w8,
              Expanded(child: _buildMetricTile(items[3], isDark, colorScheme)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: _buildMetricTile(item, isDark, colorScheme),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricTile(Map<String, dynamic> item, bool isDark, ColorScheme colorScheme) {
    final color = item['color'] as Color;

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(item['icon'] as IconData, size: 14, color: color),
            ],
          ),
          AppGap.h4,
          Text(
            item['value'] as String,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
