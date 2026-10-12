import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/datasources/sample_data_source.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/result.dart';
import '../../domain/models/purchase_order.dart';
import '../../domain/models/qc_inspection.dart';
import '../../domain/models/putaway_task.dart';
import '../../domain/repositories/i_inbound_repository.dart';
import '../../domain/services/directed_putaway_engine.dart';

final inboundRepositoryProvider = Provider<IInboundRepository>((ref) {
  return InboundRepositoryImpl();
});

class InboundRepositoryImpl implements IInboundRepository {
  final List<PurchaseOrder> _orders = [];
  final List<QcInspectionReport> _qcReports = [];
  final List<PutawayTask> _putawayTasks = [];
  final DirectedPutawayEngine _putawayEngine;

  InboundRepositoryImpl({DirectedPutawayEngine? putawayEngine})
      : _putawayEngine = putawayEngine ?? const DirectedPutawayEngine() {
    _seedInitialData();
  }

  void _seedInitialData() {
    _orders.addAll(SampleDataSource.getPurchaseOrders());
    _qcReports.addAll(SampleDataSource.getQcReports());

    // Generate initial putaway tasks for putaway-ready orders
    for (final po in _orders.where((o) => o.status == InboundStatus.putawayReady || o.status == InboundStatus.receiving)) {
      for (final item in po.items) {
        _putawayTasks.add(
          _putawayEngine.createPutawayTask(
            poId: po.id,
            poNumber: po.poNumber,
            archetypeId: po.archetypeId,
            item: item,
          ),
        );
      }
    }
  }

  @override
  Future<Result<List<PurchaseOrder>>> getPurchaseOrders({
    InboundStatus? status,
    String? archetypeId,
  }) async {
    try {
      var filtered = List<PurchaseOrder>.from(_orders);
      if (status != null) {
        filtered = filtered.where((po) => po.status == status).toList();
      }
      if (archetypeId != null && archetypeId.isNotEmpty) {
        filtered = filtered.where((po) => po.archetypeId == archetypeId).toList();
      }
      return Result.success(filtered);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch purchase orders: $e'));
    }
  }

  @override
  Future<Result<PurchaseOrder>> getPurchaseOrderById(String id) async {
    try {
      final po = _orders.firstWhere((o) => o.id == id);
      return Result.success(po);
    } catch (_) {
      return Result.failure(const NotFoundFailure('Purchase order not found.'));
    }
  }

  @override
  Future<Result<PurchaseOrder>> createPurchaseOrder(PurchaseOrder po) async {
    try {
      _orders.insert(0, po);
      return Result.success(po);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create purchase order: $e'));
    }
  }

  @override
  Future<Result<PurchaseOrder>> updatePurchaseOrder(PurchaseOrder po) async {
    try {
      final index = _orders.indexWhere((o) => o.id == po.id);
      if (index >= 0) {
        _orders[index] = po;
        return Result.success(po);
      } else {
        _orders.insert(0, po);
        return Result.success(po);
      }
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update purchase order: $e'));
    }
  }

  @override
  Future<Result<PurchaseOrder>> updatePurchaseOrderStatus(
    String poId,
    InboundStatus newStatus,
  ) async {
    try {
      final index = _orders.indexWhere((o) => o.id == poId);
      if (index == -1) {
        return Result.failure(const NotFoundFailure('Purchase order not found.'));
      }
      final updated = _orders[index].copyWith(status: newStatus);
      _orders[index] = updated;
      return Result.success(updated);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update PO status: $e'));
    }
  }

  @override
  Future<Result<PurchaseOrder>> receiveGoods({
    required String poId,
    required List<PurchaseOrderItem> receivedItems,
    String? receivingDockId,
  }) async {
    try {
      final index = _orders.indexWhere((o) => o.id == poId);
      if (index == -1) {
        return Result.failure(const NotFoundFailure('Purchase order not found.'));
      }

      final current = _orders[index];
      final updated = current.copyWith(
        status: InboundStatus.qcPending,
        items: receivedItems,
        receivingDockId: receivingDockId ?? current.receivingDockId ?? 'Dock-01',
        actualArrivalDate: DateTime.now(),
      );
      _orders[index] = updated;

      return Result.success(updated);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to record received goods: $e'));
    }
  }

  @override
  Future<Result<QcInspectionReport>> submitQcInspection(QcInspectionReport report) async {
    try {
      _qcReports.insert(0, report);

      // Update parent PO status based on QC outcome
      final poIndex = _orders.indexWhere((o) => o.id == report.poId);
      if (poIndex != -1) {
        final po = _orders[poIndex];
        final nextStatus = (report.status == QcStatus.passed || report.status == QcStatus.passedWithDiscrepancy)
            ? InboundStatus.putawayReady
            : InboundStatus.qcFailed;

        _orders[poIndex] = po.copyWith(status: nextStatus);

        // If passed QC, automatically generate Directed Putaway Tasks
        if (nextStatus == InboundStatus.putawayReady) {
          for (final item in po.items) {
            final task = _putawayEngine.createPutawayTask(
              poId: po.id,
              poNumber: po.poNumber,
              archetypeId: po.archetypeId,
              item: item,
            );
            _putawayTasks.insert(0, task);
          }
        }
      }

      return Result.success(report);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to submit QC inspection: $e'));
    }
  }

  @override
  Future<Result<List<QcInspectionReport>>> getQcReports({String? poId}) async {
    try {
      if (poId != null) {
        return Result.success(_qcReports.where((r) => r.poId == poId).toList());
      }
      return Result.success(List.from(_qcReports));
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch QC reports: $e'));
    }
  }

  @override
  Future<Result<List<PutawayTask>>> getPutawayTasks({
    String? poId,
    PutawayStatus? status,
  }) async {
    try {
      var tasks = List<PutawayTask>.from(_putawayTasks);
      if (poId != null) {
        tasks = tasks.where((t) => t.poId == poId).toList();
      }
      if (status != null) {
        tasks = tasks.where((t) => t.status == status).toList();
      }
      return Result.success(tasks);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to fetch putaway tasks: $e'));
    }
  }

  @override
  Future<Result<PutawayTask>> confirmPutaway({
    required String taskId,
    required String confirmedLocation,
    String? operatorName,
  }) async {
    try {
      final index = _putawayTasks.indexWhere((t) => t.id == taskId);
      if (index == -1) {
        return Result.failure(const NotFoundFailure('Putaway task not found.'));
      }

      final task = _putawayTasks[index];
      final updated = task.copyWith(
        confirmedLocation: confirmedLocation,
        status: PutawayStatus.completed,
        completedAt: DateTime.now(),
        assignedOperator: operatorName ?? 'Floor Putaway Staging Crew',
      );
      _putawayTasks[index] = updated;

      // Check if all tasks for this PO are completed, if so mark PO as completed
      final remainingTasks = _putawayTasks.where((t) => t.poId == task.poId && t.status != PutawayStatus.completed).length;
      if (remainingTasks == 0) {
        final poIndex = _orders.indexWhere((o) => o.id == task.poId);
        if (poIndex != -1) {
          _orders[poIndex] = _orders[poIndex].copyWith(status: InboundStatus.completed);
        }
      }

      return Result.success(updated);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to confirm putaway: $e'));
    }
  }
}
