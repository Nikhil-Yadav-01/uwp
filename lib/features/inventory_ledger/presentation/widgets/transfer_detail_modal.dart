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
import '../../../../shared/presentation/shells/modal_shell.dart';

/// Modal dialog for inspecting full Inter-Warehouse Transfer details, routes, and receiving action.
class TransferDetailModal extends ConsumerWidget {
  final StockTransfer transfer;

  const TransferDetailModal({
    super.key,
    required this.transfer,
  });

  static Future<void> show(BuildContext context, {required StockTransfer transfer}) {
    return ModalShell.show(
      context: context,
      maxWidth: 680,
      child: TransferDetailModal(transfer: transfer),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final ledgerState = ref.watch(inventoryLedgerProvider);
    final currentTransfer = ledgerState.transfers.firstWhere(
      (t) => t.transferId == transfer.transferId,
      orElse: () => transfer,
    );

    final isInTransit = currentTransfer.status == TransferStatus.inTransit;
    final isCompleted = currentTransfer.status == TransferStatus.completed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

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
                    color: currentTransfer.status.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: currentTransfer.status.color,
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
                            currentTransfer.transferNumber,
                            style: AppTypography.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: currentTransfer.transferNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied ${currentTransfer.transferNumber} to clipboard'),
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
                              color: currentTransfer.status.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                              border: Border.all(color: currentTransfer.status.color.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              currentTransfer.status.displayName.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(
                                color: currentTransfer.status.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Created: ${currentTransfer.createdAt.toString().substring(0, 10)} • Requested by: ${currentTransfer.requestedBy}',
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

            // 2. Transfer Route Visualization Card
            Container(
              padding: AppPadding.p12,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: colorScheme.outline),
              ),
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDepotBlock('ORIGIN (SOURCE)', currentTransfer.originWarehouseName, Icons.upload_rounded, AppColors.warning, isDark),
                        AppGap.h8,
                        Center(child: Icon(Icons.arrow_downward_rounded, size: 20, color: colorScheme.primary)),
                        AppGap.h8,
                        _buildDepotBlock('DESTINATION (RECEIVING)', currentTransfer.destinationWarehouseName, Icons.download_rounded, AppColors.success, isDark),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildDepotBlock('ORIGIN (SOURCE)', currentTransfer.originWarehouseName, Icons.upload_rounded, AppColors.warning, isDark),
                        ),
                        AppGap.w12,
                        Icon(Icons.arrow_forward_rounded, size: 22, color: colorScheme.primary),
                        AppGap.w12,
                        Expanded(
                          child: _buildDepotBlock('DESTINATION (RECEIVING)', currentTransfer.destinationWarehouseName, Icons.download_rounded, AppColors.success, isDark),
                        ),
                      ],
                    ),
            ),
            AppGap.h16,

            // 3. Logistics & Carrier Tracking
            if (currentTransfer.carrier != null || currentTransfer.trackingNumber != null) ...[
              Container(
                padding: AppPadding.p12,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, size: AppSizes.iconSm + 2, color: colorScheme.primary),
                    AppGap.w8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logistics Carrier: ${currentTransfer.carrier ?? "Standard Freight"}',
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (currentTransfer.trackingNumber != null)
                            Row(
                              children: [
                                Text(
                                  'Tracking #: ${currentTransfer.trackingNumber}',
                                  style: AppTypography.labelSmall.copyWith(color: colorScheme.primary),
                                ),
                                AppGap.w4,
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: currentTransfer.trackingNumber!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Copied tracking number to clipboard'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.copy_rounded, size: 12, color: colorScheme.primary),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h16,
            ],

            // 4. Transferred Items Table
            Text(
              'Transferred Items (${currentTransfer.items.length})',
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            AppGap.h8,
            ...currentTransfer.items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                padding: AppPadding.p12,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          AppGap.h4,
                          Text(
                            'SKU: ${item.sku} • Origin Bin: ${item.originBin}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          if (item.destinationBin != null) ...[
                            AppGap.h4,
                            Text(
                              'Target Bin: ${item.destinationBin}',
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppGap.w8,
                    Text(
                      '${item.quantity} ${item.uom}',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (currentTransfer.notes != null && currentTransfer.notes!.isNotEmpty) ...[
              AppGap.h8,
              Text(
                'Notes: ${currentTransfer.notes}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            AppGap.h20,

            // 5. Action Footer
            if (isNarrow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isInTransit) ...[
                    ElevatedButton.icon(
                      onPressed: () => _handleReceive(context, ref, currentTransfer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: AppSizes.iconSm),
                      label: const Text('Receive & Put Away'),
                    ),
                    AppGap.h8,
                  ],
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (isInTransit)
                    ElevatedButton.icon(
                      onPressed: () => _handleReceive(context, ref, currentTransfer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: AppSizes.iconSm),
                      label: const Text('Receive & Put Away Stock'),
                    ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.r8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                          AppGap.w4,
                          Text('Received & Put Away', style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildDepotBlock(String role, String whName, IconData icon, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            AppGap.w4,
            Text(
              role,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        AppGap.h4,
        Text(
          whName,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _handleReceive(BuildContext context, WidgetRef ref, StockTransfer transfer) {
    ref.read(inventoryLedgerProvider.notifier).updateTransferStatus(
      transfer.transferId,
      TransferStatus.completed,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transfer ${transfer.transferNumber} received at ${transfer.destinationWarehouseName}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
