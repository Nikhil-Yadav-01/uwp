import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/packing_session.dart';
import '../controllers/outbound_controller.dart';
import 'shipping_label_modal.dart';

/// Modern, structured, and responsive Packing Station Card.
class OutboundPackingCard extends ConsumerStatefulWidget {
  final PackingSession session;

  const OutboundPackingCard({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<OutboundPackingCard> createState() => _OutboundPackingCardState();
}

class _OutboundPackingCardState extends ConsumerState<OutboundPackingCard> {
  final _barcodeController = TextEditingController();
  final _weightController = TextEditingController(text: '4.5');
  final _carrierController = TextEditingController(text: 'Universal Express Cargo');

  @override
  void dispose() {
    _barcodeController.dispose();
    _weightController.dispose();
    _carrierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final session = widget.session;
    final isComplete = session.isCompleted ||
        session.status == PackingStatus.shippingLabelGenerated ||
        session.status == PackingStatus.dispatched;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        return Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          child: Container(
            padding: AppPadding.p16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.r12),
              border: Border.all(
                color: isComplete
                    ? colorScheme.outline
                    : colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Session Barcode, Order Number, Customer
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
                            'Packing: ${session.soNumber}',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: isComplete
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              isComplete ? 'READY FOR SHIP' : 'IN PACKING',
                              style: AppTypography.labelSmall.copyWith(
                                color: isComplete ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGap.w8,
                    Text(
                      '${session.scannedItems.length} scanned',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isComplete ? AppColors.success : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                AppGap.h4,
                Text(
                  'Customer: ${session.customerName} • Destination: ${session.destination}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const Divider(height: AppSpacing.lg),

                // Barcode Scan Bar
                if (!isComplete) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _barcodeController,
                          decoration: const InputDecoration(
                            hintText: 'Scan Barcode or SKU to verify item...',
                            prefixIcon: Icon(Icons.qr_code_scanner_rounded, size: AppSizes.iconSm),
                            isDense: true,
                          ),
                          onSubmitted: (barcode) => _handleScan(barcode),
                        ),
                      ),
                      AppGap.w8,
                      ElevatedButton.icon(
                        onPressed: () => _handleScan(_barcodeController.text),
                        icon: const Icon(Icons.check_rounded, size: AppSizes.iconSm),
                        label: const Text('Verify'),
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        ),
                      ),
                    ],
                  ),
                  AppGap.h12,
                ],

                // Verified Checklist
                Container(
                  padding: AppPadding.p12,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PACKING VERIFICATION CHECKLIST (${session.scannedItems.length})',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      AppGap.h8,
                      if (session.scannedItems.isEmpty)
                        Text(
                          'No items scanned yet. Scan barcodes to verify before sealing.',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        ...session.scannedItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                AppGap.w8,
                                Expanded(
                                  child: Text(
                                    '${item.productName} (${item.sku})',
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                AppGap.w8,
                                Text(
                                  '${item.quantity.toStringAsFixed(0)} ${item.uom}',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                AppGap.h12,

                // Manifest Action
                if (!isComplete) ...[
                  if (isNarrow)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _handleCompletePacking(),
                          icon: const Icon(Icons.local_shipping_rounded, size: AppSizes.iconSm),
                          label: const Text('Seal Parcel & Ship'),
                        ),
                      ],
                    )
                  else
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleCompletePacking(),
                        icon: const Icon(Icons.local_shipping_rounded, size: AppSizes.iconSm),
                        label: const Text('Seal Parcel & Ship'),
                      ),
                    ),
                ] else ...[
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Text(
                        'Tracking: ${session.trackingNumber ?? "N/A"}',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => ShippingLabelModal.show(context, session: session),
                        icon: const Icon(Icons.print_rounded, size: AppSizes.iconSm),
                        label: const Text('View / Print Label'),
                        style: ElevatedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleScan(String barcode) async {
    if (barcode.trim().isEmpty) return;
    final success = await ref.read(outboundNotifierProvider.notifier).scanPackItem(
      barcode.trim(),
    );
    _barcodeController.clear();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan Error: Barcode does not match expected items in this order.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCompletePacking() async {
    final weight = double.tryParse(_weightController.text) ?? 4.5;
    final carrier = _carrierController.text.trim().isNotEmpty ? _carrierController.text.trim() : 'Universal Express Cargo';

    final success = await ref.read(outboundNotifierProvider.notifier).dispatchShipment(
      weightKg: weight,
      carrier: carrier,
      boxCount: 1,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Packing completed & shipping manifest generated!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
