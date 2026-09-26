import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/features/inbound/domain/models/purchase_order.dart';
import 'package:warehouse/features/inbound/domain/models/qc_inspection.dart';
import 'package:warehouse/features/inbound/domain/models/putaway_task.dart';
import 'package:warehouse/features/inbound/domain/services/directed_putaway_engine.dart';
import 'package:warehouse/features/inbound/data/repositories/inbound_repository_impl.dart';
import 'package:warehouse/features/outbound/domain/models/sales_order.dart';
import 'package:warehouse/features/outbound/domain/models/packing_session.dart';
import 'package:warehouse/features/outbound/domain/services/wave_picking_optimizer_engine.dart';
import 'package:warehouse/features/outbound/data/repositories/outbound_repository_impl.dart';

void main() {
  group('Phase 3: Inbound & Directed Putaway Tests', () {
    const putawayEngine = DirectedPutawayEngine();

    test('DirectedPutawayEngine resolves correct storage zones for each archetype', () {
      // Healthcare Narcotics -> Vault
      final vaultZone = putawayEngine.resolveZoneType(
        archetypeId: 'healthcare_pharma',
        customAttributes: {'isNarcotic': true, 'controlledSchedule': 'Schedule II'},
      );
      expect(vaultZone, equals(StorageZoneType.narcoticsVault));

      // Healthcare Cold-Chain -> Cold Room
      final coldZone = putawayEngine.resolveZoneType(
        archetypeId: 'healthcare_pharma',
        customAttributes: {'requiresColdChain': true, 'storageTemp': 'Chilled (+2°C to +8°C)'},
      );
      expect(coldZone, equals(StorageZoneType.coldRoomChilled));

      // Grocery Frozen -> Deep Frozen
      final frozenZone = putawayEngine.resolveZoneType(
        archetypeId: 'grocery_foods',
        customAttributes: {'storageZone': 'Deep Frozen (-18°C)'},
      );
      expect(frozenZone, equals(StorageZoneType.deepFrozen));

      // Electronics -> Secure Cage
      final techZone = putawayEngine.resolveZoneType(
        archetypeId: 'electronics_tech',
        customAttributes: {},
      );
      expect(techZone, equals(StorageZoneType.secureHighValueCage));

      // Fashion -> Hanging Racks
      final fashionZone = putawayEngine.resolveZoneType(
        archetypeId: 'fashion_apparel',
        customAttributes: {},
      );
      expect(fashionZone, equals(StorageZoneType.hangingRacks));

      // Hardware HAZMAT -> Flammable Cabinet
      final hazmatZone = putawayEngine.resolveZoneType(
        archetypeId: 'hardware_industrial',
        customAttributes: {'isHazmat': true, 'hazmatClass': 'Class 3'},
      );
      expect(hazmatZone, equals(StorageZoneType.flammableHazmat));
    });

    test('DirectedPutawayEngine generates deterministic shelf coordinates', () {
      final loc = putawayEngine.generateSuggestedBinLocation(
        zoneType: StorageZoneType.coldRoomChilled,
        sku: 'GROC-MILK-1L',
      );
      expect(loc, contains('ColdZone-A'));
      expect(loc, contains('+4°C'));
    });

    test('InboundRepositoryImpl creates PO, receives dock goods, and executes QC pass', () async {
      final repo = InboundRepositoryImpl();

      final listResult = await repo.getPurchaseOrders();
      expect(listResult.isSuccess, isTrue);
      final initialCount = listResult.dataOrNull!.length;
      expect(initialCount, greaterThanOrEqualTo(5));

      // Create new PO
      final newPO = PurchaseOrder(
        id: 'PO-TEST-001',
        poNumber: 'PO-2026-TEST-99',
        vendorName: 'Test Bio Supply',
        orderDate: DateTime.now(),
        status: InboundStatus.approved,
        archetypeId: 'healthcare_pharma',
        items: [
          const PurchaseOrderItem(
            id: 'POI-1',
            productId: 'p1',
            productName: 'Test Vaccine',
            sku: 'HC-VAC-01',
            orderedQty: 50.0,
            unitPrice: 20.0,
            uom: 'vial',
          ),
        ],
      );

      final createRes = await repo.createPurchaseOrder(newPO);
      expect(createRes.isSuccess, isTrue);

      // Receive Dock Goods
      final receiveRes = await repo.receiveGoods(
        poId: 'PO-TEST-001',
        receivedItems: [
          newPO.items.first.copyWith(receivedQty: 50.0),
        ],
      );
      expect(receiveRes.isSuccess, isTrue);
      expect(receiveRes.dataOrNull!.status, equals(InboundStatus.qcPending));

      // Submit QC Inspection
      final qcReport = QcInspectionReport(
        id: 'QC-TEST-01',
        poId: 'PO-TEST-001',
        poNumber: 'PO-2026-TEST-99',
        inspectorName: 'Chief Inspector',
        inspectionDate: DateTime.now(),
        status: QcStatus.passed,
        itemResults: [
          const QcItemResult(
            productId: 'p1',
            productName: 'Test Vaccine',
            sku: 'HC-VAC-01',
            inspectedQty: 50.0,
            passedQty: 50.0,
          ),
        ],
      );

      final qcRes = await repo.submitQcInspection(qcReport);
      expect(qcRes.isSuccess, isTrue);

      // Verify PO updated to putawayReady and putaway task was created
      final updatedPo = await repo.getPurchaseOrderById('PO-TEST-001');
      expect(updatedPo.dataOrNull!.status, equals(InboundStatus.putawayReady));

      final putawayTasks = await repo.getPutawayTasks(poId: 'PO-TEST-001');
      expect(putawayTasks.isSuccess, isTrue);
      expect(putawayTasks.dataOrNull!.length, equals(1));
    });
  });

  group('Phase 3: Outbound & Wave Optimization Tests', () {
    const waveEngine = WavePickingOptimizerEngine();

    test('WavePickingOptimizerEngine prioritizes Emergency orders and FEFO expiry', () {
      final now = DateTime.now();

      final standardOrder = SalesOrder(
        id: 'SO-STD',
        soNumber: 'SO-STD-01',
        customerName: 'Standard Customer',
        customerType: CustomerType.retailStore,
        destinationWardOrAddress: 'Store 1',
        orderDate: now,
        priority: OrderPriority.standard,
        status: OutboundStatus.allocated,
        archetypeId: 'grocery_foods',
        items: [
          SalesOrderItem(
            id: 'ITM-1',
            productId: 'p1',
            productName: 'Later Expiry Cheese',
            sku: 'GROC-CHS-01',
            requestedQty: 10.0,
            unitPrice: 5.0,
            uom: 'pack',
            customAttributes: {
              'expirationDate': now.add(const Duration(days: 30)).toIso8601String(),
            },
          ),
        ],
      );

      final fefoOrder = SalesOrder(
        id: 'SO-FEFO',
        soNumber: 'SO-FEFO-02',
        customerName: 'FEFO Store',
        customerType: CustomerType.retailStore,
        destinationWardOrAddress: 'Store 2',
        orderDate: now,
        priority: OrderPriority.standard,
        status: OutboundStatus.allocated,
        archetypeId: 'grocery_foods',
        items: [
          SalesOrderItem(
            id: 'ITM-2',
            productId: 'p2',
            productName: 'Near Expiry Fresh Milk',
            sku: 'GROC-MLK-02',
            requestedQty: 5.0,
            unitPrice: 3.0,
            uom: 'bottle',
            customAttributes: {
              'expirationDate': now.add(const Duration(days: 3)).toIso8601String(),
            },
          ),
        ],
      );

      final emergencyOrder = SalesOrder(
        id: 'SO-EMG',
        soNumber: 'SO-EMG-03',
        customerName: 'Emergency ICU Ward',
        customerType: CustomerType.hospitalWard,
        destinationWardOrAddress: 'ICU Ward 1',
        orderDate: now,
        priority: OrderPriority.emergencyCrashCart,
        status: OutboundStatus.allocated,
        archetypeId: 'healthcare_pharma',
        items: [
          const SalesOrderItem(
            id: 'ITM-3',
            productId: 'p3',
            productName: 'Emergency Epinephrine',
            sku: 'HC-EPI-01',
            requestedQty: 2.0,
            unitPrice: 40.0,
            uom: 'vial',
          ),
        ],
      );

      final wave = waveEngine.generateOptimizedWave(
        orders: [standardOrder, fefoOrder, emergencyOrder],
      );

      expect(wave.tasks.length, equals(3));
      // Task 1 must be from the emergency crash cart order
      expect(wave.tasks[0].orderId, equals('SO-EMG'));
      // Task 2 must be the near-expiry FEFO milk
      expect(wave.tasks[1].orderId, equals('SO-FEFO'));
      // Task 3 is standard later-expiry cheese
      expect(wave.tasks[2].orderId, equals('SO-STD'));
    });

    test('OutboundRepositoryImpl handles pick confirmation and packing barcode scanning', () async {
      final repo = OutboundRepositoryImpl();

      final ordersRes = await repo.getSalesOrders();
      expect(ordersRes.isSuccess, isTrue);

      // Start packing for pre-seeded tech order
      final sessionRes = await repo.startPackingSession('SO-TECH-004');
      expect(sessionRes.isSuccess, isTrue);
      final sessionId = sessionRes.dataOrNull!.id;

      // Scan matching item barcode
      final scanRes = await repo.verifyScanItem(
        sessionId: sessionId,
        scannedBarcode: 'TECH-APEX16P-256-BLK',
      );
      expect(scanRes.isSuccess, isTrue);
      expect(scanRes.dataOrNull!.scannedItems.length, equals(1));

      // Scan invalid barcode fails with validation failure
      final badScan = await repo.verifyScanItem(
        sessionId: sessionId,
        scannedBarcode: 'UNKNOWN-INVALID-BARCODE',
      );
      expect(badScan.isFailure, isTrue);

      // Complete packing & ship
      final shipRes = await repo.completePackingAndShip(
        sessionId: sessionId,
        totalWeightKg: 2.5,
        carrier: 'FedEx Express',
        boxCount: 1,
      );
      expect(shipRes.isSuccess, isTrue);
      expect(shipRes.dataOrNull!.status, equals(PackingStatus.dispatched));
      expect(shipRes.dataOrNull!.trackingNumber, isNotNull);
    });
  });
}
