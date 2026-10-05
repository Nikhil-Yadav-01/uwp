import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/models/purchase_order.dart';
import 'po_detail_modal.dart';
import 'po_form_modal.dart';

/// Modern, structured, and responsive Purchase Order Pipeline Card.
class InboundPoCard extends StatelessWidget {
  final PurchaseOrder po;
  final VoidCallback onDockReceive;

  const InboundPoCard({
    super.key,
    required this.po,
    required this.onDockReceive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final canDockReceive = po.status == InboundStatus.inTransit || po.status == InboundStatus.approved;
    final canEdit = po.status == InboundStatus.draft || po.status == InboundStatus.approved;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        return Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          child: InkWell(
            onTap: () => PoDetailModal.show(context, purchaseOrder: po),
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
                  // 1. Header: PO Number, Supplier, Date & Status Chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: colorScheme.primary, size: AppSizes.iconSm + 2),
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
                                  po.poNumber,
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: po.poNumber));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Copied ${po.poNumber} to clipboard'),
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
                                _buildStatusChip(po.status, colorScheme),
                              ],
                            ),
                            AppGap.h4,
                            Text(
                              'Supplier: ${po.vendorName}',
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
                              AppFormatters.currency(po.totalAmount),
                              style: AppTypography.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              '${po.totalOrderedUnits.toStringAsFixed(0)} units total',
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

                  // 2. Line Items Preview Table / Cards
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
                              'ORDERED ITEMS (${po.items.length})',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              'UNIT COST',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        AppGap.h8,
                        ...po.items.take(3).map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${item.productName} (${item.sku}) — ${item.orderedQty.toStringAsFixed(0)} ${item.uom}',
                                    style: AppTypography.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppGap.w8,
                                Text(
                                  AppFormatters.currency(item.unitPrice),
                                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (po.items.length > 3) ...[
                          AppGap.h4,
                          Text(
                            '+ ${po.items.length - 3} more line items...',
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
                              AppFormatters.currency(po.totalAmount),
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
                              '${po.totalOrderedUnits.toStringAsFixed(0)} units',
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
                      // Date & Dock info
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          AppGap.w4,
                          Text(
                            po.orderDate.toString().substring(0, 10),
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          if (po.receivingDockId != null) ...[
                            AppGap.w12,
                            Icon(Icons.local_shipping_outlined, size: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            AppGap.w4,
                            Text(
                              po.receivingDockId!,
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Action Buttons
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          if (canEdit)
                            OutlinedButton.icon(
                              onPressed: () => PoFormModal.show(context, purchaseOrder: po),
                              icon: const Icon(Icons.edit_rounded, size: 13),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: () => PoDetailModal.show(context, purchaseOrder: po),
                            icon: const Icon(Icons.visibility_outlined, size: 13),
                            label: const Text('Details'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            ),
                          ),
                          if (canDockReceive)
                            ElevatedButton.icon(
                              onPressed: onDockReceive,
                              icon: const Icon(Icons.input_rounded, size: 13),
                              label: const Text('Dock Receive'),
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

  Widget _buildStatusChip(InboundStatus status, ColorScheme colorScheme) {
    Color bg;
    Color fg;

    switch (status) {
      case InboundStatus.draft:
      case InboundStatus.inTransit:
        bg = AppColors.info.withValues(alpha: 0.15);
        fg = AppColors.info;
        break;
      case InboundStatus.approved:
      case InboundStatus.atDock:
      case InboundStatus.receiving:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        break;
      case InboundStatus.qcPending:
        bg = colorScheme.primary.withValues(alpha: 0.15);
        fg = colorScheme.primary;
        break;
      case InboundStatus.qcPassed:
      case InboundStatus.putawayReady:
      case InboundStatus.completed:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
      case InboundStatus.qcFailed:
      case InboundStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.r4)),
      child: Text(
        status.label,
        style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
