import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../controllers/pos_cart_controller.dart';
import '../widgets/pos_cart_view.dart';
import '../widgets/pos_product_card.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final TextEditingController _barcodeSearchController = TextEditingController();

  @override
  void dispose() {
    _barcodeSearchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmit(String query, List<Map<String, dynamic>> products) {
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      final match = products.firstWhere(
        (p) =>
            (p['name'] as String? ?? '').toLowerCase().contains(q) ||
            (p['sku'] as String? ?? '').toLowerCase().contains(q),
        orElse: () => products.isNotEmpty ? products.first : {},
      );
      if (match.isNotEmpty) {
        ref.read(posCartProvider.notifier).addItem(match);
        _barcodeSearchController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${match['name']}" to cart'),
            duration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final products = state.products;
    final cartState = ref.watch(posCartProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 640;
          final isDesktop = constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Responsive Screen Header
                _buildHeader(context, archetype, cartState, isDark, isMobile),
                AppGap.h16,

                // 2. Barcode Scan & Quick Search Bar
                _buildSearchBar(context, archetype, products, isDark, isMobile, colorScheme),
                AppGap.h20,

                // 3. POS Grid & Cart Layout (Side-by-Side on Desktop, Stacked on Mobile)
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildProductCatalogSection(products, archetype.brandColor, isDark),
                      ),
                      AppGap.w20,
                      Expanded(
                        flex: 4,
                        child: PosCartView(brandColor: archetype.brandColor),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosCartView(brandColor: archetype.brandColor),
                      AppGap.h20,
                      _buildProductCatalogSection(products, archetype.brandColor, isDark),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    dynamic archetype,
    PosCartState cartState,
    bool isDark,
    bool isMobile,
  ) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('POS & Rapid Counter Checkout', style: AppTypography.headlineLarge),
        AppGap.h4,
        Text(
          'Direct sales register, instant barcode scanning & thermal receipts for ${archetype.name}',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );

    final clearButton = cartState.items.isNotEmpty
        ? OutlinedButton.icon(
            onPressed: () => ref.read(posCartProvider.notifier).clearCart(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            ),
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: const Text('Clear Cart'),
          )
        : const SizedBox.shrink();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          if (cartState.items.isNotEmpty) ...[
            AppGap.h12,
            clearButton,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleSection),
        AppGap.w16,
        clearButton,
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    dynamic archetype,
    List<Map<String, dynamic>> products,
    bool isDark,
    bool isMobile,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: archetype.brandColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_scanner_rounded, size: AppSizes.iconSm + 4, color: archetype.brandColor),
          AppGap.w12,
          Expanded(
            child: TextField(
              controller: _barcodeSearchController,
              decoration: const InputDecoration(
                hintText: 'Scan item barcode or type product / SKU...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: (query) => _handleSearchSubmit(query, products),
            ),
          ),
          AppGap.w8,
          FilledButton.icon(
            onPressed: () {
              if (products.isNotEmpty) {
                ref.read(posCartProvider.notifier).addItem(products.first);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Scanned "${products.first['name']}"'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: archetype.brandColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.barcode_reader, size: 16),
            label: Text(isMobile ? 'Scan' : 'Simulate Scan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCatalogSection(
    List<Map<String, dynamic>> products,
    Color brandColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Product Catalog (Tap to Add)',
          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        AppGap.h12,
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 380
                ? 1
                : (constraints.maxWidth < 700 ? 2 : 3);
            final childAspectRatio = crossAxisCount == 1 ? 2.8 : (crossAxisCount == 2 ? 1.4 : 1.3);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.sm + 4,
                mainAxisSpacing: AppSpacing.sm + 4,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return PosProductCard(
                  product: product,
                  brandColor: brandColor,
                  onAddToCart: () {
                    ref.read(posCartProvider.notifier).addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "${product['name']}" to cart'),
                        duration: const Duration(milliseconds: 600),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
