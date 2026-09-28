import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/product.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_detail_modal.dart';
import '../widgets/product_list_item.dart';
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
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Header Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < AppSpacing.breakpointMobile;
                if (isCompact) {
                  return Column(
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
                      AppGap.h12,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToForm(context),
                          icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                          label: Text('Add ${archetype.name} Item'),
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
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
                    ),
                    AppGap.w16,
                    ElevatedButton.icon(
                      onPressed: () => _navigateToForm(context),
                      icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                      label: Text('Add ${archetype.name} Item'),
                    ),
                  ],
                );
              },
            ),
            AppGap.h20,

            // Responsive Search & Filter Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search items by name, SKU, or barcode...',
                                prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm + AppSpacing.xs),
                                isDense: true,
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded, size: AppSizes.iconSm),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
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
                                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              ),
                              onChanged: catalogNotifier.setSearchQuery,
                            ),
                            const Divider(height: AppSpacing.sm),
                            FilterChip(
                              showCheckmark: false,
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
                                size: AppSizes.iconSm,
                                color: catalogState.lowStockOnly ? Colors.white : AppColors.warning,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search items by name, SKU, or scan barcode...',
                                  prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm + AppSpacing.xs),
                                  isDense: true,
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: AppSizes.iconSm),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.compact,
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
                                  contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                ),
                                onChanged: catalogNotifier.setSearchQuery,
                              ),
                            ),
                            AppGap.w12,
                            // Low Stock Toggle Button
                            FilterChip(
                              showCheckmark: false,
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
                                size: AppSizes.iconSm,
                                color: catalogState.lowStockOnly ? Colors.white : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                );
              },
            ),
            AppGap.h12,

            // Category Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = catalogState.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
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
                  padding: AppPadding.p32,
                  child: CircularProgressIndicator(),
                ),
              )
            else if (catalogState.products.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  children: [
                    Icon(archetype.icon, size: AppSizes.buttonHeightMd, color: colorScheme.primary.withValues(alpha: 0.5)),
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
                      icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
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
                  return ProductListItem(
                    product: product,
                    handler: handler,
                    onTap: () => ProductDetailModal.show(
                      context,
                      product: product,
                      onEdit: () => _navigateToForm(context, product),
                      onDelete: () => ref.read(productCatalogProvider.notifier).deleteProduct(product.id),
                    ),
                    onEdit: () => _navigateToForm(context, product),
                    onDelete: () => ref.read(productCatalogProvider.notifier).deleteProduct(product.id),
                  );
                },
              ),
          ],
        ),
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
