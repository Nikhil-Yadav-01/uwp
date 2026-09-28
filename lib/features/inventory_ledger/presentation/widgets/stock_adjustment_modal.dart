import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/inventory/domain/models/stock_adjustment.dart';
import '../../../../core/inventory/presentation/controllers/inventory_ledger_controller.dart';
import '../../../../core/master_data/data/repositories/in_memory_master_data_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class StockAdjustmentModal extends ConsumerStatefulWidget {
  const StockAdjustmentModal({super.key});

  static Future<void> show(BuildContext context) {
    return ModalShell.show(
      context: context,
      maxWidth: 600,
      child: const StockAdjustmentModal(),
    );
  }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final products = state.products;
    final warehouses = InMemoryMasterDataRepository().getWarehouses();

    if (_selectedSku.isEmpty && products.isNotEmpty) {
      _selectedSku = products.first['sku'] as String? ?? 'SKU-001';
    }

    final selectedProduct = products.firstWhere(
      (p) => (p['sku'] as String?) == _selectedSku,
      orElse: () => products.isNotEmpty ? products.first : {'name': 'Selected SKU', 'uom': 'units'},
    );

    final variance = _physicalQty - _systemQty;
    final varianceColor = variance < 0 ? AppColors.error : AppColors.success;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

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
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.error, size: AppSizes.iconMd),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record Stock Adjustment',
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        AppGap.h4,
                        Text(
                          'Log physical cycle count variance, damage or write-offs',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),

              // Warehouse & Location Row
              if (isNarrow) ...[
                DropdownButtonFormField<String>(
                  initialValue: _warehouseId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Warehouse'),
                  items: warehouses.map((wh) {
                    return DropdownMenuItem(value: wh.warehouseId, child: Text(wh.name, maxLines: 1, overflow: TextOverflow.ellipsis));
                  }).toList(),
                  onChanged: (val) => setState(() => _warehouseId = val!),
                ),
                AppGap.h12,
                TextFormField(
                  initialValue: _locationId,
                  decoration: const InputDecoration(labelText: 'Bin / Rack Location'),
                  onSaved: (val) => _locationId = val ?? 'BIN-01',
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _warehouseId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Warehouse'),
                        items: warehouses.map((wh) {
                          return DropdownMenuItem(value: wh.warehouseId, child: Text(wh.name, maxLines: 1, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) => setState(() => _warehouseId = val!),
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: TextFormField(
                        initialValue: _locationId,
                        decoration: const InputDecoration(labelText: 'Bin / Rack Location'),
                        onSaved: (val) => _locationId = val ?? 'BIN-01',
                      ),
                    ),
                  ],
                ),
              ],
              AppGap.h16,

              // Product Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSku,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Product / SKU to Adjust'),
                items: products.map((p) {
                  final sku = p['sku'] as String? ?? 'SKU';
                  final name = p['name'] as String? ?? 'Product';
                  return DropdownMenuItem(value: sku, child: Text('$sku - $name', maxLines: 1, overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSku = val!),
              ),
              AppGap.h16,

              // System vs Physical Count
              if (isNarrow) ...[
                TextFormField(
                  initialValue: _systemQty.toString(),
                  decoration: InputDecoration(
                    labelText: 'Current System Qty (${selectedProduct['uom'] ?? "units"})',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => setState(() => _systemQty = double.tryParse(val) ?? 0.0),
                ),
                AppGap.h12,
                TextFormField(
                  initialValue: _physicalQty.toString(),
                  decoration: InputDecoration(
                    labelText: 'Actual Physical Count (${selectedProduct['uom'] ?? "units"})',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => setState(() => _physicalQty = double.tryParse(val) ?? 0.0),
                ),
              ] else ...[
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
                    AppGap.w12,
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
              ],
              AppGap.h12,

              // Live Variance Indicator Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: varianceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                  border: Border.all(color: varianceColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Calculated Variance:', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${variance >= 0 ? "+" : ""}$variance ${selectedProduct['uom'] ?? "units"}',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: varianceColor,
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h16,

              // Reason Code
              DropdownButtonFormField<AdjustmentReason>(
                initialValue: _reason,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Adjustment Reason'),
                items: AdjustmentReason.values.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(reason.icon, size: 16, color: colorScheme.primary),
                        AppGap.w8,
                        Flexible(child: Text(reason.displayName, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _reason = val!),
              ),
              AppGap.h16,

              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(labelText: 'Reason Notes / Auditor Signoff'),
                onSaved: (val) => _notes = val ?? '',
              ),
              AppGap.h24,

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  AppGap.w12,
                  FilledButton.icon(
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
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
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
        );
      },
    );
  }
}
