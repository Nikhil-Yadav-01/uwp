import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../../products/presentation/controllers/product_controller.dart';
import '../../domain/models/sales_order.dart';
import '../controllers/outbound_controller.dart';

class SoFormModal extends ConsumerStatefulWidget {
  const SoFormModal({super.key});

  @override
  ConsumerState<SoFormModal> createState() => _SoFormModalState();
}

class _SoFormModalState extends ConsumerState<SoFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerType _customerType = CustomerType.b2bWholesale;
  OrderPriority _priority = OrderPriority.standard;
  String? _selectedProductId;
  double _quantity = 5.0;
  double _unitPrice = 45.0;

  @override
  void dispose() {
    _customerController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final archetype = ref.watch(archetypeProvider).archetype;
    final productsState = ref.watch(productCatalogProvider);
    final products = productsState.products;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 680,
        constraints: const BoxConstraints(maxHeight: 720),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.outbox_rounded, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Sales / Dispatch Order', style: AppTypography.h2),
                          Text('Outbound fulfillment for ${archetype.name}', style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Destination / Customer Details
                      Text('Recipient & Destination Details', style: AppTypography.bodyBold),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customerController,
                              decoration: const InputDecoration(
                                labelText: 'Customer / Ward / Store Name *',
                                prefixIcon: Icon(Icons.person_pin_circle_outlined),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<CustomerType>(
                              initialValue: _customerType,
                              decoration: const InputDecoration(
                                labelText: 'Destination Type',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: CustomerType.values.map((t) {
                                return DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _customerType = v ?? CustomerType.b2bWholesale),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _destinationController,
                              decoration: const InputDecoration(
                                labelText: 'Delivery Station / Address / Ward *',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<OrderPriority>(
                              initialValue: _priority,
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                prefixIcon: Icon(Icons.bolt_outlined),
                              ),
                              items: OrderPriority.values.map((p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _priority = v ?? OrderPriority.standard),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Product Line Item
                      Text('Ordered Item Specification', style: AppTypography.bodyBold),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProductId ?? (products.isNotEmpty ? products.first.id : null),
                        decoration: const InputDecoration(
                          labelText: 'Select Product from Catalog *',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
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
                              _unitPrice = p.sellingPrice;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _quantity.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Requested Qty *',
                                prefixIcon: Icon(Icons.numbers_outlined),
                              ),
                              onChanged: (v) => _quantity = double.tryParse(v) ?? 5.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _unitPrice.toStringAsFixed(2),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Unit Price (\$) *',
                                prefixIcon: Icon(Icons.attach_money_outlined),
                              ),
                              onChanged: (v) => _unitPrice = double.tryParse(v) ?? 45.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Fulfillment Notes / Handling Instructions',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Order Value: \$${(_quantity * _unitPrice).toStringAsFixed(2)}',
                    style: AppTypography.h3.copyWith(color: theme.colorScheme.primary),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final prodId = _selectedProductId ?? (products.isNotEmpty ? products.first.id : 'prod_1');
                          final prod = products.firstWhere((p) => p.id == prodId, orElse: () => products.first);

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
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text('Confirm & Allocate Order'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
