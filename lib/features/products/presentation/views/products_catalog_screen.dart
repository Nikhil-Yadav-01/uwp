import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/product.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_detail_modal.dart';
import 'product_form_screen.dart';

/// Master Products & Inventory Catalog Screen
class ProductsCatalogScreen extends ConsumerStatefulWidget {
  const ProductsCatalogScreen({super.key});

  @override
  ConsumerState<ProductsCatalogScreen> createState() => _ProductsCatalogScreenState();
}

class _ProductsCatalogScreenState extends ConsumerState<ProductsCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(productCatalogProvider);
    final catalogNotifier = ref.read(productCatalogProvider.notifier);
    final archetypeState = ref.watch(archetypeProvider);
    final archetype = archetypeState.archetype;
    final handler = archetypeState.handler;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final categories = ['All', 'Raw Materials', 'Finished Goods', 'Packaging', 'Controlled Stock', 'General'];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Master Inventory Catalog',
                      style: AppTypography.headlineLarge.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      'Polymorphic schema, wrappers & variants adapting to ${archetype.name}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToForm(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text('Add ${archetype.name} Item'),
                ),
              ],
            ),
            AppGap.h20,

            // Search & Filter Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.r12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search items by name, SKU, or scan barcode...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  catalogNotifier.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: catalogNotifier.setSearchQuery,
                    ),
                  ),
                  AppGap.w12,
                  // Low Stock Toggle Button
                  FilterChip(
                    label: Text(
                      'Low Stock Alert',
                      style: AppTypography.labelSmall.copyWith(
                        color: catalogState.lowStockOnly ? Colors.white : AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: catalogState.lowStockOnly,
                    selectedColor: AppColors.warning,
                    onSelected: (_) => catalogNotifier.toggleLowStockFilter(),
                    avatar: Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: catalogState.lowStockOnly ? Colors.white : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            AppGap.h12,

            // Category Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = catalogState.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => catalogNotifier.setSelectedCategory(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            AppGap.h20,

            // Product Cards List
            if (catalogState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (catalogState.products.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  children: [
                    Icon(archetype.icon, size: 48, color: colorScheme.primary.withValues(alpha: 0.5)),
                    AppGap.h16,
                    Text('No products found matching filters', style: AppTypography.headlineSmall),
                    AppGap.h8,
                    Text(
                      'Try resetting search criteria or create a new item for ${archetype.name}.',
                      style: AppTypography.bodySmall,
                    ),
                    AppGap.h16,
                    ElevatedButton.icon(
                      onPressed: () => _navigateToForm(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Item'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: catalogState.products.length,
                separatorBuilder: (context, index) => AppGap.h12,
                itemBuilder: (context, index) {
                  final product = catalogState.products[index];
                  return _buildProductCard(
                    context,
                    product: product,
                    handler: handler,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required Product product,
    required dynamic handler,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final formattedQty = handler.formatQuantity(
      product.stockQuantity,
      uom: product.baseUom,
      customAttributes: product.customAttributes,
    );

    return InkWell(
      onTap: () => ProductDetailModal.show(
        context,
        product: product,
        onEdit: () => _navigateToForm(context, product),
        onDelete: () => ref.read(productCatalogProvider.notifier).deleteProduct(product.id),
      ),
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(
            color: product.isLowStock ? AppColors.warning.withValues(alpha: 0.5) : colorScheme.outline,
            width: product.isLowStock ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Archetype Icon Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: colorScheme.primary, size: 24),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: AppTypography.headlineSmall.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          Text(
                            formattedQty,
                            style: AppTypography.headlineSmall.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              product.category,
                              style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          AppGap.w8,
                          Text('SKU: ${product.sku}', style: AppTypography.bodySmall),
                          AppGap.w8,
                          Text('•', style: AppTypography.bodySmall),
                          AppGap.w8,
                          Text('Barcode: ${product.barcode}', style: AppTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (action) {
                    if (action == 'edit') {
                      _navigateToForm(context, product);
                    } else if (action == 'delete') {
                      ref.read(productCatalogProvider.notifier).deleteProduct(product.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),

            // Dynamic Attribute Tags and Wrapper Indicators
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Low Stock Badge
                if (product.isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      'LOW STOCK ALERT',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Matrix Variants Badge
                if (product.hasVariants)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      '${product.variants.length} VARIANTS',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Recipe BOM Badge
                if (product.isRecipeKit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      'RECIPE BOM (${product.recipeBOM.length} INGREDIENTS)',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Dynamic Polymorphic Schema Tags
                ...product.customAttributes.entries.map((entry) {
                  final label = entry.key.replaceAll('_', ' ').toUpperCase();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withValues(alpha: 0.5)
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Text(
                      '$label: ${entry.value}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, [Product? product]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(productToEdit: product),
      ),
    );
  }
}
