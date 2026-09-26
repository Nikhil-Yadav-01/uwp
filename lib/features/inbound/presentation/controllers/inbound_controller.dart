import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/inbound_repository_impl.dart';
import '../../domain/models/purchase_order.dart';
import '../../domain/models/qc_inspection.dart';
import '../../domain/models/putaway_task.dart';
import '../../domain/repositories/i_inbound_repository.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

@immutable
class InboundState {
  final List<PurchaseOrder> purchaseOrders;
  final List<QcInspectionReport> qcReports;
  final List<PutawayTask> putawayTasks;
  final InboundStatus? statusFilter;
  final bool isLoading;
  final String? errorMessage;
  final PurchaseOrder? selectedOrder;

  const InboundState({
    this.purchaseOrders = const [],
    this.qcReports = const [],
    this.putawayTasks = const [],
    this.statusFilter,
    this.isLoading = false,
    this.errorMessage,
    this.selectedOrder,
  });

  InboundState copyWith({
    List<PurchaseOrder>? purchaseOrders,
    List<QcInspectionReport>? qcReports,
    List<PutawayTask>? putawayTasks,
    InboundStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? isLoading,
    String? errorMessage,
    PurchaseOrder? selectedOrder,
    bool clearSelectedOrder = false,
  }) {
    return InboundState(
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      qcReports: qcReports ?? this.qcReports,
      putawayTasks: putawayTasks ?? this.putawayTasks,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
    );
  }
}

class InboundNotifier extends StateNotifier<InboundState> {
  final IInboundRepository _repository;
  final String _archetypeId;

  InboundNotifier(this._repository, this._archetypeId) : super(const InboundState()) {
    loadInboundData();
  }

  Future<void> loadInboundData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final poResult = await _repository.getPurchaseOrders(
      status: state.statusFilter,
      archetypeId: _archetypeId,
    );
    final qcResult = await _repository.getQcReports();
    final putawayResult = await _repository.getPutawayTasks();

    poResult.fold(
      onSuccess: (pos) {
        state = state.copyWith(
          purchaseOrders: pos,
          qcReports: qcResult.fold(onSuccess: (r) => r, onFailure: (_) => []),
          putawayTasks: putawayResult.fold(onSuccess: (t) => t, onFailure: (_) => []),
          isLoading: false,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  void setFilter(InboundStatus? filter) {
    if (filter == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: filter);
    }
    loadInboundData();
  }

  void selectOrder(PurchaseOrder? order) {
    if (order == null) {
      state = state.copyWith(clearSelectedOrder: true);
    } else {
      state = state.copyWith(selectedOrder: order);
    }
  }

  Future<bool> createPurchaseOrder(PurchaseOrder order) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createPurchaseOrder(order);
    return result.fold(
      onSuccess: (_) {
        loadInboundData();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> receiveDockGoods({
    required String poId,
    required List<PurchaseOrderItem> receivedItems,
    String? dockId,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.receiveGoods(
      poId: poId,
      receivedItems: receivedItems,
      receivingDockId: dockId,
    );
    return result.fold(
      onSuccess: (_) {
        loadInboundData();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> submitQcInspection(QcInspectionReport report) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.submitQcInspection(report);
    return result.fold(
      onSuccess: (_) {
        loadInboundData();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> confirmPutawayTask({
    required String taskId,
    required String confirmedLocation,
    String? operatorName,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.confirmPutaway(
      taskId: taskId,
      confirmedLocation: confirmedLocation,
      operatorName: operatorName,
    );
    return result.fold(
      onSuccess: (_) {
        loadInboundData();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }
}

final inboundNotifierProvider =
    StateNotifierProvider<InboundNotifier, InboundState>((ref) {
  final repo = ref.watch(inboundRepositoryProvider);
  final archetype = ref.watch(archetypeProvider).archetype;
  return InboundNotifier(repo, archetype.id);
});
