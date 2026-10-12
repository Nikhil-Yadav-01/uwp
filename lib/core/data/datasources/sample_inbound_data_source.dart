import '../../../features/inbound/domain/models/purchase_order.dart';
import '../../../features/inbound/domain/models/qc_inspection.dart';

/// Clean data source providing realistic inbound purchase orders and quality inspection reports.
/// Uses friendly, easy-to-read language.
class SampleInboundDataSource {
  const SampleInboundDataSource._();

  static List<PurchaseOrder> getPurchaseOrders() {
    final now = DateTime.now();

    return [
      // 1. Healthcare & Medicine PO (City Pharmaceutical Distributors)
      PurchaseOrder(
        id: 'PO-HC-001',
        poNumber: 'PO-2026-MED-01',
        vendorName: 'City Pharmaceutical Distributors',
        vendorEmail: 'procurement@citypharma.org',
        orderDate: now.subtract(const Duration(days: 2)),
        expectedDeliveryDate: now.add(const Duration(days: 1)),
        status: InboundStatus.qcPending,
        archetypeId: 'healthcare_pharma',
        receivingDockId: 'Dock 3 (Clean Medicine Staging)',
        actualArrivalDate: now.subtract(const Duration(hours: 4)),
        notes: 'Cold storage medicine and prescription pain relief. Kept in locked safe and signed by 2 staff members.',
        items: const [
          PurchaseOrderItem(
            id: 'POI-HC-01',
            productId: 'prod_med_005',
            productName: 'Antibiotic Oral Capsules 500mg (Box of 100)',
            sku: 'MED-RX-AMX-500',
            orderedQty: 100.0,
            receivedQty: 100.0,
            unitPrice: 8.50,
            uom: 'box',
            customAttributes: {
              'batchLot': 'LOT-AMX-2026B',
              'storageTemp': 'Room Temperature (15°C to 25°C)',
            },
          ),
          PurchaseOrderItem(
            id: 'POI-HC-02',
            productId: 'prod_med_001',
            productName: 'Prescription Pain Relief Medicine (10mg / 1ml)',
            sku: 'MED-RX-PAIN-10',
            orderedQty: 50.0,
            receivedQty: 50.0,
            unitPrice: 4.50,
            uom: 'vial',
            customAttributes: {
              'batchLot': 'LOT-PAIN-9981-SEC',
              'storageTemp': 'Locked Medicine Safe',
              'requiresDualSignoff': true,
            },
          ),
        ],
      ),

      // 2. Fresh Grocery PO (Alpine Fresh Dairy & Farms)
      PurchaseOrder(
        id: 'PO-GROC-002',
        poNumber: 'PO-2026-DAIRY-89',
        vendorName: 'Alpine Fresh Dairy & Farms',
        vendorEmail: 'orders@alpinedairy.com',
        orderDate: now.subtract(const Duration(days: 1)),
        expectedDeliveryDate: now,
        status: InboundStatus.atDock,
        archetypeId: 'grocery_foods',
        receivingDockId: 'Dock 1 (Cold Chiller Bay)',
        actualArrivalDate: now.subtract(const Duration(hours: 1)),
        notes: 'Refrigerated truck arrived cold at 3.6°C. Milk bottles inspected with zero leaks.',
        items: const [
          PurchaseOrderItem(
            id: 'POI-GROC-01',
            productId: 'prod_gro_002',
            productName: 'Farm-Fresh Whole Milk (1 Gallon / 3.8L)',
            sku: 'GRO-MLK-GAL-01',
            orderedQty: 240.0,
            receivedQty: 240.0,
            unitPrice: 2.10,
            uom: 'bottle',
            customAttributes: {
              'batchLot': 'LOT-MLK-8812',
              'storageZone': 'Cold Room (+2°C)',
              'measuredDockTemp': '+3.6°C',
            },
          ),
        ],
      ),

      // 3. Tech & Smartphones PO (Apex Electronics Distribution)
      PurchaseOrder(
        id: 'PO-TECH-003',
        poNumber: 'PO-2026-TECH-44',
        vendorName: 'Apex Electronics Distribution',
        vendorEmail: 'b2b@apextech.com',
        orderDate: now.subtract(const Duration(days: 3)),
        status: InboundStatus.putawayReady,
        archetypeId: 'electronics_tech',
        receivingDockId: 'Dock 2 (Electronics Receiving)',
        notes: 'All phone boxes inspected, sealed, and ready to be placed on warehouse shelves.',
        items: const [
          PurchaseOrderItem(
            id: 'POI-TECH-01',
            productId: 'prod_ele_001',
            productName: 'Pro Flagship Smartphone 256GB (Midnight Black)',
            sku: 'ELE-PHN-PRO-256',
            orderedQty: 30.0,
            receivedQty: 30.0,
            unitPrice: 650.00,
            uom: 'units',
            customAttributes: {
              'condition': 'Brand New (Factory Sealed)',
              'serialCount': 30,
            },
          ),
        ],
      ),

      // 4. Italian Leather PO (Florence Leather Tannery Co.)
      PurchaseOrder(
        id: 'PO-LTHR-004',
        poNumber: 'PO-2026-LEATH-12',
        vendorName: 'Florence Leather Tannery Co.',
        vendorEmail: 'orders@florenceleather.it',
        orderDate: now.subtract(const Duration(days: 4)),
        status: InboundStatus.inTransit,
        archetypeId: 'leather_textiles',
        notes: 'Shipped from Italy by air cargo. Scheduled to arrive at Central Warehouse tomorrow.',
        items: const [
          PurchaseOrderItem(
            id: 'POI-LTHR-01',
            productId: 'prod_lth_001',
            productName: 'Italian Brown Full-Grain Cowhide Roll',
            sku: 'LTH-FG-BRN-50',
            orderedQty: 1200.0,
            unitPrice: 42.00,
            uom: 'sq ft',
            customAttributes: {
              'tanneryLot': 'TOSC-2026-B9',
              'grade': 'Grade A (Prime)',
            },
          ),
        ],
      ),

      // 5. Highland Scotch Whisky PO (Highland Craft Beverage & Distillers)
      PurchaseOrder(
        id: 'PO-BAR-005',
        poNumber: 'PO-2026-BAR-55',
        vendorName: 'Highland Craft Beverage & Distillers',
        vendorEmail: 'supply@highlandcraft.co.uk',
        orderDate: now.subtract(const Duration(days: 1)),
        status: InboundStatus.approved,
        archetypeId: 'bars_hospitality',
        notes: 'Monthly replenishment of Scotch bottles for bar operations.',
        items: const [
          PurchaseOrderItem(
            id: 'POI-BAR-01',
            productId: 'prod_bar_001',
            productName: 'Highland Single Malt Scotch Whisky 18-Year (700ml)',
            sku: 'BAR-SCOTCH-18Y',
            orderedQty: 24.0,
            unitPrice: 85.00,
            uom: 'bottle',
            customAttributes: {
              'abv': '43.0%',
              'vintage': '2008 Reserve',
            },
          ),
        ],
      ),
    ];
  }

