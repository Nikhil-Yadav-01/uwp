import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/inventory/domain/models/stock_transfer.dart';
import '../../../../core/inventory/presentation/controllers/inventory_ledger_controller.dart';
import '../../../../core/master_data/data/repositories/in_memory_master_data_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class StockTransferModal extends ConsumerStatefulWidget {
  const StockTransferModal({super.key});

  @override
  ConsumerState<StockTransferModal> createState() => _StockTransferModalState();
}

class _StockTransferModalState extends ConsumerState<StockTransferModal> {
  final _formKey = GlobalKey<FormState>();
  String _originWh = 'WH01';
  String _destWh = 'WH02';
  String _selectedSku = '';
  double _quantity = 10.0;
  String _carrier = 'BlueDart Air Logistics';
  String _trackingNumber = 'BD-882194829IN';
  String _notes = 'Stock balancing for anticipated weekly sales';

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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: Container(
        width: 600,
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
                          color: archetype.brandColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.swap_horiz_rounded, color: archetype.brandColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Inter-Warehouse Transfer', style: AppTypography.h2),
                          Text('Dispatch stock between physical depots with in-transit tracking', style: AppTypography.caption),
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

              // Warehouses Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _originWh,
                      decoration: const InputDecoration(labelText: 'Origin Warehouse (Source)'),
                      items: warehouses.map((wh) {
                        return DropdownMenuItem(value: wh.warehouseId, child: Text(wh.name, maxLines: 1, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) => setState(() => _originWh = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _destWh,
                      decoration: const InputDecoration(labelText: 'Destination Warehouse'),
                      items: warehouses.map((wh) {
                        return DropdownMenuItem(value: wh.warehouseId, child: Text(wh.name, maxLines: 1, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) => setState(() => _destWh = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // SKU & Quantity Row
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedSku,
                      decoration: const InputDecoration(labelText: 'Transfer Product / SKU'),
                      items: products.map((p) {
                        final sku = p['sku'] as String? ?? 'SKU';
                        final name = p['name'] as String? ?? 'Product';
                        return DropdownMenuItem(value: sku, child: Text('$sku - $name', maxLines: 1, overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedSku = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      initialValue: _quantity.toString(),
                      decoration: InputDecoration(
                        labelText: 'Quantity (${selectedProduct['uom'] ?? "units"})',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onSaved: (val) => _quantity = double.tryParse(val ?? '1') ?? 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Carrier & Tracking Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _carrier,
                      decoration: const InputDecoration(labelText: 'Logistics Carrier / Vehicle'),
                      onSaved: (val) => _carrier = val ?? '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _trackingNumber,
                      decoration: const InputDecoration(labelText: 'Airway Bill / Tracking #'),
                      onSaved: (val) => _trackingNumber = val ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Transfer Purpose / Notes'),
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

                        final originName = warehouses.firstWhere((w) => w.warehouseId == _originWh).name;
                        final destName = warehouses.firstWhere((w) => w.warehouseId == _destWh).name;

                        final transfer = StockTransfer(
                          transferId: 'TR-${Random().nextInt(9000) + 1000}',
                          transferNumber: 'TR-2026-${Random().nextInt(900) + 100}',
                          originWarehouseId: _originWh,
                          originWarehouseName: originName,
                          destinationWarehouseId: _destWh,
                          destinationWarehouseName: destName,
                          items: [
                            StockTransferItem(
                              productId: selectedProduct['id'] as String? ?? 'PROD-001',
                              productName: selectedProduct['name'] as String? ?? 'Product',
                              sku: _selectedSku,
                              quantity: _quantity,
                              uom: selectedProduct['uom'] as String? ?? 'units',
                              originBin: 'BIN-A01-01',
                              destinationBin: 'BIN-STAGING-01',
                            ),
                          ],
                          status: TransferStatus.inTransit,
                          carrier: _carrier,
                          trackingNumber: _trackingNumber,
                          notes: _notes,
                          requestedBy: 'Operations Dispatch Lead',
                          approvedBy: 'Central Hub Admin',
                          createdAt: DateTime.now(),
                          dispatchedAt: DateTime.now(),
                        );

                        ref.read(inventoryLedgerProvider.notifier).createTransfer(transfer);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Inter-Warehouse Transfer ${transfer.transferNumber} created (In-Transit)'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: archetype.brandColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Dispatch Transfer'),
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
