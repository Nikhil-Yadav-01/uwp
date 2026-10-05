import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/product.dart';

/// Modal inspecting product details, dynamic attributes, variants, and BOM using ModalShell.
class ProductDetailModal extends ConsumerWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductDetailModal({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Product product,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return ModalShell.show(
      context: context,
      maxWidth: 680,
      headerWidget: Consumer(
        builder: (context, ref, child) {
          final archetypeState = ref.watch(archetypeProvider);
          final archetype = archetypeState.archetype;
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.r16)),
              border: Border(bottom: BorderSide(color: colorScheme.outline)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Archetype Icon Box
                Container(
                  width: AppSizes.buttonHeightSm + 4,
                  height: AppSizes.buttonHeightSm + 4,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(archetype.icon, color: colorScheme.primary, size: AppSizes.iconMd),
                ),
                AppGap.w12,

                // Title & Badges Wrap (Prevents all header overflows)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTypography.headlineSmall.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppGap.h4,
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                              border: Border.all(color: colorScheme.outline),
                            ),
                            child: Text(
                              product.category.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Text(
                            'SKU: ${product.sku}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Text('•', style: AppTypography.bodySmall),
                          Text(
                            product.barcode,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontFamily: 'monospace',
                            ),
                          ),
                          _buildStockStatusPill(product),
                        ],
                      ),
                    ],
                  ),
                ),
                AppGap.w8,

                // Close Button
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        if (onDelete != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm),
            label: const Text('Delete'),
          ),
        if (onEdit != null)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onEdit();
            },
            icon: const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
            label: const Text('Edit Item'),
          ),
      ],
      child: ProductDetailModal(
        product: product,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archetypeState = ref.watch(archetypeProvider);
    final archetype = archetypeState.archetype;
    final handler = archetypeState.handler;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final formattedQty = handler.formatQuantity(
      product.stockQuantity,
      uom: product.baseUom,
      customAttributes: product.customAttributes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppGap.h8,

        // 1. Responsive Metrics Grid (2x2 on mobile, 4-column on tablet/desktop)
        _buildMetricsGrid(context, colorScheme, isDark, formattedQty),
        AppGap.h20,

        // 2. Archetype Dynamic Custom Attributes
        Text(
          '${archetype.name} Attributes',
          style: AppTypography.labelLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppGap.h8,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface.withValues(alpha: 0.4) : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: product.customAttributes.isEmpty
              ? Text(
                  'No custom attributes defined for this item.',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                )
              : Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: product.customAttributes.entries.map((entry) {
                    final label = entry.key.replaceAll('_', ' ').toUpperCase();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.r8),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppGap.h4,
                          Text(
                            '${entry.value}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),

        // 3. Variants Matrix (if present)
        if (product.variants.isNotEmpty) ...[
          AppGap.h24,
          Text(
            'Product Variants Matrix (${product.variants.length})',
            style: AppTypography.labelLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppGap.h8,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.r12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              children: product.variants.map((variant) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.style_outlined, size: AppSizes.iconSm),
                  title: Text(variant.displayName, style: AppTypography.bodyMedium),
                  subtitle: Text(
                    'SKU: ${variant.sku} • Barcode: ${variant.barcode}',
                    style: AppTypography.bodySmall,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      '${variant.stockQuantity} ${product.baseUom}',
                      style: AppTypography.labelMedium.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // 4. Recipe BOM Components (if present)
        if (product.recipeBOM.isNotEmpty) ...[
          AppGap.h24,
          Text(
            'Bill of Materials (Recipe BOM)',
            style: AppTypography.labelLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppGap.h8,
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.r12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              children: product.recipeBOM.map((comp) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.science_outlined, size: AppSizes.iconSm),
                  title: Text(comp.childProductName, style: AppTypography.bodyMedium),
                  subtitle: Text(
                    'Child SKU: ${comp.childSku} • Waste: ${comp.wasteFactorPercent}%',
                    style: AppTypography.bodySmall,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      '${comp.quantityRequired} ${comp.uom}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        AppGap.h16,
      ],
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
    String formattedQty,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 460;

        final stockTile = _buildMetricTile(
          context,
          label: 'CURRENT STOCK',
          value: formattedQty,
          color: product.isLowStock ? AppColors.warning : AppColors.success,
          icon: Icons.inventory_2_outlined,
          subValue: 'Min: ${product.minStockLevel.toStringAsFixed(0)} ${product.baseUom}',
        );

        final sellTile = _buildMetricTile(
          context,
          label: 'SELLING PRICE',
          value: AppFormatters.currency(product.sellingPrice),
          color: colorScheme.primary,
          icon: Icons.sell_outlined,
          subValue: 'Base / ${product.baseUom}',
        );

        final costTile = _buildMetricTile(
          context,
          label: 'COST PRICE',
          value: AppFormatters.currency(product.costPrice),
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          icon: Icons.receipt_long_outlined,
          subValue: 'Unit Cost',
        );

        final marginTile = _buildMetricTile(
          context,
          label: 'PROFIT MARGIN',
          value: '${product.profitMargin >= 0 ? '+' : ''}${product.profitMargin.toStringAsFixed(1)}%',
          color: product.profitMargin >= 25
              ? AppColors.success
              : (product.profitMargin >= 0 ? AppColors.info : AppColors.error),
          icon: Icons.trending_up_rounded,
          subValue: 'Markup Return',
        );

        if (isNarrow) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: stockTile),
                  AppGap.w8,
                  Expanded(child: sellTile),
                ],
              ),
              AppGap.h8,
              Row(
                children: [
                  Expanded(child: costTile),
                  AppGap.w8,
                  Expanded(child: marginTile),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: stockTile),
            AppGap.w8,
            Expanded(child: sellTile),
            AppGap.w8,
            Expanded(child: costTile),
            AppGap.w8,
            Expanded(child: marginTile),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    String? subValue,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface.withValues(alpha: 0.3) : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppGap.h4,
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subValue != null) ...[
            AppGap.h4,
            Text(
              subValue,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildStockStatusPill(Product product) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (product.stockQuantity <= 0) {
      bg = AppColors.error.withValues(alpha: 0.15);
      fg = AppColors.error;
      label = 'OUT OF STOCK';
      icon = Icons.error_outline_rounded;
    } else if (product.isLowStock) {
      bg = AppColors.warning.withValues(alpha: 0.15);
      fg = AppColors.warning;
      label = 'LOW STOCK';
      icon = Icons.warning_amber_rounded;
    } else {
      bg = AppColors.success.withValues(alpha: 0.15);
      fg = AppColors.success;
      label = 'IN STOCK';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.r4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
