import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/pos_cart_controller.dart';
import 'pos_checkout_modal.dart';
import 'pos_receipt_modal.dart';

/// Responsive Cart Summary & Checkout Action View for POS Counter.
class PosCartView extends ConsumerWidget {
  final Color brandColor;

  const PosCartView({
    super.key,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cartState = ref.watch(posCartProvider);

    return Container(
      padding: AppPadding.p16,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart_outlined, size: AppSizes.iconSm + 2, color: colorScheme.primary),
                  AppGap.w8,
                  Text(
                    'Current Order',
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                ),
                child: Text(
                  '${cartState.totalItemCount} Items',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),

          // Items List
          if (cartState.items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 36, color: Colors.grey.withValues(alpha: 0.5)),
                  AppGap.h8,
                  Text('Cart is empty', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  AppGap.h4,
                  Text(
                    'Tap products or scan barcode to add',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartState.items.length,
              separatorBuilder: (context, index) => const Divider(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = cartState.items[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppGap.h4,
                            Text(
                              '\$${item.unitPrice.toStringAsFixed(2)} / ${item.uom}',
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppGap.w4,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 16),
                            onPressed: () => ref.read(posCartProvider.notifier).updateQuantity(item.productId, item.quantity - 1),
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            '${item.quantity}',
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 16),
                            onPressed: () => ref.read(posCartProvider.notifier).updateQuantity(item.productId, item.quantity + 1),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      AppGap.w4,
                      SizedBox(
                        width: 65,
                        child: Text(
                          '\$${item.lineTotal.toStringAsFixed(2)}',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: brandColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const Divider(height: AppSpacing.lg),

          // Financial Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: AppTypography.bodySmall),
              Text('\$${cartState.subtotal.toStringAsFixed(2)}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          AppGap.h4,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Tax (5% GST):', style: AppTypography.bodySmall),
              Text('\$${cartState.taxAmount.toStringAsFixed(2)}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          AppGap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total:', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              Text(
                '\$${cartState.grandTotal.toStringAsFixed(2)}',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                ),
              ),
            ],
          ),
          AppGap.h16,

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: cartState.items.isEmpty || cartState.isProcessing
                  ? null
                  : () {
                      PosCheckoutModal.show(
                        context,
                        cartState: cartState,
                        brandColor: brandColor,
                        onPaymentSelected: (method) async {
                          final receipt = await ref.read(posCartProvider.notifier).checkout(method);
                          if (context.mounted) {
                            PosReceiptModal.show(context, receipt: receipt, brandColor: brandColor);
                          }
                        },
                      );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: cartState.isProcessing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.point_of_sale_rounded, size: 18),
              label: Text(
                cartState.isProcessing ? 'Processing Payment...' : 'Pay & Complete Sale (\$${cartState.grandTotal.toStringAsFixed(2)})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
