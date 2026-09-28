import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/sales_order.dart';
import 'so_detail_modal.dart';
import 'so_form_modal.dart';

/// Modern, structured, and fully responsive Sales Order Card.
class OutboundSoCard extends StatelessWidget {
  final SalesOrder order;
  final VoidCallback onStartPacking;
  final void Function(int tabIndex)? onNavigateStage;

  const OutboundSoCard({
    super.key,
    required this.order,
    required this.onStartPacking,
    this.onNavigateStage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isEmergency = order.priority == OrderPriority.emergencyCrashCart;
    final canEdit = order.status == OutboundStatus.pending || order.status == OutboundStatus.allocated;
    final canPack = order.status == OutboundStatus.picked || order.status == OutboundStatus.packing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        return Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          child: InkWell(
            onTap: () => SoDetailModal.show(
              context,
              salesOrder: order,
              onNavigateStage: onNavigateStage,
            ),
            borderRadius: BorderRadius.circular(AppRadii.r12),
            child: Container(
              padding: AppPadding.p16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.r12),
                border: Border.all(
                  color: isEmergency
                      ? colorScheme.error.withValues(alpha: 0.6)
                      : colorScheme.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header: Icon, SO#, Priority, Status Chip & Financials
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: isEmergency
                              ? colorScheme.error.withValues(alpha: 0.12)
                              : colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                        child: Icon(
                          isEmergency ? Icons.emergency_rounded : Icons.shopping_bag_outlined,
                          color: isEmergency ? colorScheme.error : colorScheme.primary,
                          size: AppSizes.iconSm + 2,
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
                                  order.soNumber,
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: order.soNumber));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Copied ${order.soNumber} to clipboard'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(AppRadii.r4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(Icons.copy_rounded, size: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  ),
                                ),
                                _buildPriorityBadge(order.priority, colorScheme),
                                _buildStatusChip(order.status, colorScheme),
                              ],
                            ),
                            AppGap.h4,
                            Text(
                              '${order.customerName} • ${order.destinationWardOrAddress}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${order.totalRequestedUnits.toStringAsFixed(0)} units total',
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),

                  // 2. Line Items Preview Table
                  Container(
                    padding: AppPadding.p12,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ORDERED ITEMS (${order.items.length})',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              'UNIT PRICE',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        AppGap.h8,
                        ...order.items.take(3).map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${item.productName} (${item.sku}) — ${item.requestedQty.toStringAsFixed(0)} ${item.uom}',
                                    style: AppTypography.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppGap.w8,
                                Text(
                                  '\$${item.unitPrice.toStringAsFixed(2)}',
                                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (order.items.length > 3) ...[
                          AppGap.h4,
                          Text(
                            '+ ${order.items.length - 3} more items...',
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 3. Narrow Screen Financials
                  if (isNarrow) ...[
                    AppGap.h12,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL VALUE',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TOTAL QUANTITY',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              '${order.totalRequestedUnits.toStringAsFixed(0)} units',
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  AppGap.h12,

                  // 4. Footer & Action Buttons
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          AppGap.w4,
                          Text(
                            order.orderDate.toString().substring(0, 10),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (canEdit)
                            OutlinedButton.icon(
                              onPressed: () => SoFormModal.show(context, salesOrder: order),
                              icon: const Icon(Icons.edit_rounded, size: 13),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: () => SoDetailModal.show(
                              context,
                              salesOrder: order,
                              onNavigateStage: onNavigateStage,
                            ),
                            icon: const Icon(Icons.visibility_outlined, size: 13),
                            label: const Text('Details'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            ),
                          ),
                          if (canPack)
                            ElevatedButton.icon(
                              onPressed: onStartPacking,
                              icon: const Icon(Icons.qr_code_scanner_rounded, size: 13),
                              label: const Text('Pack Order'),
                              style: ElevatedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
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
      },
    );
  }

  Widget _buildPriorityBadge(OrderPriority priority, ColorScheme colorScheme) {
    Color bg;
    Color fg;
    String label;

    switch (priority) {
      case OrderPriority.emergencyCrashCart:
        bg = colorScheme.error;
        fg = colorScheme.onError;
        label = 'EMERGENCY';
        break;
      case OrderPriority.rush:
        bg = AppColors.warning;
        fg = Colors.white;
        label = 'RUSH';
        break;
      case OrderPriority.standard:
        bg = colorScheme.outline.withValues(alpha: 0.15);
        fg = colorScheme.onSurface;
        label = 'STANDARD';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.r4)),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 9),
      ),
    );
  }

  Widget _buildStatusChip(OutboundStatus status, ColorScheme colorScheme) {
    Color bg;
    Color fg;

    switch (status) {
      case OutboundStatus.pending:
      case OutboundStatus.allocated:
        bg = AppColors.info.withValues(alpha: 0.15);
        fg = AppColors.info;
        break;
      case OutboundStatus.waveAssigned:
      case OutboundStatus.picking:
        bg = colorScheme.primary.withValues(alpha: 0.15);
        fg = colorScheme.primary;
        break;
      case OutboundStatus.picked:
      case OutboundStatus.packing:
      case OutboundStatus.packed:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        break;
      case OutboundStatus.shipped:
      case OutboundStatus.delivered:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
      case OutboundStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.r4)),
      child: Text(
        status.name.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
