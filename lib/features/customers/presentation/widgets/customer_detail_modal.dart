import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/customer.dart';
import 'customer_form_modal.dart';

class CustomerDetailModal extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomerDetailModal({
    super.key,
    required this.customer,
    this.onEdit,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Customer customer,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CustomerDetailModal(
        customer: customer,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r16)),
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: AppPadding.p24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: customer.tier.color.withValues(alpha: 0.15),
                    child: Text(
                      customer.name.substring(0, customer.name.length >= 2 ? 2 : 1).toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: customer.tier.color, fontSize: 16),
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                customer.name,
                                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            AppGap.w8,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (customer.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadii.r4),
                              ),
                              child: Text(
                                customer.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: customer.isActive ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppGap.h4,
                        Text(
                          '${customer.code} • ${customer.tier.label}',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 28),

              // KPI Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Total Orders',
                      value: '${customer.totalOrders}',
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.info,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: _buildStatCard(
                      label: 'Outstanding Balance',
                      value: '\$${customer.outstandingBalance.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet_outlined,
                      color: customer.outstandingBalance > 0 ? AppColors.warning : AppColors.success,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              AppGap.h16,

              // Detailed Profile Fields
              _buildDetailTile(Icons.person_outline_rounded, 'Contact Person', customer.contactPerson, isDark),
              _buildDetailTile(Icons.email_outlined, 'Email Address', customer.email, isDark),
              _buildDetailTile(Icons.phone_outlined, 'Phone Number', customer.phone, isDark),
              _buildDetailTile(Icons.receipt_outlined, 'GSTIN / Tax ID', customer.gstin, isDark),
              _buildDetailTile(Icons.location_city_outlined, 'City / Region', customer.city, isDark),
              _buildDetailTile(Icons.pin_drop_outlined, 'Shipping & Billing Address', customer.address, isDark),
              AppGap.h24,

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onDelete != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDelete?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          CustomerFormModal.show(context, customer);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                      ),
                      AppGap.w8,
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
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

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: AppPadding.p12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          AppGap.w10,
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
