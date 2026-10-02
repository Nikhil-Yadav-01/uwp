import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/returns_repository.dart';
import '../../domain/models/return_request.dart';

class ReturnsState {
  final List<ReturnRequest> returns;
  final String searchQuery;
  final ReturnStatus? selectedStatus;
  final ReturnReason? selectedReason;
  final bool isLoading;

  const ReturnsState({
    required this.returns,
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedReason,
    this.isLoading = false,
  });

  List<ReturnRequest> get filteredReturns {
    return returns.where((r) {
      if (selectedStatus != null && r.status != selectedStatus) return false;
      if (selectedReason != null && r.reason != selectedReason) return false;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchRtn = r.returnNumber.toLowerCase().contains(query);
        final matchSo = r.salesOrderNumber.toLowerCase().contains(query);
        final matchCust = r.customerName.toLowerCase().contains(query);
        final matchSku = r.sku.toLowerCase().contains(query);
        final matchProduct = r.productName.toLowerCase().contains(query);
        return matchRtn || matchSo || matchCust || matchSku || matchProduct;
      }
      return true;
    }).toList();
  }

  ReturnsState copyWith({
    List<ReturnRequest>? returns,
    String? searchQuery,
    ReturnStatus? selectedStatus,
    ReturnReason? selectedReason,
    bool clearStatus = false,
    bool clearReason = false,
    bool isLoading = false,
  }) {
    return ReturnsState(
      returns: returns ?? this.returns,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedReason: clearReason ? null : (selectedReason ?? this.selectedReason),
      isLoading: isLoading,
    );
  }
}

class ReturnsNotifier extends StateNotifier<ReturnsState> {
  final IReturnsRepository _repository;

  ReturnsNotifier(this._repository)
      : super(ReturnsState(returns: _repository.getAll()));

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void filterByStatus(ReturnStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  void filterByReason(ReturnReason? reason) {
    if (reason == null) {
      state = state.copyWith(clearReason: true);
    } else {
      state = state.copyWith(selectedReason: reason);
    }
  }

  void createReturn({
    required String salesOrderNumber,
    required String customerName,
    required String sku,
    required String productName,
    required int quantity,
    required ReturnReason reason,
    String? trackingNumber,
    String notes = '',
  }) {
    final nextId = 'RTN-00${(state.returns.length + 10).toString()}';
    final request = ReturnRequest(
      id: nextId,
      returnNumber: nextId,
      salesOrderNumber: salesOrderNumber,
      customerName: customerName,
      sku: sku,
      productName: productName,
      quantity: quantity,
      reason: reason,
      status: ReturnStatus.pending,
      trackingNumber: trackingNumber,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _repository.add(request);
    state = state.copyWith(returns: _repository.getAll());
  }

  void approveReturn(String id) {
    _repository.updateStatus(id, ReturnStatus.approved);
    state = state.copyWith(returns: _repository.getAll());
  }

  void receiveReturn(String id) {
    _repository.updateStatus(id, ReturnStatus.received);
    state = state.copyWith(returns: _repository.getAll());
  }

  void restockReturn(String id, String binLocation) {
    _repository.updateStatus(id, ReturnStatus.restocked, binLocation: binLocation);
    state = state.copyWith(returns: _repository.getAll());
  }

  void scrapReturn(String id) {
    _repository.updateStatus(id, ReturnStatus.scrapped);
    state = state.copyWith(returns: _repository.getAll());
  }
}

final returnsRepositoryProvider = Provider<IReturnsRepository>((ref) {
  return InMemoryReturnsRepository();
});

final returnsNotifierProvider = StateNotifierProvider<ReturnsNotifier, ReturnsState>((ref) {
  final repo = ref.watch(returnsRepositoryProvider);
  return ReturnsNotifier(repo);
});
