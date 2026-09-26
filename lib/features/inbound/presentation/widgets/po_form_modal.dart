import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../../products/presentation/controllers/product_controller.dart';
import '../../domain/models/purchase_order.dart';
import '../controllers/inbound_controller.dart';

class PoFormModal extends ConsumerStatefulWidget {
  const PoFormModal({super.key});

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
                        child: Icon(Icons.note_add_rounded, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create Purchase Order', style: AppTypography.h2),
                          Text('Inbound intake for ${archetype.name}', style: AppTypography.caption),
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
                      // Vendor Details
                      Text('Vendor Information', style: AppTypography.bodyBold),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _vendorController,
                              decoration: const InputDecoration(
                                labelText: 'Vendor / Supplier Name *',
                                prefixIcon: Icon(Icons.business_outlined),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Vendor Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Product Line Item
                      Text('Line Item & Receiving Specifications', style: AppTypography.bodyBold),
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
                              _unitPrice = p.costPrice > 0 ? p.costPrice : p.sellingPrice * 0.7;
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
                                labelText: 'Ordered Quantity *',
                                prefixIcon: Icon(Icons.numbers_outlined),
                              ),
                              onChanged: (v) => _quantity = double.tryParse(v) ?? 10.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _unitPrice.toStringAsFixed(2),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Unit Cost (\$) *',
                                prefixIcon: Icon(Icons.attach_money_outlined),
                              ),
                              onChanged: (v) => _unitPrice = double.tryParse(v) ?? 25.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Archetype-Specific Line Attributes Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.tune_rounded, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Archetype Compliance & Receiving Controls',
                                  style: AppTypography.captionBold.copyWith(color: theme.colorScheme.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (archetype.id == 'healthcare_pharma') ...[
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'NDC / Drug License Number',
                                  isDense: true,
                                ),
                                onChanged: (v) => _customAttributes['ndcNumber'] = v,
                              ),
                              const SizedBox(height: 8),
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
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Dock Temperature Check Requirement (e.g. +4°C)',
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
                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Special Receiving Instructions / Notes',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Est. Total: \$${(_quantity * _unitPrice).toStringAsFixed(2)}',
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
                          if (context.mounted && success) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Created Purchase Order ${newPO.poNumber}'),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Submit & Approve PO'),
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
