import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final now = DateTime.now();

    // 1. Healthcare / Pharma PO: Cold-chain antibiotic & Schedule II Narcotic
    final pharmaPO = PurchaseOrder(
      id: 'PO-HC-001',
      poNumber: 'PO-2026-PHARMA-01',
      vendorName: 'Novartis & Pfizer Bio-Distribution Ltd',
      vendorEmail: 'procure@novartis-pharma.org',
      orderDate: now.subtract(const Duration(days: 2)),
      expectedDeliveryDate: now.add(const Duration(days: 1)),
      status: InboundStatus.qcPending,
      archetypeId: 'healthcare_pharma',
      receivingDockId: 'Dock-03 (Cold-Chain Staging)',
      actualArrivalDate: now.subtract(const Duration(hours: 4)),
      notes: 'Contains Schedule II Controlled Narcotics & 4°C Cold-Chain Vaccines. Dual-signoff mandatory.',
      items: [
        PurchaseOrderItem(
          id: 'POI-HC-01',
          productId: 'prod_hc_1',
          productName: 'Amoxicillin 500mg Trihydrate Capsules',
          sku: 'HC-AMX-500-BX',
          orderedQty: 100.0,
          receivedQty: 100.0,
          unitPrice: 14.50,
          uom: 'box',
          customAttributes: {
            'ndcNumber': '0093-3147-01',
            'batchLot': 'LOT-AMX-2026B',
            'expiryDate': now.add(const Duration(days: 730)).toIso8601String(),
            'controlledSchedule': 'None (Rx Only)',
            'requiresColdChain': false,
            'storageTemp': 'Ambient (15°C to 25°C)',
          },
        ),
        PurchaseOrderItem(
          id: 'POI-HC-02',
          productId: 'prod_hc_3',
          productName: 'Fentanyl Citrate 50mcg/ml Injection (Ampoule 2ml)',
          sku: 'HC-FNT-50MCG-AMP',
          orderedQty: 50.0,
          receivedQty: 50.0,
          unitPrice: 88.00,
          uom: 'vial',
          customAttributes: {
            'ndcNumber': '0409-9093-22',
            'batchLot': 'LOT-FNT-9981-SEC',
            'expiryDate': now.add(const Duration(days: 365)).toIso8601String(),
            'controlledSchedule': 'Schedule II (C-II Narcotic)',
            'isNarcotic': true,
            'requiresDualSignoff': true,
            'storageTemp': 'Secure Vault (Double-Lock)',
          },
        ),
      ],
    );

    // 2. Grocery & Perishables PO: Cold-chain Organic Milk & Farm Berries
    final groceryPO = PurchaseOrder(
      id: 'PO-GROC-002',
      poNumber: 'PO-2026-GROC-89',
      vendorName: 'Alpine Organic Farms & Dairy Coop',
      vendorEmail: 'orders@alpinedairy.com',
      orderDate: now.subtract(const Duration(days: 1)),
      expectedDeliveryDate: now,
      status: InboundStatus.atDock,
      archetypeId: 'grocery_foods',
      receivingDockId: 'Dock-01 (Chiller Bay)',
      actualArrivalDate: now.subtract(const Duration(hours: 1)),
      notes: 'Chilled delivery. Check temperature logger upon opening refrigerated truck seal.',
      items: [
        PurchaseOrderItem(
          id: 'POI-GROC-01',
          productId: 'prod_groc_1',
          productName: 'Organic Whole Milk (1L Glass Bottle)',
          sku: 'GROC-MILK-1L',
          orderedQty: 240.0,
          receivedQty: 240.0,
          unitPrice: 3.20,
          uom: 'carton',
          customAttributes: {
            'batchLot': 'LOT-MLK-8812',
            'expirationDate': now.add(const Duration(days: 14)).toIso8601String(),
            'storageZone': 'Chilled (+4°C)',
            'measuredDockTemp': '+3.6°C',
          },
        ),
      ],
    );

    // 3. Electronics PO: Flagship Smartphones
    final techPO = PurchaseOrder(
      id: 'PO-TECH-003',
      poNumber: 'PO-2026-TECH-44',
      vendorName: 'Apex Mobile Distro Corp',
      orderDate: now.subtract(const Duration(days: 3)),
      status: InboundStatus.putawayReady,
      archetypeId: 'electronics_tech',
      receivingDockId: 'Dock-02',
      items: [
        PurchaseOrderItem(
          id: 'POI-TECH-01',
          productId: 'prod_tech_1',
          productName: 'Apex Phone 16 Pro (256GB Midnight Black)',
          sku: 'TECH-APEX16P-256-BLK',
          orderedQty: 30.0,
          receivedQty: 30.0,
          unitPrice: 899.00,
          uom: 'unit',
          customAttributes: {
            'serialTrackingRequired': true,
            'conditionGrade': 'Brand New (Factory Sealed)',
            'imeiCount': 30,
          },
        ),
      ],
    );

    // 4. Leather & Textiles PO: Full Grain Bovine Hides
    final leatherPO = PurchaseOrder(
      id: 'PO-LTHR-004',
      poNumber: 'PO-2026-LTHR-12',
      vendorName: 'Toscana Tannery S.p.A.',
      orderDate: now.subtract(const Duration(days: 4)),
      status: InboundStatus.inTransit,
      archetypeId: 'leather_textiles',
      items: [
        PurchaseOrderItem(
          id: 'POI-LTHR-01',
          productId: 'prod_lthr_1',
          productName: 'Full-Grain Italian Cowhide (Cognac Brown)',
          sku: 'LTHR-IT-CGN-50',
          orderedQty: 1200.0,
          unitPrice: 9.80,
          uom: 'sq ft',
          customAttributes: {
            'tanneryLot': 'TOSC-2026-B9',
            'hideGrade': 'Grade A (Zero Grain Defects)',
            'thickness': '1.8mm (4.5 oz)',
          },
        ),
      ],
    );

    // 5. Hospitality PO: Craft IPA Kegs
    final barPO = PurchaseOrder(
      id: 'PO-BAR-005',
      poNumber: 'PO-2026-BAR-55',
      vendorName: 'Highland Craft Brewery Ltd',
      orderDate: now.subtract(const Duration(days: 1)),
      status: InboundStatus.approved,
      archetypeId: 'bars_hospitality',
      items: [
        PurchaseOrderItem(
          id: 'POI-BAR-01',
          productId: 'prod_bar_1',
          productName: 'Highland Single Malt Scotch (750ml, 43% ABV)',
          sku: 'BAR-SCOTCH-750',
          orderedQty: 24.0,
          unitPrice: 42.00,
          uom: 'bottle',
          customAttributes: {
            'abv': '43.0%',
            'vintage': '12 Year Aged',
            'caskType': 'Sherry Oak Finish',
          },
        ),
      ],
    );

    _orders.addAll([pharmaPO, groceryPO, techPO, leatherPO, barPO]);

    // Initial QC Inspection Report for Pharma PO
    _qcReports.add(
      QcInspectionReport(
        id: 'QC-REP-001',
        poId: pharmaPO.id,
        poNumber: pharmaPO.poNumber,
        inspectorName: 'Dr. Sarah Jenkins (Lead Pharmacist)',
        witnessName: 'Officer Marcus Vance (Security Supervisor)',
        inspectionDate: now.subtract(const Duration(hours: 2)),
        status: QcStatus.passed,
        requiresDualSignoff: true,
        isDualSigned: true,
        overallNotes: 'Narcotics seal intact. Temperature data logger verified +4.1°C throughout transit. Zero vial breakage.',
        itemResults: [
          QcItemResult(
            productId: 'prod_hc_1',
            productName: 'Amoxicillin 500mg Trihydrate Capsules',
            sku: 'HC-AMX-500-BX',
            inspectedQty: 100.0,
            passedQty: 100.0,
            testMetrics: {'batchSeal': 'Passed', 'cartonIntegrity': '100%'},
          ),
          QcItemResult(
            productId: 'prod_hc_3',
            productName: 'Fentanyl Citrate 50mcg/ml Injection (Ampoule 2ml)',
            sku: 'HC-FNT-50MCG-AMP',
            inspectedQty: 50.0,
            passedQty: 50.0,
            testMetrics: {'vaultKey1': 'Validated', 'vaultKey2': 'Validated', 'narcoticCount': 'Exact 50'},
          ),
        ],
      ),
    );

    // Initial Putaway Tasks for Tech PO
    for (final item in techPO.items) {
      _putawayTasks.add(
        _putawayEngine.createPutawayTask(
          poId: techPO.id,
          poNumber: techPO.poNumber,
          archetypeId: techPO.archetypeId,
          item: item,
        ),
      );
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
