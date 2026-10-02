import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';

/// Tactile, responsive product card for the POS Counter Catalog.
class PosProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Color brandColor;
  final VoidCallback onAddToCart;

  const PosProductCard({
    super.key,
    required this.product,
    required this.brandColor,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final name = product['name'] as String? ?? 'Product';
    final sku = product['sku'] as String? ?? 'SKU-001';
    final price = (product['unitPrice'] as num?)?.toDouble() ?? 10.0;
    final uom = product['uom'] as String? ?? 'unit';

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: InkWell(
        onTap: onAddToCart,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        child: Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppGap.h4,
                  Text(
                    'SKU: $sku • $uom',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              AppGap.h8,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                    ),
                  ),
                  AppGap.w8,
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: brandColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_shopping_cart_rounded,
                      size: AppSizes.iconSm,
                      color: brandColor,
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
}
