import '../models/sales_order.dart';
import '../models/picking_wave.dart';

/// Service that aggregates Sales Orders into optimized Wave Picklists,
/// ordering pick tasks by priority, FEFO expiration dates, and physical walking path.
class WavePickingOptimizerEngine {
  const WavePickingOptimizerEngine();

  /// Converts a batch of Sales Orders into an optimized PickingWave with ordered PickTasks.
  PickingWave generateOptimizedWave({
    required List<SalesOrder> orders,
    String? assignedPickerId,
    String? assignedPickerName,
    String zone = 'Main Warehouse (Zone A)',
  }) {
    if (orders.isEmpty) {
      throw ArgumentError('Cannot generate a picking wave from an empty order list.');
    }

    final waveId = 'WAVE-${DateTime.now().millisecondsSinceEpoch}';
    final waveNumber = 'W-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // 1. Gather all line items from all participating orders
    final List<PickTask> rawTasks = [];

    for (final order in orders) {
      for (final item in order.items) {
        final loc = _deriveProductLocation(item.sku, order.archetypeId);
        final expiry = _extractExpiry(item.customAttributes);
        final batch = item.customAttributes['batchLot'] as String? ??
            item.customAttributes['batchNumber'] as String? ??
            'LOT-${item.sku.substring(0, (item.sku.length).clamp(0, 4))}-26';

        rawTasks.add(
          PickTask(
            id: 'TASK-${order.id}-${item.id}',
            orderId: order.id,
            soNumber: order.soNumber,
            productId: item.productId,
            productName: item.productName,
            sku: item.sku,
            location: loc,
            quantityToPick: item.requestedQty,
            uom: item.uom,
            batchLotNumber: batch,
            expiryDate: expiry,
            stepOrder: 0, // Assigned after sorting
          ),
        );
      }
    }

    // 2. Sort tasks by:
    //    a) Order Priority (Emergency Crash Cart first, then Rush, then Standard)
    //    b) FEFO: Items with nearest expiration date come first
    //    c) Physical location string (Aisle -> Rack -> Bin walking path)
    rawTasks.sort((a, b) {
      // Find parent order priority
      final orderA = orders.firstWhere((o) => o.id == a.orderId);
      final orderB = orders.firstWhere((o) => o.id == b.orderId);

      if (orderA.priority != orderB.priority) {
        return _priorityRank(orderB.priority).compareTo(_priorityRank(orderA.priority));
      }

      // FEFO Sort if expiry date is present on both
      if (a.expiryDate != null && b.expiryDate != null) {
        final expiryComp = a.expiryDate!.compareTo(b.expiryDate!);
        if (expiryComp != 0) return expiryComp;
      } else if (a.expiryDate != null) {
        return -1; // Items with expiry picked before non-perishables
      } else if (b.expiryDate != null) {
        return 1;
      }

      // Walking path alphanumeric location sort
      return a.location.compareTo(b.location);
    });

    // 3. Assign 1-indexed step orders for picker navigation
    final List<PickTask> sequencedTasks = [];
    for (int i = 0; i < rawTasks.length; i++) {
      sequencedTasks.add(rawTasks[i].copyWith(stepOrder: i + 1));
    }

    return PickingWave(
      id: waveId,
      waveNumber: waveNumber,
      assignedPickerId: assignedPickerId,
      assignedPickerName: assignedPickerName ?? 'Voice Picker Station #1',
      orderIds: orders.map((o) => o.id).toList(),
      tasks: sequencedTasks,
      createdAt: DateTime.now(),
      zone: zone,
    );
  }

  int _priorityRank(OrderPriority priority) {
    switch (priority) {
      case OrderPriority.emergencyCrashCart:
        return 3;
      case OrderPriority.rush:
        return 2;
      case OrderPriority.standard:
        return 1;
    }
  }

  DateTime? _extractExpiry(Map<String, dynamic> attributes) {
    final exp = attributes['expirationDate'] ?? attributes['expiryDate'] ?? attributes['expiry'];
    if (exp == null) return null;
    if (exp is DateTime) return exp;
    if (exp is String) {
      return DateTime.tryParse(exp);
    }
    return null;
  }

  String _deriveProductLocation(String sku, String archetypeId) {
    final hash = sku.hashCode.abs();
    final aisle = (hash % 6 + 1).toString().padLeft(2, '0');
    final rack = (hash % 4 + 1).toString().padLeft(2, '0');
    final bin = (hash % 10 + 1).toString().padLeft(2, '0');

    switch (archetypeId) {
      case 'healthcare_pharma':
        return 'Vault-V01 • Safe-$aisle • Locker-$bin';
      case 'grocery_foods':
        return 'ColdZone-C02 • Aisle-$aisle • Shelf-$rack • Bin-$bin';
      case 'electronics_tech':
        return 'Cage-E • Aisle-$aisle • Bay-$rack • Bin-$bin';
      case 'fashion_apparel':
        return 'Mezzanine-M • Rail-$aisle • Sec-$rack • Bin-$bin';
      case 'leather_textiles':
        return 'RollBay-L • Rack-$aisle • Slot-$bin';
      case 'hardware_industrial':
        return 'Floor-H • Aisle-$aisle • Bin-$bin';
      default:
        return 'Aisle-$aisle • Rack-$rack • Bin-$bin';
    }
  }
}
