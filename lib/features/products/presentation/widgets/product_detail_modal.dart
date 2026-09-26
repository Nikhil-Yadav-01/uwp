import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/product.dart';

/// Modal dialog/bottom sheet inspecting product details, dynamic attributes, variants, and BOM.
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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailModal(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 700,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.r16)),
              border: Border(bottom: BorderSide(color: colorScheme.outline)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(archetype.icon, color: colorScheme.primary, size: 22),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTypography.headlineMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppGap.h4,
                      Row(
                        children: [
                          Text(
                            'SKU: ${product.sku}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppGap.w8,
                          Text('•', style: AppTypography.bodySmall),
                          AppGap.w8,
                          Text(
                            'Category: ${product.category}',
                            style: AppTypography.bodySmall.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          // Content Scroll
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stock & Pricing Summary Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          label: 'Current Stock',
                          value: '${product.stockQuantity} ${product.baseUom}',
                          color: product.isLowStock ? AppColors.warning : AppColors.success,
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      AppGap.w12,
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          label: 'Selling Price',
                          value: '\$${product.sellingPrice.toStringAsFixed(2)}',
                          color: colorScheme.primary,
                          icon: Icons.sell_outlined,
                        ),
                      ),
                      AppGap.w12,
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          label: 'Margin',
                          value: '${product.profitMargin.toStringAsFixed(1)}%',
                          color: AppColors.info,
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                  AppGap.h20,

                  // Vertical Dynamic Custom Attributes (Polymorphic Schema)
                  Text(
                    '${archetype.name} Attributes',
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppGap.h8,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withValues(alpha: 0.4)
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppRadii.r12),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: product.customAttributes.isEmpty
                        ? Text(
                            'No custom attributes defined.',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          )
                        : Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: product.customAttributes.entries.map((entry) {
                              final label = entry.key.replaceAll('_', ' ').toUpperCase();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

                  // Variants Matrix (if present)
                  if (product.variants.isNotEmpty) ...[
                    AppGap.h24,
                    Text(
                      'Product Variants Matrix (${product.variants.length})',
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                            leading: const Icon(Icons.style_outlined, size: 18),
                            title: Text(variant.displayName, style: AppTypography.bodyMedium),
                            subtitle: Text('SKU: ${variant.sku} • Barcode: ${variant.barcode}'),
                            trailing: Text(
                              '${variant.stockQuantity} ${product.baseUom}',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Recipe / BOM Components (if present)
                  if (product.recipeBOM.isNotEmpty) ...[
                    AppGap.h24,
                    Text(
                      'Bill of Materials (Recipe BOM)',
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                            leading: const Icon(Icons.blender_outlined, size: 18),
                            title: Text(comp.childProductName, style: AppTypography.bodyMedium),
                            subtitle: Text('Child SKU: ${comp.childSku} • Waste: ${comp.wasteFactorPercent}%'),
                            trailing: Text(
                              '${comp.quantityRequired} ${comp.uom}',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action Buttons Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadii.r16)),
              border: Border(top: BorderSide(color: colorScheme.outline)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete!();
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                  ),
                AppGap.w12,
                if (onEdit != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit!();
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Item'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.3)
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              AppGap.w4,
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          AppGap.h4,
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
