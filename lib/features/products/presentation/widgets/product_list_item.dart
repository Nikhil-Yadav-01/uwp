import 'package:flutter/material.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/models/product.dart';

/// Highly organized, responsive product list item adaptable for Mobile, Tablet, and Desktop.
class ProductListItem extends StatelessWidget {
  final Product product;
  final dynamic handler;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductListItem({
    super.key,
    required this.product,
    required this.handler,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 960) {
          return _buildDesktopRow(context, colorScheme, isDark);
        } else if (constraints.maxWidth >= 560) {
          return _buildTabletCard(context, colorScheme, isDark);
        } else {
          return _buildMobileCard(context, colorScheme, isDark);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP WIDE ROW LAYOUT (>= 960px)
  // ---------------------------------------------------------------------------
  Widget _buildDesktopRow(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final formattedQty = _getFormattedQty();
    final stockStatus = _getStockStatus();
    final margin = product.profitMargin;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: Container(
        padding: AppPadding.p16,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(
            color: product.isLowStock
                ? AppColors.warning.withValues(alpha: 0.5)
                : colorScheme.outline,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Archetype Icon
            Container(
              width: AppSizes.buttonHeightMd,
              height: AppSizes.buttonHeightMd,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadii.r8),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: colorScheme.primary,
                size: AppSizes.iconMd,
              ),
            ),
            AppGap.w16,

            // 2. Identity Column (Name, Category, SKU/Barcode, Specs)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _buildCategoryBadge(isDark, colorScheme),
                      AppGap.w8,
                      Text(
                        'SKU: ${product.sku}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      AppGap.w8,
                      Text('•', style: AppTypography.labelSmall),
                      AppGap.w8,
                      Text(
                        product.barcode,
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  AppGap.h4,
                  Text(
                    product.name,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppGap.h4,
                  _buildArchetypeSpecsWrap(isDark, colorScheme, maxItems: 3),
                ],
              ),
            ),
            AppGap.w16,

            // 3. Financial Column (Price, Cost, Margin)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PRICING',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppGap.h4,
                  Row(
                    children: [
                      Text(
                        AppFormatters.currency(product.sellingPrice),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppGap.w8,
                      _buildMarginBadge(margin),
                    ],
                  ),
                  AppGap.h4,
                  Text(
                    'Cost: ${AppFormatters.currency(product.costPrice)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.w16,

            // 4. Stock Health Column
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STOCK LEVEL',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildStockStatusPill(stockStatus),
                    ],
                  ),
                  AppGap.h4,
                  Text(
                    formattedQty,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppGap.h4,
                  _buildStockProgressBar(stockStatus),
                  AppGap.h4,
                  Text(
                    'Min Stock: ${product.minStockLevel.toStringAsFixed(0)} ${product.baseUom}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.w16,

            // 5. Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit item',
                  icon: const Icon(Icons.edit_outlined, size: AppSizes.iconSm),
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: AppSizes.iconSm),
                  onSelected: (action) {
                    if (action == 'edit') {
                      onEdit();
                    } else if (action == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: AppSizes.iconSm),
                          SizedBox(width: 8),
                          Text('Edit Item'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
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

  // ---------------------------------------------------------------------------
  // TABLET CARD LAYOUT (560px - 959px)
  // ---------------------------------------------------------------------------
  Widget _buildTabletCard(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final formattedQty = _getFormattedQty();
    final stockStatus = _getStockStatus();
    final margin = product.profitMargin;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: Container(
        padding: AppPadding.p16,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(
            color: product.isLowStock
                ? AppColors.warning.withValues(alpha: 0.5)
                : colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Icon + Name + Category + Menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSizes.buttonHeightSm,
                  height: AppSizes.buttonHeightSm,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: colorScheme.primary,
                    size: AppSizes.iconSm,
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildCategoryBadge(isDark, colorScheme),
                          AppGap.w8,
                          _buildStockStatusPill(stockStatus),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        product.name,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppGap.h4,
                      Text(
                        'SKU: ${product.sku}  •  Barcode: ${product.barcode}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionsMenu(),
              ],
            ),
            AppGap.h12,

            // Middle Metric Strip
            _buildMetricStrip(isDark, colorScheme, formattedQty, margin, stockStatus),
            AppGap.h12,

            // Bottom: Archetype Specs & Badges
            _buildArchetypeSpecsWrap(isDark, colorScheme),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE CARD LAYOUT (< 560px)
  // ---------------------------------------------------------------------------
  Widget _buildMobileCard(BuildContext context, ColorScheme colorScheme, bool isDark) {
    final formattedQty = _getFormattedQty();
    final stockStatus = _getStockStatus();
    final margin = product.profitMargin;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: Container(
        padding: AppPadding.p12,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(
            color: product.isLowStock
                ? AppColors.warning.withValues(alpha: 0.5)
                : colorScheme.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Category on left, Stock pill & Menu on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryBadge(isDark, colorScheme),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStockStatusPill(stockStatus),
                    _buildActionsMenu(),
                  ],
                ),
              ],
            ),
            AppGap.h8,

            // Item Title and SKU
            Text(
              product.name,
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppGap.h4,
            Text(
              'SKU: ${product.sku}  •  ${product.barcode}',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            AppGap.h12,

            // Compact 3-Column Metric Box
            _buildMetricStrip(isDark, colorScheme, formattedQty, margin, stockStatus),
            AppGap.h8,

            // Dynamic Attribute Tags
            _buildArchetypeSpecsWrap(isDark, colorScheme),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // REUSABLE SUB-COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildCategoryBadge(bool isDark, ColorScheme colorScheme) {
    return Container(
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
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStockStatusPill(_StockStatus status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case _StockStatus.outOfStock:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        label = 'OUT OF STOCK';
        icon = Icons.error_outline_rounded;
        break;
      case _StockStatus.lowStock:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        label = 'LOW STOCK';
        icon = Icons.warning_amber_rounded;
        break;
      case _StockStatus.inStock:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        label = 'IN STOCK';
        icon = Icons.check_circle_outline_rounded;
        break;
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
          Icon(icon, size: 12, color: fg),
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

  Widget _buildMarginBadge(double margin) {
    final isPositive = margin >= 0;
    final color = margin >= 25 ? AppColors.success : (isPositive ? AppColors.info : AppColors.error);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.r4),
      ),
      child: Text(
        '${isPositive ? '+' : ''}${margin.toStringAsFixed(1)}%',
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStockProgressBar(_StockStatus status) {
    final ratio = product.minStockLevel > 0
        ? (product.stockQuantity / (product.minStockLevel * 2.0)).clamp(0.0, 1.0)
        : (product.stockQuantity > 0 ? 1.0 : 0.0);

    Color color;
    switch (status) {
      case _StockStatus.outOfStock:
        color = AppColors.error;
        break;
      case _StockStatus.lowStock:
        color = AppColors.warning;
        break;
      case _StockStatus.inStock:
        color = AppColors.success;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.r4),
      child: LinearProgressIndicator(
        value: ratio,
        minHeight: 4,
        backgroundColor: color.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildMetricStrip(
    bool isDark,
    ColorScheme colorScheme,
    String formattedQty,
    double margin,
    _StockStatus stockStatus,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Segment 1: Stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOCK',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppGap.h4,
                Text(
                  formattedQty,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppGap.h4,
                _buildStockProgressBar(stockStatus),
              ],
            ),
          ),
          Container(
            height: AppSizes.iconLg,
            width: 1,
            color: colorScheme.outline.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          // Segment 2: Selling Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRICE',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppGap.h4,
                Text(
                  AppFormatters.currency(product.sellingPrice),
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                AppGap.h4,
                Text(
                  'Cost: ${AppFormatters.currency(product.costPrice)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: AppSizes.iconLg,
            width: 1,
            color: colorScheme.outline.withValues(alpha: 0.5),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          // Segment 3: Margin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MARGIN',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppGap.h4,
                _buildMarginBadge(margin),
                AppGap.h4,
                Text(
                  'Min: ${product.minStockLevel.toStringAsFixed(0)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchetypeSpecsWrap(bool isDark, ColorScheme colorScheme, {int? maxItems}) {
    final chips = <Widget>[];

    // Variants Badge
    if (product.hasVariants) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.r4),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.style_outlined, size: 12, color: AppColors.info),
              const SizedBox(width: 4),
              Text(
                '${product.variants.length} VARIANTS',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Recipe BOM Badge
    if (product.isRecipeKit) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.r4),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science_outlined, size: 12, color: AppColors.success),
              const SizedBox(width: 4),
              Text(
                'RECIPE BOM (${product.recipeBOM.length})',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Polymorphic Schema Attribute Tags
    var attrEntries = product.customAttributes.entries.toList();
    if (maxItems != null && attrEntries.length > maxItems) {
      attrEntries = attrEntries.take(maxItems).toList();
    }

    for (final entry in attrEntries) {
      final label = entry.key.replaceAll('_', ' ').toUpperCase();
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface.withValues(alpha: 0.6) : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppRadii.r4),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.7)),
          ),
          child: Text(
            '$label: ${entry.value}',
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }

  Widget _buildActionsMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      padding: EdgeInsets.zero,
      onSelected: (action) {
        if (action == 'edit') {
          onEdit();
        } else if (action == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: AppSizes.iconSm),
              SizedBox(width: 8),
              Text('Edit Item'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: AppSizes.iconSm, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  String _getFormattedQty() {
    return handler.formatQuantity(
      product.stockQuantity,
      uom: product.baseUom,
      customAttributes: product.customAttributes,
    );
  }

  _StockStatus _getStockStatus() {
    if (product.stockQuantity <= 0) {
      return _StockStatus.outOfStock;
    } else if (product.isLowStock) {
      return _StockStatus.lowStock;
    } else {
      return _StockStatus.inStock;
    }
  }
}

enum _StockStatus {
  inStock,
  lowStock,
  outOfStock,
}
