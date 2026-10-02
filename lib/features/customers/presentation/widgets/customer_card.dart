import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/customer.dart';
import 'customer_detail_modal.dart';
import 'customer_form_modal.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const CustomerCard({
    super.key,
    required this.customer,
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
          onTap: () => CustomerDetailModal.show(
            context,
            customer: customer,
            onEdit: () => CustomerFormModal.show(context, customer),
            onDelete: onDelete,
          ),
          child: Padding(
            padding: AppPadding.p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name + Tier Badge + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: customer.tier.color.withValues(alpha: 0.15),
                      child: Text(
                        customer.name.substring(0, customer.name.length >= 2 ? 2 : 1).toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: customer.tier.color, fontSize: 13),
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
                                customer.name,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: customer.tier.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadii.r4),
                                  border: Border.all(color: customer.tier.color.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  customer.tier.label,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: customer.tier.color),
                                ),
                              ),
                            ],
                          ),
                          AppGap.h4,
                          Text(
                            '${customer.code} • Contact: ${customer.contactPerson} • ${customer.city}',
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
                          color: (customer.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                          border: Border.all(color: (customer.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: customer.isActive ? AppColors.success : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            AppGap.w4,
                            Text(
                              customer.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: customer.isActive ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Middle Info Bar: GSTIN, Email, Phone, Orders
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 480;

                    final gstinPill = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_outlined, size: 14, color: AppColors.primary),
                        AppGap.w4,
                        Text('GSTIN: ${customer.gstin}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    );

                    final emailPill = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        AppGap.w4,
                        Flexible(
                          child: Text(
                            customer.email,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );

                    final phonePill = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        AppGap.w4,
                        Text(customer.phone, style: const TextStyle(fontSize: 11)),
                      ],
                    );

                    final ordersPill = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                      ),
                      child: Text(
                        '${customer.totalOrders} Orders',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          gstinPill,
                          AppGap.h4,
                          emailPill,
                          AppGap.h6,
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              phonePill,
                              ordersPill,
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        gstinPill,
                        AppGap.w16,
                        Expanded(child: emailPill),
                        phonePill,
                        AppGap.w12,
                        ordersPill,
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
