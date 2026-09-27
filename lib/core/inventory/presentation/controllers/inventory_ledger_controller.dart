import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/in_memory_inventory_ledger_repository.dart';
import '../../domain/models/inventory_transaction.dart';
import '../../domain/models/stock_transfer.dart';
import '../../domain/models/stock_adjustment.dart';

class LedgerState {
  final List<InventoryTransaction> transactions;
  final List<StockTransfer> transfers;
  final List<StockAdjustment> adjustments;
  final String selectedWarehouseId;
  final InventoryTransactionType? selectedType;
  final String searchQuery;

  const LedgerState({
    required this.transactions,
    required this.transfers,
    required this.adjustments,
    this.selectedWarehouseId = '',
    this.selectedType,
    this.searchQuery = '',
  });

  LedgerState copyWith({
    List<InventoryTransaction>? transactions,
    List<StockTransfer>? transfers,
    List<StockAdjustment>? adjustments,
    String? selectedWarehouseId,
    InventoryTransactionType? selectedType,
    bool clearTypeFilter = false,
    String? searchQuery,
  }) {
    return LedgerState(
      transactions: transactions ?? this.transactions,
      transfers: transfers ?? this.transfers,
      adjustments: adjustments ?? this.adjustments,
      selectedWarehouseId: selectedWarehouseId ?? this.selectedWarehouseId,
      selectedType: clearTypeFilter ? null : (selectedType ?? this.selectedType),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class InventoryLedgerNotifier extends StateNotifier<LedgerState> {
  final InMemoryInventoryLedgerRepository _repository;

  InventoryLedgerNotifier(this._repository)
      : super(
          LedgerState(
            transactions: _repository.getTransactions(),
            transfers: _repository.getTransfers(),
            adjustments: _repository.getAdjustments(),
          ),
        );

  void refresh() {
    state = state.copyWith(
      transactions: _repository.getTransactions(
        warehouseId: state.selectedWarehouseId,
        type: state.selectedType,
        searchQuery: state.searchQuery,
      ),
      transfers: _repository.getTransfers(),
      adjustments: _repository.getAdjustments(),
    );
  }

  void filterWarehouse(String warehouseId) {
    state = state.copyWith(selectedWarehouseId: warehouseId);
    refresh();
  }

  void filterType(InventoryTransactionType? type) {
    if (type == null) {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
    refresh();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    refresh();
  }

  void createTransfer(StockTransfer transfer) {
    _repository.createTransfer(transfer);
    refresh();
  }

  void updateTransferStatus(String transferId, TransferStatus status) {
    _repository.updateTransferStatus(transferId, status);
    refresh();
  }

  void recordAdjustment(StockAdjustment adjustment) {
    _repository.recordAdjustment(adjustment);
    refresh();
  }
}

final inventoryLedgerRepositoryProvider = Provider<InMemoryInventoryLedgerRepository>((ref) {
  return InMemoryInventoryLedgerRepository();
});

final inventoryLedgerProvider = StateNotifierProvider<InventoryLedgerNotifier, LedgerState>((ref) {
  final repo = ref.watch(inventoryLedgerRepositoryProvider);
  return InventoryLedgerNotifier(repo);
});
