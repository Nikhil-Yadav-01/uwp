import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/purchase_order.dart';
import 'po_detail_modal.dart';
import 'qc_inspection_modal.dart';

/// Modern, structured, and responsive QC Inspection Gate Card.
class InboundQcCard extends StatelessWidget {
  final PurchaseOrder po;

  const InboundQcCard({
    super.key,
    required this.po,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isHealthcare = po.archetypeId == 'healthcare_pharma';

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
              // Header: PO#, Dual-Witness tag & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        po.poNumber,
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isHealthcare)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.r4),
                          ),
                          child: Text(
                            'DUAL-WITNESS MANDATORY',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  _buildStatusChip(po.status, colorScheme),
                ],
              ),
              AppGap.h4,
              Text(
                'Supplier: ${po.vendorName} • Arrived at: ${po.receivingDockId ?? "Dock Staging Bay 01"}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const Divider(height: AppSpacing.lg),

              // Summary
              Text(
                '${po.items.length} items staged (${po.totalOrderedUnits.toStringAsFixed(0)} units total for testing)',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              AppGap.h12,

              // Action Footer
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => PoDetailModal.show(context, purchaseOrder: po),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text('View PO Details'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => QcInspectionModal.show(context, purchaseOrder: po),
                    icon: const Icon(Icons.fact_check_rounded, size: AppSizes.iconSm),
                    label: const Text('Open QC Gate'),
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(InboundStatus status, ColorScheme colorScheme) {
    final bg = colorScheme.primary.withValues(alpha: 0.15);
    final fg = colorScheme.primary;

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
