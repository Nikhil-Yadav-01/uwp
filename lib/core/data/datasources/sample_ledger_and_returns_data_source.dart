import '../../../features/returns/domain/models/return_request.dart';
import '../../inventory/domain/models/inventory_transaction.dart';
import '../../inventory/domain/models/stock_adjustment.dart';
import '../../inventory/domain/models/stock_transfer.dart';

/// Clean data source providing stock movement history, transfers, adjustments, and returns.
/// Uses clear, everyday words.
class SampleLedgerAndReturnsDataSource {
  const SampleLedgerAndReturnsDataSource._();

  // ===========================================================================
  // STOCK LEDGER TRANSACTIONS
  // ===========================================================================
  static List<InventoryTransaction> getTransactions() {
    final now = DateTime.now();

    return [
      InventoryTransaction(
        transactionId: 'TX-1001',
        productId: 'prod_lth_001',
        productName: 'Italian Brown Full-Grain Cowhide Roll',
        sku: 'LTH-FG-BRN-50',
        warehouseId: 'WH01',
        warehouseName: 'Main Central Warehouse',
        locationId: 'A01-01-01',
        transactionType: InventoryTransactionType.purchaseReceipt,
        quantity: 100.0,
        uom: 'sq ft',
        balanceAfter: 100.0,
        referenceType: 'PO',
        referenceId: 'PO-2026-LEATH-12',
        notes: 'Received initial shipment from Italian tannery in good condition.',
        createdBy: 'Receiving Dock Lead (P. Mehta)',
        createdAt: now.subtract(const Duration(days: 3, hours: 4)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1002',
        productId: 'prod_lth_001',
        productName: 'Italian Brown Full-Grain Cowhide Roll',
        sku: 'LTH-FG-BRN-50',
        warehouseId: 'WH01',
        warehouseName: 'Main Central Warehouse',
        locationId: 'A01-01-01',
        transactionType: InventoryTransactionType.putaway,
        quantity: 100.0,
        uom: 'sq ft',
        balanceAfter: 100.0,
        referenceType: 'PUTAWAY',
        referenceId: 'PT-2026-042',
        notes: 'Placed leather rolls securely on Shelf A1.',
        createdBy: 'Warehouse Stager (R. Kumar)',
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1003',
        productId: 'prod_lth_001',
        productName: 'Italian Brown Full-Grain Cowhide Roll',
        sku: 'LTH-FG-BRN-50',
        warehouseId: 'WH01',
        warehouseName: 'Main Central Warehouse',
        locationId: 'A01-01-01',
        transactionType: InventoryTransactionType.pick,
        quantity: 20.0,
        uom: 'sq ft',
        balanceAfter: 80.0,
        referenceType: 'SO',
        referenceId: 'SO-2026-104',
        notes: 'Picked 20 sq ft for customer boutique order.',
        createdBy: 'Picker (S. Patil)',
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1004',
        productId: 'prod_lth_001',
        productName: 'Italian Brown Full-Grain Cowhide Roll',
        sku: 'LTH-FG-BRN-50',
        warehouseId: 'WH01',
        warehouseName: 'Main Central Warehouse',
        locationId: 'A01-01-01',
        transactionType: InventoryTransactionType.damage,
        quantity: 2.0,
        uom: 'sq ft',
        balanceAfter: 78.0,
        referenceType: 'QC',
        referenceId: 'ADJ-2026-001',
        notes: 'Quality check: 2 sq ft scratched and removed from shelf.',
        createdBy: 'Quality Inspector (A. Sen)',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1005',
        productId: 'prod_gro_001',
        productName: 'Fresh Organic Hass Avocados (Pack of 12)',
        sku: 'GRO-AVO-ORG-12',
        warehouseId: 'WH01',
        warehouseName: 'Main Central Warehouse',
        locationId: 'B01-01-01',
        transactionType: InventoryTransactionType.purchaseReceipt,
        quantity: 180.0,
        uom: 'carton',
        balanceAfter: 180.0,
        referenceType: 'PO',
        referenceId: 'PO-2026-GROC-109',
        notes: 'Cold truck delivery checked at +3.8°C. Moved to walk-in cold room.',
        createdBy: 'Cold Storage Lead',
        createdAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1006',
        productId: 'prod_ele_001',
        productName: 'Pro Flagship Smartphone 256GB (Midnight Black)',
        sku: 'ELE-PHN-PRO-256',
        warehouseId: 'WH01',
        warehouseName: 'Main Central Warehouse',
        locationId: 'A01-01-03',
        transactionType: InventoryTransactionType.purchaseReceipt,
        quantity: 34.0,
        uom: 'units',
        balanceAfter: 34.0,
        referenceType: 'PO',
        referenceId: 'PO-2026-TECH-44',
        notes: 'Phones scanned and verified against delivery packing slip.',
        createdBy: 'Tech Room Supervisor',
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
    ];
  }

  // ===========================================================================
  // INTER-WAREHOUSE TRANSFERS
  // ===========================================================================
  static List<StockTransfer> getTransfers() {
    final now = DateTime.now();

    return [
      StockTransfer(
        transferId: 'TR-1001',
        transferNumber: 'TR-2026-001',
        originWarehouseId: 'WH01',
        originWarehouseName: 'Main Central Warehouse',
        destinationWarehouseId: 'WH02',
        destinationWarehouseName: 'Harbor Transit Warehouse',
        items: const [
          StockTransferItem(
            productId: 'prod_lth_001',
            productName: 'Italian Brown Full-Grain Cowhide Roll',
            sku: 'LTH-FG-BRN-50',
            quantity: 15.0,
            uom: 'sq ft',
            originBin: 'A01-01-01',
            destinationBin: 'M01-01-01',
          ),
        ],
        status: TransferStatus.inTransit,
        carrier: 'BlueDart Air Logistics',
        trackingNumber: 'BD-982138472IN',
        notes: 'Moving 15 sq ft leather to Harbor Warehouse for weekend export.',
        requestedBy: 'Store Manager (A. Verma)',
        approvedBy: 'Central Operations Head',
        createdAt: now.subtract(const Duration(hours: 8)),
        dispatchedAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  // ===========================================================================
  // STOCK ADJUSTMENTS
  // ===========================================================================
  static List<StockAdjustment> getAdjustments() {
    final now = DateTime.now();

    return [
      StockAdjustment(
        adjustmentId: 'ADJ-1001',
        adjustmentNumber: 'ADJ-2026-001',
        warehouseId: 'WH01',
        warehouseName: 'Main Central Warehouse',
        locationId: 'A01-01-01',
        productId: 'prod_lth_001',
        productName: 'Italian Brown Full-Grain Cowhide Roll',
        sku: 'LTH-FG-BRN-50',
        systemQuantity: 80.0,
        physicalQuantity: 78.0,
        varianceQuantity: -2.0,
        uom: 'sq ft',
        reason: AdjustmentReason.damaged,
        notes: 'Physical count check: 2 sq ft damaged on edge and removed.',
        createdBy: 'Quality Inspector (A. Sen)',
        approvedBy: 'Warehouse Manager',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
    ];
  }

  // ===========================================================================
  // RETURNS (RMA)
  // ===========================================================================
  static List<ReturnRequest> getReturns() {
    final now = DateTime.now();

    return [
      ReturnRequest(
        id: 'RTN-0012',
        returnNumber: 'RTN-0012',
        salesOrderNumber: 'SO-0456',
        customerName: 'Downtown Tech & Mobile Store',
        sku: 'ELE-PHN-PRO-256',
        productName: 'Pro Flagship Smartphone 256GB (Midnight Black)',
        quantity: 1,
        reason: ReturnReason.damagedInTransit,
        status: ReturnStatus.pending,
        trackingNumber: 'RET-FEDEX-9912',
        notes: 'Outer box squashed during courier transit. Phone unopened.',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      ReturnRequest(
        id: 'RTN-0011',
        returnNumber: 'RTN-0011',
        salesOrderNumber: 'SO-0455',
        customerName: 'Amazon Central Warehouse Depot',
        sku: 'ELE-LAP-16-1TB',
        productName: '16-inch Workstation Laptop (32GB RAM / 1TB SSD)',
        quantity: 1,
        reason: ReturnReason.wrongItemShipped,
        status: ReturnStatus.approved,
        trackingNumber: 'RET-BLUEDART-8821',
        notes: 'Customer ordered 32GB RAM model, 16GB model sent by error.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      ReturnRequest(
        id: 'RTN-0010',
        returnNumber: 'RTN-0010',
        salesOrderNumber: 'SO-0454',
        customerName: 'Fresh Market Supermarket',
        sku: 'GRO-AVO-ORG-12',
        productName: 'Fresh Organic Hass Avocados (Pack of 12)',
        quantity: 2,
        reason: ReturnReason.customerReturn,
        status: ReturnStatus.received,
        assignedBinLocation: 'A01-01-02',
        trackingNumber: 'RET-LOCAL-7714',
        notes: 'Store over-ordered avocados. Unopened fresh cartons returned to cold room.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ReturnRequest(
        id: 'RTN-0009',
        returnNumber: 'RTN-0009',
        salesOrderNumber: 'SO-0450',
        customerName: 'Fashion Street Clothing Boutique',
        sku: 'FSH-HD-BLK',
        productName: 'Heavyweight Cotton Hoodie',
        quantity: 3,
        reason: ReturnReason.undeliveredRto,
        status: ReturnStatus.restocked,
        assignedBinLocation: 'A01-01-01',
        notes: 'Delivery address incomplete. Returned packages inspected and placed back on rack.',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
