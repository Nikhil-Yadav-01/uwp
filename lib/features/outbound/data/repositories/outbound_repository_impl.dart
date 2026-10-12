import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/datasources/sample_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/result.dart';
import '../../domain/models/sales_order.dart';
import '../../domain/models/picking_wave.dart';
import '../../domain/models/packing_session.dart';
import '../../domain/repositories/i_outbound_repository.dart';
import '../../domain/services/wave_picking_optimizer_engine.dart';

final outboundRepositoryProvider = Provider<IOutboundRepository>((ref) {
  return OutboundRepositoryImpl();
});

class OutboundRepositoryImpl implements IOutboundRepository {
  final List<SalesOrder> _orders = [];
  final List<PickingWave> _waves = [];
  final List<PackingSession> _packingSessions = [];
  final WavePickingOptimizerEngine _waveEngine;

  OutboundRepositoryImpl({WavePickingOptimizerEngine? waveEngine})
      : _waveEngine = waveEngine ?? const WavePickingOptimizerEngine() {
    _seedInitialData();
  }

  void _seedInitialData() {
    _orders.addAll(SampleDataSource.getSalesOrders());

    // Generate initial picking wave for picking orders
    final pickingOrders = _orders.where((o) => o.status == OutboundStatus.picking || o.status == OutboundStatus.allocated).toList();
    if (pickingOrders.isNotEmpty) {
      final wave1 = _waveEngine.generateOptimizedWave(
        orders: pickingOrders,
        assignedPickerName: 'Alex Carter (Voice Picking PDA #3)',
        zone: 'Zone A & High-Security Vault Zone',
      );
      _waves.add(wave1);
    }

    _packingSessions.addAll(SampleDataSource.getPackingSessions());
  }

  @override
  Future<Result<List<SalesOrder>>> getSalesOrders({
    OutboundStatus? status,
    String? archetypeId,
  }) async {
    try {
      var filtered = List<SalesOrder>.from(_orders);
      if (status != null) {
        filtered = filtered.where((o) => o.status == status).toList();
      }
      if (archetypeId != null && archetypeId.isNotEmpty) {
        filtered = filtered.where((o) => o.archetypeId == archetypeId).toList();
      }
      return Result.success(filtered);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch sales orders: $e'));
    }
  }

  @override
  Future<Result<SalesOrder>> getSalesOrderById(String id) async {
    try {
      final order = _orders.firstWhere((o) => o.id == id);
      return Result.success(order);
    } catch (_) {
      return Result.failure(const NotFoundFailure('Sales order not found.'));
    }
  }

  @override
  Future<Result<SalesOrder>> createSalesOrder(SalesOrder order) async {
    try {
      _orders.insert(0, order);
      return Result.success(order);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create sales order: $e'));
    }
  }

