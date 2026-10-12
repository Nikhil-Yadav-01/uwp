import 'dart:math';
import '../../../data/datasources/sample_data_source.dart';
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
    _transactions.addAll(SampleDataSource.getTransactions());
    _transfers.addAll(SampleDataSource.getTransfers());
    _adjustments.addAll(SampleDataSource.getAdjustments());
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
