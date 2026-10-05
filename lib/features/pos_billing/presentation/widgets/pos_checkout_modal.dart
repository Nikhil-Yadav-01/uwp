import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../controllers/pos_cart_controller.dart';

/// Modal dialog for choosing a payment tender and completing the POS transaction.
class PosCheckoutModal extends StatelessWidget {
  final PosCartState cartState;
  final Color brandColor;
  final ValueChanged<PaymentMethod> onPaymentSelected;

  const PosCheckoutModal({
    super.key,
    required this.cartState,
    required this.brandColor,
    required this.onPaymentSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required PosCartState cartState,
    required Color brandColor,
    required ValueChanged<PaymentMethod> onPaymentSelected,
  }) {
    return ModalShell.show(
      context: context,
      maxWidth: 500,
      child: PosCheckoutModal(
        cartState: cartState,
        brandColor: brandColor,
        onPaymentSelected: onPaymentSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: brandColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(Icons.point_of_sale_rounded, color: brandColor, size: AppSizes.iconMd),
                ),
                AppGap.w12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Payment Tender',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      'Instant payment verification & stock deduction',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
              onPressed: () => Navigator.pop(context),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const Divider(height: AppSpacing.lg),

        // Total Due Banner
        Container(
          width: double.infinity,
          padding: AppPadding.p16,
          decoration: BoxDecoration(
            color: brandColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: brandColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL DUE NOW:',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                ),
              ),
              Text(
                AppFormatters.currency(cartState.grandTotal),
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                ),
              ),
            ],
          ),
        ),
        AppGap.h16,

        // Payment Method Options
        ...PaymentMethod.values.map((method) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onPaymentSelected(method);
                },
                borderRadius: BorderRadius.circular(AppRadii.r8),
                child: Container(
                  padding: AppPadding.p12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: brandColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                        child: Icon(method.icon, color: brandColor, size: AppSizes.iconSm + 2),
                      ),
                      AppGap.w12,
                      Expanded(
                        child: Text(
                          method.displayName,
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: colorScheme.outline, size: AppSizes.iconSm + 4),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
