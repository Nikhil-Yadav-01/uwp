import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/vendor.dart';
import 'vendor_detail_modal.dart';
import 'vendor_form_modal.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const VendorCard({
    super.key,
    required this.vendor,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.r12),
          onTap: () => VendorDetailModal.show(
            context,
            vendor: vendor,
            onEdit: () => VendorFormModal.show(context, vendor),
            onDelete: onDelete,
          ),
          child: Padding(
            padding: AppPadding.p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name + Rating + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        vendor.name.substring(0, vendor.name.length >= 2 ? 2 : 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                vendor.name,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadii.r4),
                                ),
                                child: Text(
                                  '⭐ ${vendor.rating}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                                ),
                              ),
                            ],
                          ),
                          AppGap.h4,
                          Text(
                            '${vendor.code} • Contact: ${vendor.contactPerson} • ${vendor.city}',
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AppGap.w8,
                    // Active / Inactive Pill
                    InkWell(
                      onTap: onToggleStatus,
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (vendor.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                          border: Border.all(color: (vendor.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: vendor.isActive ? AppColors.success : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppGap.w4,
                            Text(
                              vendor.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: vendor.isActive ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Middle Info Bar: GSTIN, Email, Terms, Lead Time, PO count
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 500;

                    final gstinPill = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_outlined, size: 14, color: AppColors.primary),
                        AppGap.w4,
                        Text('GSTIN: ${vendor.gstin}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    );

                    final termsPill = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                      ),
                      child: Text(
                        vendor.paymentTerms.label,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.info),
                      ),
                    );

                    final leadTimePill = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        AppGap.w4,
                        Text('${vendor.leadTimeDays}d lead', style: const TextStyle(fontSize: 11)),
                      ],
                    );

                    final poCountPill = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                      ),
                      child: Text(
                        '${vendor.totalPurchaseOrders} POs',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          gstinPill,
                          AppGap.h6,
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              termsPill,
                              leadTimePill,
                              poCountPill,
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        gstinPill,
                        AppGap.w16,
                        termsPill,
                        const Spacer(),
                        leadTimePill,
                        AppGap.w12,
                        poCountPill,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
