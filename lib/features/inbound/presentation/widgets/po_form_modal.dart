import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../../products/presentation/controllers/product_controller.dart';
import '../../domain/models/purchase_order.dart';
import '../controllers/inbound_controller.dart';

/// Modal dialog for creating and approving new Purchase Orders.
class PoFormModal extends ConsumerStatefulWidget {
  const PoFormModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalShell.show(
      context: context,
      maxWidth: 680,
      child: const PoFormModal(),
    );
  }

  @override
  ConsumerState<PoFormModal> createState() => _PoFormModalState();
}

class _PoFormModalState extends ConsumerState<PoFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _vendorController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProductId;
  double _quantity = 10.0;
  double _unitPrice = 25.0;
  final Map<String, dynamic> _customAttributes = {};

  @override
  void dispose() {
    _vendorController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;
    final productsState = ref.watch(productCatalogProvider);
    final products = productsState.products;

    final totalEstimate = _quantity * _unitPrice;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
                child: Icon(Icons.note_add_rounded, color: colorScheme.primary, size: AppSizes.iconMd),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Purchase Order',
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      'Inbound inventory intake for ${archetype.name}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Vendor Details
                  Text(
                    'Vendor Information',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppGap.h8,
                  if (isNarrow) ...[
                    TextFormField(
                      controller: _vendorController,
                      decoration: const InputDecoration(
                        labelText: 'Vendor / Supplier Name *',
                        prefixIcon: Icon(Icons.business_outlined, size: AppSizes.iconSm),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    AppGap.h12,
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Vendor Email',
                        prefixIcon: Icon(Icons.email_outlined, size: AppSizes.iconSm),
                      ),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _vendorController,
                            decoration: const InputDecoration(
                              labelText: 'Vendor / Supplier Name *',
                              prefixIcon: Icon(Icons.business_outlined, size: AppSizes.iconSm),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        AppGap.w12,
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Vendor Email',
                              prefixIcon: Icon(Icons.email_outlined, size: AppSizes.iconSm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  AppGap.h16,

                  // 2. Product Line Item
                  Text(
                    'Line Item & Receiving Specifications',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppGap.h8,
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProductId ?? (products.isNotEmpty ? products.first.id : null),
                    decoration: const InputDecoration(
                      labelText: 'Select Product from Catalog *',
                      prefixIcon: Icon(Icons.inventory_2_outlined, size: AppSizes.iconSm),
                    ),
                    items: products.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.name} (${p.sku})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProductId = val;
                        if (val != null) {
                          final p = products.firstWhere((prod) => prod.id == val);
                          _unitPrice = p.costPrice > 0 ? p.costPrice : p.sellingPrice * 0.7;
                        }
                      });
                    },
                  ),
                  AppGap.h12,
                  if (isNarrow) ...[
                    TextFormField(
                      initialValue: _quantity.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ordered Quantity *',
                        prefixIcon: Icon(Icons.numbers_outlined, size: AppSizes.iconSm),
                      ),
                      onChanged: (v) => setState(() => _quantity = double.tryParse(v) ?? 10.0),
                    ),
                    AppGap.h12,
                    TextFormField(
                      initialValue: _unitPrice.toStringAsFixed(2),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Unit Cost (\$) *',
                        prefixIcon: Icon(Icons.attach_money_outlined, size: AppSizes.iconSm),
                      ),
                      onChanged: (v) => setState(() => _unitPrice = double.tryParse(v) ?? 25.0),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _quantity.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Ordered Quantity *',
                              prefixIcon: Icon(Icons.numbers_outlined, size: AppSizes.iconSm),
                            ),
                            onChanged: (v) => setState(() => _quantity = double.tryParse(v) ?? 10.0),
                          ),
                        ),
                        AppGap.w12,
                        Expanded(
                          child: TextFormField(
                            initialValue: _unitPrice.toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Unit Cost (\$) *',
                              prefixIcon: Icon(Icons.attach_money_outlined, size: AppSizes.iconSm),
                            ),
                            onChanged: (v) => setState(() => _unitPrice = double.tryParse(v) ?? 25.0),
                          ),
                        ),
                      ],
                    ),
                  AppGap.h16,

                  // 3. Archetype Compliance Card
                  Container(
                    padding: AppPadding.p12,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded, size: AppSizes.iconSm, color: colorScheme.primary),
                            AppGap.w8,
                            Text(
                              'Archetype Compliance & Receiving Controls',
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        AppGap.h8,
                        if (archetype.id == 'healthcare_pharma') ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'NDC / Drug License Number',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['ndcNumber'] = v,
                          ),
                          AppGap.h8,
                          CheckboxListTile(
                            title: const Text('Requires Dual-Signoff Witness (Narcotics Vault)'),
                            value: _customAttributes['requiresDualSignoff'] == true,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) => setState(() => _customAttributes['requiresDualSignoff'] = v),
                          ),
                        ] else if (archetype.id == 'grocery_foods') ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Batch / Lot Number',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['batchLot'] = v,
                          ),
                          AppGap.h8,
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Dock Temperature Requirement (e.g. +4°C)',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['dockTempReq'] = v,
                          ),
                        ] else if (archetype.id == 'leather_textiles') ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Tannery Batch Lot & Hide Grade Stamp',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['tanneryLot'] = v,
                          ),
                        ] else ...[
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Batch Lot / Manufacturer Code',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['batchLot'] = v,
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppGap.h16,

                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Special Receiving Instructions / Notes',
                      prefixIcon: Icon(Icons.notes_outlined, size: AppSizes.iconSm),
                    ),
                  ),
                  AppGap.h16,

                  // Dynamic Estimated Total & Action Buttons
                  Container(
                    padding: AppPadding.p12,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTIMATED ORDER VALUE',
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '\$${totalEstimate.toStringAsFixed(2)}',
                              style: AppTypography.headlineSmall.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            AppGap.w8,
                            ElevatedButton.icon(
                              onPressed: () => _handleSubmit(products, archetype),
                              icon: const Icon(Icons.check_circle_outline_rounded, size: AppSizes.iconSm),
                              label: const Text('Submit PO'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(List<dynamic> products, dynamic archetype) async {
    if (!_formKey.currentState!.validate()) return;
    final prodId = _selectedProductId ?? (products.isNotEmpty ? products.first.id : 'prod_1');
    final prod = products.firstWhere((p) => p.id == prodId, orElse: () => products.first);

    final newPO = PurchaseOrder(
      id: 'PO-${DateTime.now().millisecondsSinceEpoch}',
      poNumber: 'PO-2026-${archetype.id.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      vendorName: _vendorController.text.trim(),
      vendorEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      orderDate: DateTime.now(),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
      status: InboundStatus.approved,
      archetypeId: archetype.id,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      items: [
        PurchaseOrderItem(
          id: 'POI-${DateTime.now().millisecondsSinceEpoch}',
          productId: prod.id,
          productName: prod.name,
          sku: prod.sku,
          orderedQty: _quantity,
          unitPrice: _unitPrice,
          uom: prod.baseUom,
          customAttributes: _customAttributes,
        ),
      ],
    );

    final success = await ref.read(inboundNotifierProvider.notifier).createPurchaseOrder(newPO);
    if (mounted && success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created Purchase Order ${newPO.poNumber}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