  static List<QcInspectionReport> getQcReports() {
    final now = DateTime.now();

    return [
      QcInspectionReport(
        id: 'QC-REP-001',
        poId: 'PO-HC-001',
        poNumber: 'PO-2026-MED-01',
        inspectorName: 'Dr. Sarah Jenkins (Pharmacist)',
        witnessName: 'Officer Marcus Vance (Security Supervisor)',
        inspectionDate: now.subtract(const Duration(hours: 2)),
        status: QcStatus.passed,
        requiresDualSignoff: true,
        isDualSigned: true,
        overallNotes: 'Medicine boxes sealed and cold temperature verified. Both staff members confirmed count and locked safe.',
        itemResults: const [
          QcItemResult(
            productId: 'prod_med_005',
            productName: 'Antibiotic Oral Capsules 500mg (Box of 100)',
            sku: 'MED-RX-AMX-500',
            inspectedQty: 100.0,
            passedQty: 100.0,
            testMetrics: {'boxIntegrity': '100% Intact', 'batchSeal': 'Passed'},
          ),
          QcItemResult(
            productId: 'prod_med_001',
            productName: 'Prescription Pain Relief Medicine (10mg / 1ml)',
            sku: 'MED-RX-PAIN-10',
            inspectedQty: 50.0,
            passedQty: 50.0,
            testMetrics: {'vaultLock1': 'Verified', 'vaultLock2': 'Verified', 'vialCount': 'Exact 50'},
          ),
        ],
      ),
    ];
  }
}
