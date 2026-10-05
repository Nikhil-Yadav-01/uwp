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
import '../../../products/presentation/controllers/product_controller.dart';
import '../../domain/models/sales_order.dart';
import '../controllers/outbound_controller.dart';

/// Modal dialog for Creating or Editing a Sales / Dispatch Order.
class SoFormModal extends ConsumerStatefulWidget {
  final SalesOrder? salesOrder;

  const SoFormModal({super.key, this.salesOrder});

  static Future<void> show(BuildContext context, {SalesOrder? salesOrder}) {
    return ModalShell.show(
      context: context,
      maxWidth: 680,
      child: SoFormModal(salesOrder: salesOrder),
    );
  }

  @override
  ConsumerState<SoFormModal> createState() => _SoFormModalState();
}

class _SoFormModalState extends ConsumerState<SoFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customerController;
  late final TextEditingController _destinationController;
  late final TextEditingController _notesController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;

  late CustomerType _customerType;
  late OrderPriority _priority;
  String? _selectedProductId;
  double _quantity = 5.0;
  double _unitPrice = 45.0;

  bool get isEditMode => widget.salesOrder != null;

  @override
  void initState() {
    super.initState();
    final so = widget.salesOrder;
    _customerController = TextEditingController(text: so?.customerName ?? '');
    _destinationController = TextEditingController(text: so?.destinationWardOrAddress ?? '');
    _notesController = TextEditingController(text: so?.notes ?? '');

    _customerType = so?.customerType ?? CustomerType.b2bWholesale;
    _priority = so?.priority ?? OrderPriority.standard;

    if (so != null && so.items.isNotEmpty) {
      final firstItem = so.items.first;
      _selectedProductId = firstItem.productId;
      _quantity = firstItem.requestedQty;
      _unitPrice = firstItem.unitPrice;
    }

    _quantityController = TextEditingController(text: _quantity.toStringAsFixed(0));
    _unitPriceController = TextEditingController(text: _unitPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _customerController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Icon(Icons.outbox_rounded, color: colorScheme.primary, size: AppSizes.iconMd),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditMode ? 'Edit Sales Order (${widget.salesOrder!.soNumber})' : 'Create Sales / Dispatch Order',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        AppGap.h4,
                        Text(
                          'Outbound fulfillment for ${archetype.name}',
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

              // Recipient & Destination Details
              Text(
                'Recipient & Destination Details',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              AppGap.h8,
              if (isNarrow) ...[
                TextFormField(
                  controller: _customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer / Ward / Store Name *',
                    prefixIcon: Icon(Icons.person_pin_circle_outlined, size: AppSizes.iconSm),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                AppGap.h12,
                DropdownButtonFormField<CustomerType>(
                  initialValue: _customerType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Destination Type',
                    prefixIcon: Icon(Icons.category_outlined, size: AppSizes.iconSm),
                  ),
                  items: CustomerType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase(), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _customerType = v ?? CustomerType.b2bWholesale),
                ),
                AppGap.h12,
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Station / Address / Ward *',
                    prefixIcon: Icon(Icons.location_on_outlined, size: AppSizes.iconSm),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                AppGap.h12,
                DropdownButtonFormField<OrderPriority>(
                  initialValue: _priority,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.bolt_outlined, size: AppSizes.iconSm),
                  ),
                  items: OrderPriority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase(), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _priority = v ?? OrderPriority.standard),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customerController,
                        decoration: const InputDecoration(
                          labelText: 'Customer / Ward / Store Name *',
                          prefixIcon: Icon(Icons.person_pin_circle_outlined, size: AppSizes.iconSm),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: DropdownButtonFormField<CustomerType>(
                        initialValue: _customerType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Destination Type',
                          prefixIcon: Icon(Icons.category_outlined, size: AppSizes.iconSm),
                        ),
                        items: CustomerType.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t.name.toUpperCase(), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _customerType = v ?? CustomerType.b2bWholesale),
                      ),
                    ),
                  ],
                ),
                AppGap.h12,
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Station / Address / Ward *',
                          prefixIcon: Icon(Icons.location_on_outlined, size: AppSizes.iconSm),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: DropdownButtonFormField<OrderPriority>(
                        initialValue: _priority,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(Icons.bolt_outlined, size: AppSizes.iconSm),
                        ),
                        items: OrderPriority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.name.toUpperCase(), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _priority = v ?? OrderPriority.standard),
                      ),
                    ),
                  ],
                ),
              ],
              AppGap.h16,

              // Product Line Item
              Text(
                'Ordered Item Specification',
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              AppGap.h8,
              DropdownButtonFormField<String>(
                initialValue: _selectedProductId ?? (products.isNotEmpty ? products.first.id : null),
                isExpanded: true,
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
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedProductId = val;
                    if (val != null) {
                      final p = products.firstWhere((prod) => prod.id == val);
                      _unitPrice = p.sellingPrice;
                      _unitPriceController.text = _unitPrice.toStringAsFixed(2);
                    }
                  });
                },
              ),
              AppGap.h12,
              if (isNarrow) ...[
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Requested Qty *',
                    prefixIcon: Icon(Icons.numbers_outlined, size: AppSizes.iconSm),
                  ),
                  onChanged: (v) => setState(() => _quantity = double.tryParse(v) ?? 5.0),
                ),
                AppGap.h12,
                TextFormField(
                  controller: _unitPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (${AppFormatters.currencySymbol}) *',
                    prefixIcon: Icon(Icons.currency_rupee_outlined, size: AppSizes.iconSm),
                  ),
                  onChanged: (v) => setState(() => _unitPrice = double.tryParse(v) ?? 45.0),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                           labelText: 'Requested Qty *',
                          prefixIcon: Icon(Icons.numbers_outlined, size: AppSizes.iconSm),
                        ),
                        onChanged: (v) => setState(() => _quantity = double.tryParse(v) ?? 5.0),
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: TextFormField(
                        controller: _unitPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Unit Price (${AppFormatters.currencySymbol}) *',
                          prefixIcon: Icon(Icons.currency_rupee_outlined, size: AppSizes.iconSm),
                        ),
                        onChanged: (v) => setState(() => _unitPrice = double.tryParse(v) ?? 45.0),
                      ),
                    ),
                  ],
                ),
              ],
              AppGap.h12,

              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Fulfillment Notes / Handling Instructions',
                  prefixIcon: Icon(Icons.notes_outlined, size: AppSizes.iconSm),
                ),
              ),
              AppGap.h16,

              // Total Order Value Box
              Container(
                padding: AppPadding.p12,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ESTIMATED ORDER TOTAL',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      AppFormatters.currency(_quantity * _unitPrice),
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h20,

              // Footer Actions
              if (isNarrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handleSubmit(context, archetype, products),
                      icon: const Icon(Icons.send_rounded, size: AppSizes.iconSm),
                      label: Text(isEditMode ? 'Save Changes' : 'Confirm & Allocate Order'),
                    ),
                    AppGap.h8,
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handleSubmit(context, archetype, products),
                    icon: const Icon(Icons.send_rounded, size: AppSizes.iconSm),
                    label: Text(isEditMode ? 'Save Changes' : 'Confirm & Allocate Order'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context, dynamic archetype, List<dynamic> products) async {
    if (!_formKey.currentState!.validate()) return;

    final prodId = _selectedProductId ?? (products.isNotEmpty ? products.first.id : 'prod_1');
    final prod = products.firstWhere((p) => p.id == prodId, orElse: () => products.first);

    if (isEditMode) {
      final existingSO = widget.salesOrder!;
      final updatedSO = existingSO.copyWith(
        customerName: _customerController.text.trim(),
        customerType: _customerType,
        destinationWardOrAddress: _destinationController.text.trim(),
        priority: _priority,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        items: [
          SalesOrderItem(
            id: existingSO.items.isNotEmpty ? existingSO.items.first.id : 'SOI-${DateTime.now().millisecondsSinceEpoch}',
            productId: prod.id,
            productName: prod.name,
            sku: prod.sku,
            requestedQty: _quantity,
            unitPrice: _unitPrice,
            uom: prod.baseUom,
          ),
        ],
      );

      final success = await ref.read(outboundNotifierProvider.notifier).updateSalesOrder(updatedSO);
      if (context.mounted && success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated Sales Order ${updatedSO.soNumber}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      final newSO = SalesOrder(
        id: 'SO-${DateTime.now().millisecondsSinceEpoch}',
        soNumber: 'SO-2026-${archetype.id.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        customerName: _customerController.text.trim(),
        customerType: _customerType,
        destinationWardOrAddress: _destinationController.text.trim(),
        orderDate: DateTime.now(),
        priority: _priority,
        status: OutboundStatus.allocated,
        archetypeId: archetype.id,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        items: [
          SalesOrderItem(
            id: 'SOI-${DateTime.now().millisecondsSinceEpoch}',
            productId: prod.id,
            productName: prod.name,
            sku: prod.sku,
            requestedQty: _quantity,
            unitPrice: _unitPrice,
            uom: prod.baseUom,
          ),
        ],
      );

      final success = await ref.read(outboundNotifierProvider.notifier).createSalesOrder(newSO);
      if (context.mounted && success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created Sales Order ${newSO.soNumber}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
