import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/outbound_repository_impl.dart';
import '../../domain/models/sales_order.dart';
import '../../domain/models/picking_wave.dart';
import '../../domain/models/packing_session.dart';
import '../../domain/repositories/i_outbound_repository.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

@immutable
class OutboundState {
  final List<SalesOrder> salesOrders;
  final List<PickingWave> activeWaves;
  final PickingWave? selectedWave;
  final PackingSession? activePackingSession;
  final OutboundStatus? statusFilter;
  final bool isLoading;
  final String? errorMessage;
  final SalesOrder? selectedOrder;

  const OutboundState({
    this.salesOrders = const [],
    this.activeWaves = const [],
    this.selectedWave,
    this.activePackingSession,
    this.statusFilter,
    this.isLoading = false,
    this.errorMessage,
    this.selectedOrder,
  });

  OutboundState copyWith({
    List<SalesOrder>? salesOrders,
    List<PickingWave>? activeWaves,
    PickingWave? selectedWave,
    bool clearSelectedWave = false,
    PackingSession? activePackingSession,
    bool clearPackingSession = false,
    OutboundStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? isLoading,
    String? errorMessage,
    SalesOrder? selectedOrder,
    bool clearSelectedOrder = false,
  }) {
    return OutboundState(
      salesOrders: salesOrders ?? this.salesOrders,
      activeWaves: activeWaves ?? this.activeWaves,
      selectedWave: clearSelectedWave ? null : (selectedWave ?? this.selectedWave),
      activePackingSession: clearPackingSession ? null : (activePackingSession ?? this.activePackingSession),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
    );
  }
}

class OutboundNotifier extends StateNotifier<OutboundState> {
  final IOutboundRepository _repository;
  final String _archetypeId;

  OutboundNotifier(this._repository, this._archetypeId) : super(const OutboundState()) {
    loadOutboundData();
  }

  Future<void> loadOutboundData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final ordersResult = await _repository.getSalesOrders(
      status: state.statusFilter,
      archetypeId: _archetypeId,
    );
    final wavesResult = await _repository.getActiveWaves();

    ordersResult.fold(
      onSuccess: (orders) {
        final waves = wavesResult.fold(onSuccess: (w) => w, onFailure: (_) => <PickingWave>[]);
        state = state.copyWith(
          salesOrders: orders,
          activeWaves: waves,
          selectedWave: waves.isNotEmpty ? waves.first : null,
          isLoading: false,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  void setFilter(OutboundStatus? filter) {
    if (filter == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: filter);
    }
    loadOutboundData();
  }

  void selectOrder(SalesOrder? order) {
    if (order == null) {
      state = state.copyWith(clearSelectedOrder: true);
    } else {
      state = state.copyWith(selectedOrder: order);
    }
  }

  void selectWave(PickingWave wave) {
    state = state.copyWith(selectedWave: wave);
  }

  Future<bool> createSalesOrder(SalesOrder order) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createSalesOrder(order);
    return result.fold(
      onSuccess: (_) {
        loadOutboundData();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> updateSalesOrder(SalesOrder order) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateSalesOrder(order);
    return result.fold(
      onSuccess: (updated) {
        loadOutboundData();
        if (state.selectedOrder?.id == updated.id) {
          state = state.copyWith(selectedOrder: updated);
        }
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> generateWave({
    required List<String> orderIds,
    String? pickerName,
    String? zone,
  }) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.generatePickingWave(
      orderIds: orderIds,
      assignedPickerName: pickerName,
      zone: zone,
    );
    return result.fold(
      onSuccess: (wave) {
        loadOutboundData();
        state = state.copyWith(selectedWave: wave);
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> confirmPickTask({
    required String waveId,
    required String taskId,
    required double quantityPicked,
  }) async {
    final result = await _repository.confirmPickTask(
      waveId: waveId,
      taskId: taskId,
      quantityPicked: quantityPicked,
    );
    return result.fold(
      onSuccess: (updatedWave) {
        state = state.copyWith(
          selectedWave: updatedWave,
          activeWaves: state.activeWaves.map((w) => w.id == updatedWave.id ? updatedWave : w).toList(),
        );
        loadOutboundData();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> startPacking(String orderId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.startPackingSession(orderId);
    return result.fold(
      onSuccess: (session) {
        state = state.copyWith(activePackingSession: session, isLoading: false);
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> scanPackItem(String barcode) async {
    if (state.activePackingSession == null) return false;
    final result = await _repository.verifyScanItem(
      sessionId: state.activePackingSession!.id,
      scannedBarcode: barcode,
    );
    return result.fold(
      onSuccess: (updatedSession) {
        state = state.copyWith(activePackingSession: updatedSession);
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> dispatchShipment({
    required double weightKg,
    required String carrier,
    required int boxCount,
  }) async {
    if (state.activePackingSession == null) return false;
    final result = await _repository.completePackingAndShip(
      sessionId: state.activePackingSession!.id,
      totalWeightKg: weightKg,
      carrier: carrier,
      boxCount: boxCount,
    );
    return result.fold(
      onSuccess: (completed) {
        state = state.copyWith(activePackingSession: completed);
        loadOutboundData();
        return true;
      },
      onFailure: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }
}

final outboundNotifierProvider =
    StateNotifierProvider<OutboundNotifier, OutboundState>((ref) {
  final repo = ref.watch(outboundRepositoryProvider);
  final archetype = ref.watch(archetypeProvider).archetype;
  return OutboundNotifier(repo, archetype.id);
});
