import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final products = state.products;
    final handler = state.handler;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('POS & Counter Checkout', style: AppTypography.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Instant counter sales, thermal receipts & automatic stock deduction for ${archetype.name}',
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: archetype.brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.print_outlined, size: 18),
                label: const Text('Test Thermal Print'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // POS Grid & Cart Split
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: buildItemGrid(products, handler, archetype.brandColor, isDark)),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 4, child: buildCartCard(archetype.brandColor, isDark)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    buildCartCard(archetype.brandColor, isDark),
                    const SizedBox(height: AppSpacing.lg),
                    buildItemGrid(products, handler, archetype.brandColor, isDark),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildItemGrid(List<Map<String, dynamic>> products, dynamic handler, Color brandColor, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product['name'] as String, style: AppTypography.bodyBold, maxLines: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${(product['unitPrice'] as num).toStringAsFixed(2)}', style: AppTypography.h3.copyWith(color: brandColor)),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: brandColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: Icon(Icons.add_rounded, size: 16, color: brandColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCartCard(Color brandColor, bool isDark) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current Cart / Order', style: AppTypography.h3),
              const Icon(Icons.shopping_bag_outlined, size: 20),
            ],
          ),
          const Divider(height: 24),
          Text('No items added yet. Click items or scan barcode to add to cart.', style: AppTypography.caption),
          const SizedBox(height: 30),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: AppTypography.h2),
              Text('\$0.00', style: AppTypography.h2.copyWith(color: brandColor)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.credit_card_rounded, size: 18),
              label: const Text('Complete Sale & Print Receipt'),
            ),
          ),
        ],
      ),
    );
  }
}
