import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/models/packing_session.dart';
import '../../domain/models/sales_order.dart';
import 'shipping_label_modal.dart';
import 'so_detail_modal.dart';

/// Modern, structured, and responsive Outbound Shipping / Manifest Card.
class OutboundShippingCard extends StatelessWidget {
  final SalesOrder order;
  final PackingSession? session;

  const OutboundShippingCard({
    super.key,
    required this.order,
    this.session,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final tracking = session?.trackingNumber ?? 'TRK-2026-DISPATCH-${order.id.hashCode.abs().toString().substring(0, 5)}';
    final carrier = session?.shippingCarrier ?? 'Universal Freight Logistics';
    final boxCount = session?.boxCount ?? 1;
    final weightKg = session?.totalWeightKg ?? 3.5;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: Container(
        padding: AppPadding.p16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: SO#, Carrier Badge, Shipped Chip
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
                        padding: const EdgeInsets.all(AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.success,
                          size: AppSizes.iconSm + 2,
                        ),
                      ),
                      AppGap.w4,
                      Text(
                        order.soNumber,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                        ),
                        child: Text(
                          carrier,
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.w8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                  ),
                  child: Text(
                    'DISPATCHED',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                  ],
                ),
                AppGap.h4,
                Text(
                  'Recipient: ${order.customerName} • Destination: ${order.destinationWardOrAddress}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const Divider(height: AppSpacing.lg),

                // Shipping Manifest Details (Tracking, Boxes, Weight)
                Container(
                  padding: AppPadding.p12,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.qr_code_rounded, size: 16, color: colorScheme.primary),
                              AppGap.w8,
                              Text(
                                'Tracking #:',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              AppGap.w4,
                              Text(
                                tracking,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              AppGap.w4,
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: tracking));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Copied tracking # $tracking'),
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
                          Text(
                            '$boxCount Box(es) • ${weightKg.toStringAsFixed(1)} kg',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppGap.h12,

                // Footer Actions
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Text(
                      'Value: ${AppFormatters.currency(order.totalAmount)} • ${order.items.length} item(s)',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => SoDetailModal.show(context, salesOrder: order),
                          icon: const Icon(Icons.visibility_outlined, size: 13),
                          label: const Text('Order Details'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final sess = session ??
                                PackingSession(
                                  id: 'session_${order.id}',
                                  orderId: order.id,
                                  soNumber: order.soNumber,
                                  customerName: order.customerName,
                                  destination: order.destinationWardOrAddress,
                                  packerName: 'Shipping Station #1',
                                  status: PackingStatus.shippingLabelGenerated,
                                  startedAt: DateTime.now(),
                                  completedAt: DateTime.now(),
                                  trackingNumber: tracking,
                                  shippingCarrier: carrier,
                                  totalWeightKg: weightKg,
                                  boxCount: boxCount,
                                  magicTrackingUrl: 'https://wms.universal.io/track/$tracking',
                                  scannedItems: [],
                                );
                            ShippingLabelModal.show(context, session: sess);
                          },
                          icon: const Icon(Icons.print_rounded, size: 13),
                          label: const Text('View / Print 4x6 Label'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
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
        );
  }
}
