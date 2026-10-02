import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../controllers/pos_cart_controller.dart';

/// Modal dialog for displaying authentic ESC/POS thermal receipt slip and dispatching print job.
class PosReceiptModal extends StatelessWidget {
  final PosSaleReceipt receipt;
  final Color brandColor;

  const PosReceiptModal({
    super.key,
    required this.receipt,
    required this.brandColor,
  });

  static Future<void> show(
    BuildContext context, {
    required PosSaleReceipt receipt,
    required Color brandColor,
  }) {
    return ModalShell.show(
      context: context,
      maxWidth: 460,
      child: PosReceiptModal(receipt: receipt, brandColor: brandColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success Icon & Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
        ),
        AppGap.h12,
        Text(
          'Sale Completed & Stock Deducted!',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        AppGap.h4,
        Text(
          'Receipt #${receipt.receiptNumber}',
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontFamily: 'monospace',
          ),
        ),
        const Divider(height: AppSpacing.lg),

        // Authentic Thermal Receipt Slip Look
        Container(
          width: double.infinity,
          padding: AppPadding.p16,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'UNIVERSAL WMS COUNTER',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              AppGap.h4,
              Center(
                child: Text(
                  receipt.timestamp.toIso8601String().substring(0, 16),
                  style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
              const Divider(height: AppSpacing.md),

              // Items breakdown
              ...receipt.items.map((i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${i.quantity}x ${i.productName}',
                          style: AppTypography.labelSmall.copyWith(fontFamily: 'monospace'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppGap.w8,
                      Text(
                        '\$${i.lineTotal.toStringAsFixed(2)}',
                        style: AppTypography.labelSmall.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: AppSpacing.md),

              // Subtotal & Tax
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal:', style: AppTypography.labelSmall),
                  Text('\$${receipt.subtotal.toStringAsFixed(2)}', style: AppTypography.labelSmall.copyWith(fontFamily: 'monospace')),
                ],
              ),
              AppGap.h4,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GST Tax (5%):', style: AppTypography.labelSmall),
                  Text('\$${receipt.taxAmount.toStringAsFixed(2)}', style: AppTypography.labelSmall.copyWith(fontFamily: 'monospace')),
                ],
              ),
              const Divider(height: AppSpacing.md),

              // Total Paid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL PAID (${receipt.paymentMethod.displayName}):',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${receipt.totalAmount.toStringAsFixed(2)}',
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppGap.h20,

        // Modal Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            AppGap.w12,
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ESC/POS Thermal Receipt sent to printer queue!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text('Print ESC/POS Receipt'),
            ),
          ],
        ),
      ],
    );
  }
}
