import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/inventory/domain/models/stock_adjustment.dart';
import '../../../../core/inventory/presentation/controllers/inventory_ledger_controller.dart';
import '../../../../core/master_data/data/repositories/in_memory_master_data_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class StockAdjustmentModal extends ConsumerStatefulWidget {
  const StockAdjustmentModal({super.key});

  @override
  ConsumerState<StockAdjustmentModal> createState() => _StockAdjustmentModalState();
}

class _StockAdjustmentModalState extends ConsumerState<StockAdjustmentModal> {
  final _formKey = GlobalKey<FormState>();
  String _warehouseId = 'WH01';
  String _locationId = 'BIN-A01-01';
  String _selectedSku = '';
  double _systemQty = 50.0;
  double _physicalQty = 48.0;
  AdjustmentReason _reason = AdjustmentReason.damaged;
  String _notes = 'Damage found during cycle count routine';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final products = state.products;
    final warehouses = InMemoryMasterDataRepository().getWarehouses();

    if (_selectedSku.isEmpty && products.isNotEmpty) {
      _selectedSku = products.first['sku'] as String? ?? 'SKU-001';
    }

    final selectedProduct = products.firstWhere(
      (p) => (p['sku'] as String?) == _selectedSku,
      orElse: () => products.isNotEmpty ? products.first : {'name': 'Selected SKU', 'uom': 'unit'},
    );

    final variance = _physicalQty - _systemQty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune_rounded, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Record Stock Adjustment', style: AppTypography.h2),
                          Text('Log physical cycle count variance, damage or write-offs', style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Warehouse & Location Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _warehouseId,
                      decoration: const InputDecoration(labelText: 'Warehouse'),
                      items: warehouses.map((wh) {
                        return DropdownMenuItem(value: wh.warehouseId, child: Text(wh.name, maxLines: 1, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) => setState(() => _warehouseId = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _locationId,
                      decoration: const InputDecoration(labelText: 'Bin / Rack Location'),
                      onSaved: (val) => _locationId = val ?? 'BIN-01',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSku,
                decoration: const InputDecoration(labelText: 'Product / SKU to Adjust'),
                items: products.map((p) {
                  final sku = p['sku'] as String? ?? 'SKU';
                  final name = p['name'] as String? ?? 'Product';
                  return DropdownMenuItem(value: sku, child: Text('$sku - $name', maxLines: 1, overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSku = val!),
              ),
              const SizedBox(height: 16),

              // System vs Physical Count
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _systemQty.toString(),
                      decoration: InputDecoration(
                        labelText: 'Current System Qty (${selectedProduct['uom'] ?? "units"})',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) => setState(() => _systemQty = double.tryParse(val) ?? 0.0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _physicalQty.toString(),
                      decoration: InputDecoration(
                        labelText: 'Actual Physical Count (${selectedProduct['uom'] ?? "units"})',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) => setState(() => _physicalQty = double.tryParse(val) ?? 0.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Live Variance Indicator Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: variance < 0 ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: variance < 0 ? Colors.red : Colors.green),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Calculated Variance:', style: AppTypography.bodyBold),
                    Text(
                      '${variance >= 0 ? "+" : ""}$variance ${selectedProduct['uom'] ?? "units"}',
                      style: AppTypography.h3.copyWith(color: variance < 0 ? Colors.red : Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reason Code
              DropdownButtonFormField<AdjustmentReason>(
                initialValue: _reason,
                decoration: const InputDecoration(labelText: 'Adjustment Reason'),
                items: AdjustmentReason.values.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Row(
                      children: [
                        Icon(reason.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(reason.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _reason = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Reason Notes / Auditor Signoff'),
                onSaved: (val) => _notes = val ?? '',
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();

                        final whName = warehouses.firstWhere((w) => w.warehouseId == _warehouseId).name;

                        final adj = StockAdjustment(
                          adjustmentId: 'ADJ-${Random().nextInt(9000) + 1000}',
                          adjustmentNumber: 'ADJ-2026-${Random().nextInt(900) + 100}',
                          warehouseId: _warehouseId,
                          warehouseName: whName,
                          locationId: _locationId,
                          productId: selectedProduct['id'] as String? ?? 'PROD-001',
                          productName: selectedProduct['name'] as String? ?? 'Product',
                          sku: _selectedSku,
                          systemQuantity: _systemQty,
                          physicalQuantity: _physicalQty,
                          varianceQuantity: variance,
                          uom: selectedProduct['uom'] as String? ?? 'units',
                          reason: _reason,
                          notes: _notes,
                          createdBy: 'Inventory Auditor',
                          approvedBy: 'Warehouse Manager',
                          createdAt: DateTime.now(),
                        );

                        ref.read(inventoryLedgerProvider.notifier).recordAdjustment(adj);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Stock Adjustment ${adj.adjustmentNumber} recorded in Ledger'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: archetype.brandColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Apply Stock Adjustment'),
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