  @override
  Future<Result<SalesOrder>> updateSalesOrder(SalesOrder order) async {
    try {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index >= 0) {
        _orders[index] = order;
        return Result.success(order);
      } else {
        _orders.insert(0, order);
        return Result.success(order);
      }
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update sales order: $e'));
    }
  }

  @override
  Future<Result<SalesOrder>> updateSalesOrderStatus(
    String orderId,
    OutboundStatus newStatus,
  ) async {
    try {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index == -1) {
        return Result.failure(const NotFoundFailure('Sales order not found.'));
      }
      final updated = _orders[index].copyWith(status: newStatus);
      _orders[index] = updated;
      return Result.success(updated);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update order status: $e'));
    }
  }

  @override
  Future<Result<PickingWave>> generatePickingWave({
    required List<String> orderIds,
    String? assignedPickerName,
    String? zone,
  }) async {
    try {
      final targetOrders = _orders.where((o) => orderIds.contains(o.id)).toList();
      if (targetOrders.isEmpty) {
        return Result.failure(const ValidationFailure('No matching orders found for wave generation.'));
      }

      final wave = _waveEngine.generateOptimizedWave(
        orders: targetOrders,
        assignedPickerName: assignedPickerName,
        zone: zone ?? 'Zone A (Main Warehouse)',
      );

      _waves.insert(0, wave);

      // Mark selected orders as waveAssigned / picking
      for (final orderId in orderIds) {
        final idx = _orders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _orders[idx] = _orders[idx].copyWith(
            status: OutboundStatus.picking,
            assignedWaveId: wave.id,
          );
        }
      }

      return Result.success(wave);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to generate picking wave: $e'));
    }
  }

  @override
  Future<Result<List<PickingWave>>> getActiveWaves() async {
    try {
      return Result.success(List.from(_waves));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch active waves: $e'));
    }
  }

  @override
  Future<Result<PickingWave>> confirmPickTask({
    required String waveId,
    required String taskId,
    required double quantityPicked,
  }) async {
    try {
      final waveIdx = _waves.indexWhere((w) => w.id == waveId);
      if (waveIdx == -1) {
        return Result.failure(const NotFoundFailure('Picking wave not found.'));
      }

      final wave = _waves[waveIdx];
      final taskIdx = wave.tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx == -1) {
        return Result.failure(const NotFoundFailure('Pick task not found.'));
      }

      final task = wave.tasks[taskIdx];
      final updatedTask = task.copyWith(
        quantityPicked: quantityPicked,
        isConfirmed: true,
      );

      final updatedTasks = List<PickTask>.from(wave.tasks);
      updatedTasks[taskIdx] = updatedTask;

      final allDone = updatedTasks.every((t) => t.isCompleted);
      final updatedWave = wave.copyWith(
        tasks: updatedTasks,
        status: allDone ? WaveStatus.completed : WaveStatus.inProgress,
        completedAt: allDone ? DateTime.now() : null,
      );

      _waves[waveIdx] = updatedWave;

      // Update corresponding order item pickedQty
      final orderIdx = _orders.indexWhere((o) => o.id == task.orderId);
      if (orderIdx != -1) {
        final order = _orders[orderIdx];
        final updatedItems = order.items.map((item) {
          if (item.productId == task.productId) {
            return item.copyWith(pickedQty: (item.pickedQty + quantityPicked).clamp(0.0, item.requestedQty));
          }
          return item;
        }).toList();

        final orderAllPicked = updatedItems.every((i) => i.isFullyPicked);
        _orders[orderIdx] = order.copyWith(
          items: updatedItems,
          status: orderAllPicked ? OutboundStatus.picked : OutboundStatus.picking,
        );
      }

      return Result.success(updatedWave);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to confirm pick task: $e'));
    }
  }

  @override
  Future<Result<PackingSession>> startPackingSession(String orderId) async {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      final session = PackingSession(
        id: 'PACK-${DateTime.now().millisecondsSinceEpoch}',
        orderId: order.id,
        soNumber: order.soNumber,
        customerName: order.customerName,
        destination: order.destinationWardOrAddress,
        packerName: 'Floor Packing Operator #1',
        startedAt: DateTime.now(),
        status: PackingStatus.inProgress,
      );

      _packingSessions.insert(0, session);

      // Update order status to packing
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(status: OutboundStatus.packing);
      }

      return Result.success(session);
    } catch (_) {
      return Result.failure(const NotFoundFailure('Order not found to start packing.'));
    }
  }

  @override
  Future<Result<PackingSession>> verifyScanItem({
    required String sessionId,
    required String scannedBarcode,
  }) async {
    try {
      final sessIdx = _packingSessions.indexWhere((s) => s.id == sessionId);
      if (sessIdx == -1) {
        return Result.failure(const NotFoundFailure('Packing session not found.'));
      }

      final session = _packingSessions[sessIdx];
      final order = _orders.firstWhere((o) => o.id == session.orderId);

      // Check if scanned barcode matches any item SKU or barcode in the order
      final matchingItem = order.items.firstWhere(
        (i) => i.sku.toLowerCase() == scannedBarcode.toLowerCase() ||
               scannedBarcode.toLowerCase().contains(i.sku.toLowerCase()),
        orElse: () => throw const FormatException('Barcode does not match any item in this sales order.'),
      );

      final newPackedItem = PackedItem(
        productId: matchingItem.productId,
        productName: matchingItem.productName,
        sku: matchingItem.sku,
        barcode: scannedBarcode,
        quantity: 1.0,
        uom: matchingItem.uom,
        scannedAt: DateTime.now(),
      );

      final updatedScanned = List<PackedItem>.from(session.scannedItems)..add(newPackedItem);
      final updatedSession = session.copyWith(scannedItems: updatedScanned);
      _packingSessions[sessIdx] = updatedSession;

      return Result.success(updatedSession);
    } on FormatException catch (e) {
      return Result.failure(ValidationFailure(e.message));
    } catch (e) {
      return Result.failure(DatabaseFailure('Scan verification failed: $e'));
    }
  }

  @override
  Future<Result<PackingSession>> completePackingAndShip({
    required String sessionId,
    required double totalWeightKg,
    required String carrier,
    required int boxCount,
  }) async {
    try {
      final sessIdx = _packingSessions.indexWhere((s) => s.id == sessionId);
      if (sessIdx == -1) {
        return Result.failure(const NotFoundFailure('Packing session not found.'));
      }

      final session = _packingSessions[sessIdx];
      final trackingNum = 'TRK-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final magicLink = 'https://wms.universal.io/track/$trackingNum';

      final completedSession = session.copyWith(
        status: PackingStatus.dispatched,
        totalWeightKg: totalWeightKg,
        shippingCarrier: carrier,
        boxCount: boxCount,
        trackingNumber: trackingNum,
        magicTrackingUrl: magicLink,
        completedAt: DateTime.now(),
      );

      _packingSessions[sessIdx] = completedSession;

      // Update Sales Order to shipped
      final orderIdx = _orders.indexWhere((o) => o.id == session.orderId);
      if (orderIdx != -1) {
        _orders[orderIdx] = _orders[orderIdx].copyWith(status: OutboundStatus.shipped);
      }

      return Result.success(completedSession);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to complete packing: $e'));
    }
  }
}
