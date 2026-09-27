import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../controllers/pos_cart_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final products = state.products;
    final cartState = ref.watch(posCartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('POS & Rapid Counter Checkout', style: AppTypography.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Direct sales register, instant barcode scanning & thermal receipts for ${archetype.name}',
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                if (cartState.items.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => ref.read(posCartProvider.notifier).clearCart(),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                    label: const Text('Clear Cart'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Barcode Scan / Quick Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: archetype.brandColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _barcodeSearchController,
                      decoration: const InputDecoration(
                        hintText: 'Scan item barcode or type product name / SKU to add instantly...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onSubmitted: (query) {
                        if (query.isNotEmpty) {
                          final match = products.firstWhere(
                            (p) =>
                                (p['name'] as String).toLowerCase().contains(query.toLowerCase()) ||
                                (p['sku'] as String? ?? '').toLowerCase().contains(query.toLowerCase()),
                            orElse: () => products.isNotEmpty ? products.first : {},
                          );
                          if (match.isNotEmpty) {
                            ref.read(posCartProvider.notifier).addItem(match);
                            _barcodeSearchController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${match['name']}" to cart'),
                                duration: const Duration(milliseconds: 900),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (products.isNotEmpty) {
                        ref.read(posCartProvider.notifier).addItem(products.first);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Scanned sample "${products.first['name']}"'),
                            duration: const Duration(milliseconds: 900),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: archetype.brandColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.barcode_reader, size: 16),
                    label: const Text('Simulate Scan'),
                  ),
                ],
              ),
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
                      Expanded(
                        flex: 6,
                        child: _buildItemGrid(products, archetype.brandColor, isDark),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        flex: 4,
                        child: _buildCartCard(cartState, archetype.brandColor, isDark),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCartCard(cartState, archetype.brandColor, isDark),
                      const SizedBox(height: AppSpacing.lg),
                      _buildItemGrid(products, archetype.brandColor, isDark),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(List<Map<String, dynamic>> products, Color brandColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Active Product Catalog (Tap to Add)', style: AppTypography.h3),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            final price = (product['unitPrice'] as num?)?.toDouble() ?? 10.0;
            final uom = product['uom'] as String? ?? 'unit';

            return InkWell(
              onTap: () {
                ref.read(posCartProvider.notifier).addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${product['name']}" to cart'),
                    duration: const Duration(milliseconds: 700),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'] as String, style: AppTypography.bodyBold, maxLines: 2),
                        const SizedBox(height: 4),
                        Text('SKU: ${product['sku'] ?? "SKU-001"} • $uom', style: AppTypography.caption),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${price.toStringAsFixed(2)}', style: AppTypography.h2.copyWith(color: brandColor)),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: brandColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: Icon(Icons.add_shopping_cart_rounded, size: 16, color: brandColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCartCard(PosCartState cartState, Color brandColor, bool isDark) {
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
              Row(
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text('Current Order', style: AppTypography.h3),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cartState.totalItemCount} Items',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: brandColor),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Items List
          if (cartState.items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.remove_shopping_cart_outlined, size: 36, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text('Cart is empty', style: AppTypography.bodyBold),
                  Text('Tap items on the left or scan barcode to add', style: AppTypography.caption),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartState.items.length,
              separatorBuilder: (context, index) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final item = cartState.items[index];

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: AppTypography.bodyBold, maxLines: 1),
                          Text('\$${item.unitPrice.toStringAsFixed(2)} / ${item.uom}', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 18),
                          onPressed: () => ref.read(posCartProvider.notifier).updateQuantity(item.productId, item.quantity - 1),
                        ),
                        Text('${item.quantity}', style: AppTypography.bodyBold),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 18),
                          onPressed: () => ref.read(posCartProvider.notifier).updateQuantity(item.productId, item.quantity + 1),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 70,
                      child: Text(
                        '\$${item.lineTotal.toStringAsFixed(2)}',
                        style: AppTypography.bodyBold.copyWith(color: brandColor),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                );
              },
            ),

          const Divider(height: 24),

          // Financial Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: AppTypography.body),
              Text('\$${cartState.subtotal.toStringAsFixed(2)}', style: AppTypography.body),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Tax (5% GST):', style: AppTypography.body),
              Text('\$${cartState.taxAmount.toStringAsFixed(2)}', style: AppTypography.body),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total:', style: AppTypography.h2),
              Text('\$${cartState.grandTotal.toStringAsFixed(2)}', style: AppTypography.h1.copyWith(color: brandColor)),
            ],
          ),
          const SizedBox(height: 18),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cartState.items.isEmpty || cartState.isProcessing
                  ? null
                  : () => _showCheckoutModal(cartState, brandColor),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: cartState.isProcessing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.point_of_sale_rounded, size: 20),
              label: Text(
                cartState.isProcessing ? 'Processing Payment...' : 'Pay & Complete Sale (\$${cartState.grandTotal.toStringAsFixed(2)})',
                style: AppTypography.bodyBold.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutModal(PosCartState cartState, Color brandColor) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Payment Tender', style: AppTypography.h2),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(innerContext)),
                  ],
                ),
                const Divider(height: 24),
                Text('Total Due: \$${cartState.grandTotal.toStringAsFixed(2)}', style: AppTypography.h3.copyWith(color: brandColor)),
                const SizedBox(height: 16),
                ...PaymentMethod.values.map((method) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(method.icon, color: brandColor),
                      title: Text(method.displayName, style: AppTypography.bodyBold),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(innerContext);
                        final receipt = await ref.read(posCartProvider.notifier).checkout(method);
                        if (!mounted) return;
                        _showReceiptDialog(receipt, brandColor);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReceiptDialog(PosSaleReceipt receipt, Color brandColor) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
                const SizedBox(height: 8),
                Text('Sale Completed & Stock Deducted!', style: AppTypography.h2),
                Text('Receipt #${receipt.receiptNumber}', style: AppTypography.caption),
                const Divider(height: 24),

                // Thermal Receipt Preview Look
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('RUDRAKSHA WMS COUNTER', style: AppTypography.bodyBold)),
                      Center(child: Text(receipt.timestamp.toIso8601String().substring(0, 16), style: AppTypography.caption)),
                      const Divider(height: 16),
                      ...receipt.items.map((i) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${i.quantity}x ${i.productName}', style: AppTypography.caption),
                            Text('\$${i.lineTotal.toStringAsFixed(2)}', style: AppTypography.caption),
                          ],
                        );
                      }),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL PAID (${receipt.paymentMethod.displayName}):', style: AppTypography.bodyBold),
                          Text('\$${receipt.totalAmount.toStringAsFixed(2)}', style: AppTypography.bodyBold),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ESC/POS Thermal Receipt sent to printer queue!'), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: brandColor, foregroundColor: Colors.white),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Print ESC/POS Receipt'),
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
}
