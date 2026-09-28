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
import 'po_detail_modal.dart';

/// Modal dialog for creating and editing Purchase Orders.
class PoFormModal extends ConsumerStatefulWidget {
  final PurchaseOrder? purchaseOrder;

  const PoFormModal({super.key, this.purchaseOrder});

  static Future<void> show(BuildContext context, {PurchaseOrder? purchaseOrder}) {
    return ModalShell.show(
      context: context,
      maxWidth: 680,
      child: PoFormModal(purchaseOrder: purchaseOrder),
    );
  }

  @override
  ConsumerState<PoFormModal> createState() => _PoFormModalState();
}

class _PoFormModalState extends ConsumerState<PoFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vendorController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;

  String? _selectedProductId;
  double _quantity = 10.0;
  double _unitPrice = 25.0;
  final Map<String, dynamic> _customAttributes = {};

  bool get isEdit => widget.purchaseOrder != null;

  @override
  void initState() {
    super.initState();
    final po = widget.purchaseOrder;
    _vendorController = TextEditingController(text: po?.vendorName ?? '');
    _emailController = TextEditingController(text: po?.vendorEmail ?? '');
    _notesController = TextEditingController(text: po?.notes ?? '');

    if (po != null && po.items.isNotEmpty) {
      final firstItem = po.items.first;
      _selectedProductId = firstItem.productId;
      _quantity = firstItem.orderedQty;
      _unitPrice = firstItem.unitPrice;
      _customAttributes.addAll(firstItem.customAttributes);
    }

    _qtyController = TextEditingController(text: _quantity.toStringAsFixed(0));
    _priceController = TextEditingController(text: _unitPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
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
        mainAxisSize: MainAxisSize.min,
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
                child: Icon(
                  isEdit ? Icons.edit_note_rounded : Icons.note_add_rounded,
                  color: colorScheme.primary,
                  size: AppSizes.iconMd,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Purchase Order' : 'Create Purchase Order',
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h4,
                    Text(
                      isEdit
                          ? 'Updating ${widget.purchaseOrder!.poNumber}'
                          : 'Inbound intake for ${archetype.name}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              final isNarrow = constraints.maxWidth < 480;

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
                    isExpanded: true,
                    initialValue: _selectedProductId ?? (products.isNotEmpty ? products.first.id : null),
                    decoration: const InputDecoration(
                      labelText: 'Select Product from Catalog *',
                      prefixIcon: Icon(Icons.inventory_2_outlined, size: AppSizes.iconSm),
                    ),
                    items: products.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          '${p.name} (${p.sku})',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProductId = val;
                        if (val != null) {
                          final p = products.firstWhere((prod) => prod.id == val);
                          _unitPrice = p.costPrice > 0 ? p.costPrice : p.sellingPrice * 0.7;
                          _priceController.text = _unitPrice.toStringAsFixed(2);
                        }
                      });
                    },
                  ),
                  AppGap.h12,
                  if (isNarrow) ...[
                    TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ordered Quantity *',
                        prefixIcon: Icon(Icons.numbers_outlined, size: AppSizes.iconSm),
                      ),
                      onChanged: (v) => setState(() => _quantity = double.tryParse(v) ?? 10.0),
                    ),
                    AppGap.h12,
                    TextFormField(
                      controller: _priceController,
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
                            controller: _qtyController,
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
                            controller: _priceController,
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
                            Expanded(
                              child: Text(
                                'Archetype Compliance & Receiving Controls',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        AppGap.h8,
                        if (archetype.id == 'healthcare_pharma') ...[
                          TextFormField(
                            initialValue: _customAttributes['ndcNumber']?.toString(),
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
                            initialValue: _customAttributes['batchLot']?.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Batch / Lot Number',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['batchLot'] = v,
                          ),
                          AppGap.h8,
                          TextFormField(
                            initialValue: _customAttributes['dockTempReq']?.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Dock Temperature Requirement (e.g. +4°C)',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['dockTempReq'] = v,
                          ),
                        ] else if (archetype.id == 'leather_textiles') ...[
                          TextFormField(
                            initialValue: _customAttributes['tanneryLot']?.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Tannery Batch Lot & Hide Grade Stamp',
                              isDense: true,
                            ),
                            onChanged: (v) => _customAttributes['tanneryLot'] = v,
                          ),
                        ] else ...[
                          TextFormField(
                            initialValue: _customAttributes['batchLot']?.toString(),
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

                  // 4. Dynamic Estimated Total & Responsive Action Bar
                  _buildEstimateAndActionBar(
                    context,
                    totalEstimate,
                    isNarrow,
                    products,
                    archetype,
                    colorScheme,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateAndActionBar(
    BuildContext context,
    double totalEstimate,
    bool isNarrow,
    List<dynamic> products,
    dynamic archetype,
    ColorScheme colorScheme,
  ) {
    final estimateCard = Container(
      padding: AppPadding.p12,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.r8),
      ),
      child: Column(
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
    );

    final cancelButton = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'),
    );

    final submitButton = ElevatedButton.icon(
      onPressed: () => _handleSubmit(products, archetype),
      icon: Icon(
        isEdit ? Icons.save_rounded : Icons.check_circle_outline_rounded,
        size: AppSizes.iconSm,
      ),
      label: Text(isEdit ? 'Save Changes' : 'Submit PO'),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          estimateCard,
          AppGap.h12,
          Row(
            children: [
              Expanded(child: cancelButton),
              AppGap.w8,
              Expanded(flex: 2, child: submitButton),
            ],
          ),
        ],
      );
    }

    return Container(
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
              cancelButton,
              AppGap.w8,
              submitButton,
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(List<dynamic> products, dynamic archetype) async {
    if (!_formKey.currentState!.validate()) return;
    final prodId = _selectedProductId ?? (products.isNotEmpty ? products.first.id : 'prod_1');
    final prod = products.firstWhere((p) => p.id == prodId, orElse: () => products.first);

    if (isEdit) {
      final existingPO = widget.purchaseOrder!;
      final updatedPO = existingPO.copyWith(
        vendorName: _vendorController.text.trim(),
        vendorEmail: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        items: [
          existingPO.items.isNotEmpty
              ? existingPO.items.first.copyWith(
                  productId: prod.id,
                  productName: prod.name,
                  sku: prod.sku,
                  orderedQty: _quantity,
                  unitPrice: _unitPrice,
                  uom: prod.baseUom,
                  customAttributes: _customAttributes,
                )
              : PurchaseOrderItem(
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

      final success = await ref.read(inboundNotifierProvider.notifier).updatePurchaseOrder(updatedPO);
      if (mounted && success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated Purchase Order ${updatedPO.poNumber}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        // Show updated PO detail view
        PoDetailModal.show(context, purchaseOrder: updatedPO);
      }
    } else {
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
        // Show new PO detail view
        PoDetailModal.show(context, purchaseOrder: newPO);
      }
    }
  }
}
