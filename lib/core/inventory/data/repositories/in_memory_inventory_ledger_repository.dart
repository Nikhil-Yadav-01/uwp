import 'dart:math';
import '../../domain/models/inventory_transaction.dart';
import '../../domain/models/stock_transfer.dart';
import '../../domain/models/stock_adjustment.dart';

/// Repository managing immutable stock ledger transactions, transfers, and adjustments.
class InMemoryInventoryLedgerRepository {
  static final InMemoryInventoryLedgerRepository _instance = InMemoryInventoryLedgerRepository._internal();
  factory InMemoryInventoryLedgerRepository() => _instance;
  InMemoryInventoryLedgerRepository._internal() {
    _seedInitialLedger();
  }

  final List<InventoryTransaction> _transactions = [];
  final List<StockTransfer> _transfers = [];
  final List<StockAdjustment> _adjustments = [];

  void _seedInitialLedger() {
    final now = DateTime.now();

    _transactions.addAll([
      InventoryTransaction(
        transactionId: 'TX-1001',
        productId: 'PROD-LTH-001',
        productName: 'Full Grain Italian Cowhide (Cognac Tan)',
        sku: 'LTH-FG-TAN-50',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-01',
        transactionType: InventoryTransactionType.purchaseReceipt,
        quantity: 100.0,
        uom: 'sq ft',
        balanceAfter: 100.0,
        referenceType: 'PO',
        referenceId: 'PO-2026-081',
        notes: 'Initial bulk container shipment received in good condition',
        createdBy: 'Purchase Manager (P. Mehta)',
        createdAt: now.subtract(const Duration(days: 3, hours: 4)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1002',
        productId: 'PROD-LTH-001',
        productName: 'Full Grain Italian Cowhide (Cognac Tan)',
        sku: 'LTH-FG-TAN-50',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-01',
        transactionType: InventoryTransactionType.putaway,
        quantity: 100.0,
        uom: 'sq ft',
        balanceAfter: 100.0,
        referenceType: 'PUTAWAY',
        referenceId: 'PT-2026-042',
        notes: 'Allocated to heavy roll storage Aisle 01',
        createdBy: 'Warehouse Stager (R. Kumar)',
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1003',
        productId: 'PROD-LTH-001',
        productName: 'Full Grain Italian Cowhide (Cognac Tan)',
        sku: 'LTH-FG-TAN-50',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-01',
        transactionType: InventoryTransactionType.pick,
        quantity: 20.0,
        uom: 'sq ft',
        balanceAfter: 80.0,
        referenceType: 'SO',
        referenceId: 'SO-2026-104',
        notes: 'Picked for Milan Flagship order wave #1',
        createdBy: 'Picker (S. Patil)',
        createdAt: now.subtract(const Duration(days: 2, hours: 5)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1004',
        productId: 'PROD-LTH-001',
        productName: 'Full Grain Italian Cowhide (Cognac Tan)',
        sku: 'LTH-FG-TAN-50',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-01',
        transactionType: InventoryTransactionType.damage,
        quantity: 2.0,
        uom: 'sq ft',
        balanceAfter: 78.0,
        referenceType: 'QC',
        referenceId: 'ADJ-2026-001',
        notes: 'Edge grain surface abrasion found during moisture check',
        createdBy: 'QC Auditor (A. Sen)',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1005',
        productId: 'PROD-GRO-001',
        productName: 'Organic Alphonso Mangoes (Grade A Export)',
        sku: 'GRO-MNG-ALPH-01',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-B01-01',
        transactionType: InventoryTransactionType.purchaseReceipt,
        quantity: 250.0,
        uom: 'crates',
        balanceAfter: 250.0,
        referenceType: 'PO',
        referenceId: 'PO-2026-089',
        notes: 'Chilled reefer truck intake with temperature log verified (+3.8°C)',
        createdBy: 'Receiving Dock Lead',
        createdAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      InventoryTransaction(
        transactionId: 'TX-1006',
        productId: 'PROD-ELE-001',
        productName: 'FPGA Neural Accelerator Core Module v2',
        sku: 'ELE-FPGA-N2-01',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-03',
        transactionType: InventoryTransactionType.purchaseReceipt,
        quantity: 50.0,
        uom: 'units',
        balanceAfter: 50.0,
        referenceType: 'PO',
        referenceId: 'PO-2026-092',
        notes: 'Anti-static sealed trays verified by barcode serial scan',
        createdBy: 'Hardware Lead',
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
    ]);

    _transfers.add(
      StockTransfer(
        transferId: 'TR-1001',
        transferNumber: 'TR-2026-001',
        originWarehouseId: 'WH01',
        originWarehouseName: 'Central Distribution Hub #01',
        destinationWarehouseId: 'WH02',
        destinationWarehouseName: 'North Retail Fulfillment Depot #02',
        items: const [
          StockTransferItem(
            productId: 'PROD-LTH-001',
            productName: 'Full Grain Italian Cowhide (Cognac Tan)',
            sku: 'LTH-FG-TAN-50',
            quantity: 15.0,
            uom: 'sq ft',
            originBin: 'BIN-A01-01',
            destinationBin: 'BIN-NORTH-A01',
          ),
        ],
        status: TransferStatus.inTransit,
        carrier: 'BlueDart Air Logistics',
        trackingNumber: 'BD-982138472IN',
        notes: 'Urgent stock replenishment for weekend retail demand',
        requestedBy: 'Store Manager (A. Verma)',
        approvedBy: 'Central Operations Head',
        createdAt: now.subtract(const Duration(hours: 8)),
        dispatchedAt: now.subtract(const Duration(hours: 4)),
      ),
    );

    _adjustments.add(
      StockAdjustment(
        adjustmentId: 'ADJ-1001',
        adjustmentNumber: 'ADJ-2026-001',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-01',
        productId: 'PROD-LTH-001',
        productName: 'Full Grain Italian Cowhide (Cognac Tan)',
        sku: 'LTH-FG-TAN-50',
        systemQuantity: 80.0,
        physicalQuantity: 78.0,
        varianceQuantity: -2.0,
        uom: 'sq ft',
        reason: AdjustmentReason.damaged,
        notes: 'Surface abrasion scrapping approved by QC',
        createdBy: 'QC Auditor (A. Sen)',
        approvedBy: 'Plant Manager',
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
      ),
    );
  }

  // Transaction Queries & Recording
  List<InventoryTransaction> getTransactions({String? warehouseId, InventoryTransactionType? type, String? searchQuery}) {
    return _transactions.where((tx) {
      if (warehouseId != null && warehouseId.isNotEmpty && tx.warehouseId != warehouseId) {
        return false;
      }
      if (type != null && tx.transactionType != type) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return tx.productName.toLowerCase().contains(query) ||
            tx.sku.toLowerCase().contains(query) ||
            tx.referenceId.toLowerCase().contains(query) ||
            tx.locationId.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  void recordTransaction(InventoryTransaction transaction) {
    _transactions.insert(0, transaction);
  }

  // Stock Transfers
  List<StockTransfer> getTransfers() => List.unmodifiable(_transfers);

  void createTransfer(StockTransfer transfer) {
    _transfers.insert(0, transfer);

    for (final item in transfer.items) {
      recordTransaction(
        InventoryTransaction(
          transactionId: 'TX-${Random().nextInt(90000) + 10000}',
          productId: item.productId,
          productName: item.productName,
          sku: item.sku,
          warehouseId: transfer.originWarehouseId,
          warehouseName: transfer.originWarehouseName,
          locationId: item.originBin,
          transactionType: InventoryTransactionType.transferOut,
          quantity: item.quantity,
          uom: item.uom,
          balanceAfter: max(0, 100.0 - item.quantity),
          referenceType: 'TRANSFER',
          referenceId: transfer.transferNumber,
          notes: 'Transfer dispatched to ${transfer.destinationWarehouseName}',
          createdBy: transfer.requestedBy,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  void updateTransferStatus(String transferId, TransferStatus newStatus) {
    final index = _transfers.indexWhere((t) => t.transferId == transferId);
    if (index != -1) {
      final transfer = _transfers[index];
      _transfers[index] = transfer.copyWith(
        status: newStatus,
        receivedAt: newStatus == TransferStatus.completed ? DateTime.now() : transfer.receivedAt,
      );

      if (newStatus == TransferStatus.completed) {
        for (final item in transfer.items) {
          recordTransaction(
            InventoryTransaction(
              transactionId: 'TX-${Random().nextInt(90000) + 10000}',
              productId: item.productId,
              productName: item.productName,
              sku: item.sku,
              warehouseId: transfer.destinationWarehouseId,
              warehouseName: transfer.destinationWarehouseName,
              locationId: item.destinationBin ?? 'BIN-STAGING',
              transactionType: InventoryTransactionType.transferIn,
              quantity: item.quantity,
              uom: item.uom,
              balanceAfter: item.quantity,
              referenceType: 'TRANSFER',
              referenceId: transfer.transferNumber,
              notes: 'Transfer received from ${transfer.originWarehouseName}',
              createdBy: 'Receiving Dock Lead',
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }
  }

  // Stock Adjustments
  List<StockAdjustment> getAdjustments() => List.unmodifiable(_adjustments);

  void recordAdjustment(StockAdjustment adjustment) {
    _adjustments.insert(0, adjustment);

    final isPositive = adjustment.varianceQuantity >= 0;
    recordTransaction(
      InventoryTransaction(
        transactionId: 'TX-${Random().nextInt(90000) + 10000}',
        productId: adjustment.productId,
        productName: adjustment.productName,
        sku: adjustment.sku,
        warehouseId: adjustment.warehouseId,
        warehouseName: adjustment.warehouseName,
        locationId: adjustment.locationId,
        transactionType: isPositive ? InventoryTransactionType.adjustmentIn : (adjustment.reason == AdjustmentReason.damaged ? InventoryTransactionType.damage : InventoryTransactionType.adjustmentOut),
        quantity: adjustment.varianceQuantity.abs(),
        uom: adjustment.uom,
        balanceAfter: adjustment.physicalQuantity,
        referenceType: 'ADJUSTMENT',
        referenceId: adjustment.adjustmentNumber,
        notes: 'Reason: ${adjustment.reason.displayName}. ${adjustment.notes ?? ""}',
        createdBy: adjustment.createdBy,
        createdAt: adjustment.createdAt,
      ),
    );
  }
}
