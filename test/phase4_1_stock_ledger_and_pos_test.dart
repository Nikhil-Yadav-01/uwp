import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/core/inventory/data/repositories/in_memory_inventory_ledger_repository.dart';
import 'package:warehouse/core/inventory/domain/models/inventory_transaction.dart';
import 'package:warehouse/core/inventory/domain/models/stock_transfer.dart';
import 'package:warehouse/core/inventory/domain/models/stock_adjustment.dart';
import 'package:warehouse/core/master_data/data/repositories/in_memory_master_data_repository.dart';
import 'package:warehouse/features/pos_billing/presentation/controllers/pos_cart_controller.dart';
import 'package:warehouse/features/rbac/presentation/controllers/user_role_controller.dart';

void main() {
  group('Phase 4.1: Stock Ledger & Inventory Transactions Tests', () {
    late InMemoryInventoryLedgerRepository ledgerRepo;

    setUp(() {
      ledgerRepo = InMemoryInventoryLedgerRepository();
    });

    test('Ledger correctly records purchase receipts and sales transactions', () {
      final initialCount = ledgerRepo.getTransactions().length;

      final newTx = InventoryTransaction(
        transactionId: 'TX-TEST-001',
        productId: 'PROD-TEST',
        productName: 'Test Raw Material Roll',
        sku: 'TEST-SKU-01',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-01',
        transactionType: InventoryTransactionType.purchaseReceipt,
        quantity: 50.0,
        uom: 'units',
        balanceAfter: 150.0,
        referenceType: 'PO',
        referenceId: 'PO-TEST-100',
        createdBy: 'Test User',
        createdAt: DateTime.now(),
      );

      ledgerRepo.recordTransaction(newTx);

      final updated = ledgerRepo.getTransactions();
      expect(updated.length, initialCount + 1);
      expect(updated.first.transactionId, 'TX-TEST-001');
      expect(updated.first.transactionType.isAddition, isTrue);
    });

    test('Inter-Warehouse Stock Transfer transitions through In-Transit to Completed', () {
      final transfer = StockTransfer(
        transferId: 'TR-TEST-999',
        transferNumber: 'TR-2026-999',
        originWarehouseId: 'WH01',
        originWarehouseName: 'Central Distribution Hub #01',
        destinationWarehouseId: 'WH02',
        destinationWarehouseName: 'North Retail Depot #02',
        items: const [
          StockTransferItem(
            productId: 'PROD-01',
            productName: 'Italian Leather Roll',
            sku: 'LTH-01',
            quantity: 10.0,
            uom: 'sq ft',
            originBin: 'BIN-A01-01',
            destinationBin: 'BIN-NORTH-01',
          ),
        ],
        status: TransferStatus.inTransit,
        requestedBy: 'Store Lead',
        createdAt: DateTime.now(),
      );

      ledgerRepo.createTransfer(transfer);

      final transfers = ledgerRepo.getTransfers();
      expect(transfers.any((t) => t.transferId == 'TR-TEST-999'), isTrue);

      ledgerRepo.updateTransferStatus('TR-TEST-999', TransferStatus.completed);

      final completedTransfer = ledgerRepo.getTransfers().firstWhere((t) => t.transferId == 'TR-TEST-999');
      expect(completedTransfer.status, TransferStatus.completed);
      expect(completedTransfer.receivedAt, isNotNull);
    });

    test('Stock Adjustment logs damaged loss with negative variance', () {
      final adjustment = StockAdjustment(
        adjustmentId: 'ADJ-TEST-100',
        adjustmentNumber: 'ADJ-2026-TEST',
        warehouseId: 'WH01',
        warehouseName: 'Central Distribution Hub #01',
        locationId: 'BIN-A01-01',
        productId: 'PROD-01',
        productName: 'Italian Leather Roll',
        sku: 'LTH-01',
        systemQuantity: 100.0,
        physicalQuantity: 95.0,
        varianceQuantity: -5.0,
        uom: 'sq ft',
        reason: AdjustmentReason.damaged,
        createdBy: 'Auditor',
        createdAt: DateTime(2026, 9, 27),
      );

      ledgerRepo.recordAdjustment(adjustment);

      final adjustments = ledgerRepo.getAdjustments();
      expect(adjustments.any((a) => a.adjustmentId == 'ADJ-TEST-100'), isTrue);
      expect(adjustments.first.varianceQuantity, -5.0);
    });
  });

  group('Phase 4.1: Master Data & RBAC Tests', () {
    test('Master Data Repository returns seeded Warehouses, Suppliers, and Customers', () {
      final repo = InMemoryMasterDataRepository();
      final warehouses = repo.getWarehouses();
      final suppliers = repo.getSuppliers();
      final customers = repo.getCustomers();

      expect(warehouses.isNotEmpty, isTrue);
      expect(warehouses.first.zones.isNotEmpty, isTrue);
      expect(suppliers.isNotEmpty, isTrue);
      expect(customers.isNotEmpty, isTrue);
    });

    test('RBAC UserRole permissions correctly guard sensitive actions', () {
      const superAdmin = UserRole.superAdmin;
      const picker = UserRole.picker;
      const auditor = UserRole.auditor;

      expect(superAdmin.canEditCatalog(), isTrue);
      expect(superAdmin.canApproveTransfers(), isTrue);
      expect(superAdmin.canPerformStockAdjustments(), isTrue);

      expect(picker.canEditCatalog(), isFalse);
      expect(picker.canApproveTransfers(), isFalse);
      expect(picker.canPerformStockAdjustments(), isFalse);

      expect(auditor.canEditCatalog(), isFalse);
      expect(auditor.canPerformStockAdjustments(), isTrue);
    });
  });

  group('Phase 4.1: POS Cart Calculations', () {
    test('PosCartItem calculates lineTotal with discounts correctly', () {
      const item = PosCartItem(
        productId: 'P-1',
        productName: 'Item A',
        sku: 'SKU-A',
        unitPrice: 100.0,
        quantity: 2,
        discountPercent: 10.0, // 10% discount
        uom: 'unit',
      );

      expect(item.lineTotal, 180.0);
    });

    test('PosCartState computes subtotal, GST tax, and grand total', () {
      const state = PosCartState(
        items: [
          PosCartItem(
            productId: 'P-1',
            productName: 'Item A',
            sku: 'SKU-A',
            unitPrice: 100.0,
            quantity: 2,
            uom: 'unit',
          ),
          PosCartItem(
            productId: 'P-2',
            productName: 'Item B',
            sku: 'SKU-B',
            unitPrice: 50.0,
            quantity: 1,
            uom: 'unit',
          ),
        ],
        taxRate: 0.05, // 5% GST
      );

      expect(state.subtotal, 250.0);
      expect(state.taxAmount, 12.50);
      expect(state.grandTotal, 262.50);
      expect(state.totalItemCount, 3);
    });
  });
}
