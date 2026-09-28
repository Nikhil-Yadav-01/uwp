import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/inventory/domain/models/stock_transfer.dart';
import '../../../../core/inventory/presentation/controllers/inventory_ledger_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'transfer_detail_modal.dart';

/// Responsive card displaying an Inter-Warehouse Transfer.
class StockTransferCard extends ConsumerWidget {
  final StockTransfer transfer;

  const StockTransferCard({
    super.key,
    required this.transfer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isInTransit = transfer.status == TransferStatus.inTransit;
    final statusColor = transfer.status.color;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: InkWell(
        onTap: () => TransferDetailModal.show(context, transfer: transfer),
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
              // 1. Header: Transfer ID, Status Badge & Receive Button
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
                          transfer.transferNumber,
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: transfer.transferNumber));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied ${transfer.transferNumber} to clipboard'),
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
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.r4),
                            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            transfer.status.displayName,
                            style: AppTypography.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isInTransit) ...[
                    AppGap.w8,
                    FilledButton.icon(
                      onPressed: () {
                        ref.read(inventoryLedgerProvider.notifier).updateTransferStatus(transfer.transferId, TransferStatus.completed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Transfer ${transfer.transferNumber} received at ${transfer.destinationWarehouseName}'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
                      label: const Text('Receive', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              const Divider(height: AppSpacing.lg),

              // 2. Route Banner: Origin Depot -> Destination Depot
              Container(
                padding: AppPadding.p12,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
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
                            'ORIGIN DEPOT',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          AppGap.h4,
                          Text(
                            transfer.originWarehouseName,
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Icon(Icons.arrow_forward_rounded, color: colorScheme.primary, size: AppSizes.iconSm),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'DESTINATION DEPOT',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          AppGap.h4,
                          Text(
                            transfer.destinationWarehouseName,
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h12,

              // 3. Items Manifest Summary
              Text(
                'ITEMS MANIFEST (${transfer.items.length})',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              AppGap.h8,
              ...transfer.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 14, color: colorScheme.primary),
                      AppGap.w8,
                      Expanded(
                        child: Text(
                          '${item.productName} (${item.sku})',
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppGap.w8,
                      Text(
                        '${item.quantity} ${item.uom}',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // 4. Tracking & Carrier (if available)
              if (transfer.carrier != null) ...[
                const Divider(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    AppGap.w8,
                    Expanded(
                      child: Text(
                        '${transfer.carrier} • Tracking: ${transfer.trackingNumber ?? "N/A"}',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
