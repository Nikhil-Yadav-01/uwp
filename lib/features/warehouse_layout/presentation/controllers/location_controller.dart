import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/master_data/data/repositories/in_memory_master_data_repository.dart';
import '../../../../core/master_data/domain/models/master_data_models.dart';

class LocationState {
  final List<WarehouseNode> warehouses;
  final String selectedWarehouseId;
  final String? selectedZoneId;
  final String? selectedRackId;
  final String? selectedBinId;
  final String searchQuery;

  const LocationState({
    required this.warehouses,
    required this.selectedWarehouseId,
    this.selectedZoneId,
    this.selectedRackId,
    this.selectedBinId,
    this.searchQuery = '',
  });

  WarehouseNode get activeWarehouse {
    return warehouses.firstWhere(
      (w) => w.warehouseId == selectedWarehouseId,
      orElse: () => warehouses.first,
    );
  }

  WarehouseZone? get activeZone {
    if (selectedZoneId == null) {
      return activeWarehouse.zones.isNotEmpty ? activeWarehouse.zones.first : null;
    }
    try {
      return activeWarehouse.zones.firstWhere((z) => z.zoneId == selectedZoneId);
    } catch (_) {
      return activeWarehouse.zones.isNotEmpty ? activeWarehouse.zones.first : null;
    }
  }

  WarehouseBin? get activeBin {
    if (selectedBinId == null) {
      final zone = activeZone;
      if (zone != null && zone.racks.isNotEmpty && zone.racks.first.bins.isNotEmpty) {
        return zone.racks.first.bins.first;
      }
      return null;
    }
    for (final zone in activeWarehouse.zones) {
      for (final rack in zone.racks) {
        for (final bin in rack.bins) {
          if (bin.binId == selectedBinId) return bin;
        }
      }
    }
    return null;
  }

  LocationState copyWith({
    List<WarehouseNode>? warehouses,
    String? selectedWarehouseId,
    String? selectedZoneId,
    String? selectedRackId,
    String? selectedBinId,
    String? searchQuery,
    bool clearBin = false,
  }) {
    return LocationState(
      warehouses: warehouses ?? this.warehouses,
      selectedWarehouseId: selectedWarehouseId ?? this.selectedWarehouseId,
      selectedZoneId: selectedZoneId ?? this.selectedZoneId,
      selectedRackId: selectedRackId ?? this.selectedRackId,
      selectedBinId: clearBin ? null : (selectedBinId ?? this.selectedBinId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final InMemoryMasterDataRepository _repo;

  LocationNotifier(this._repo)
      : super(
          LocationState(
            warehouses: _repo.getWarehouses(),
            selectedWarehouseId: _repo.getWarehouses().isNotEmpty ? _repo.getWarehouses().first.warehouseId : 'WH01',
          ),
        );

  void selectWarehouse(String warehouseId) {
    state = state.copyWith(
      selectedWarehouseId: warehouseId,
      selectedZoneId: null,
      selectedRackId: null,
      clearBin: true,
    );
  }

  void selectZone(String zoneId) {
    state = state.copyWith(
      selectedZoneId: zoneId,
      selectedRackId: null,
      clearBin: true,
    );
  }

  void selectBin(String binId) {
    state = state.copyWith(selectedBinId: binId);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void addWarehouse({
    required String code,
    required String name,
    required String address,
    required String city,
    bool isCentralHub = false,
  }) {
    final nextId = 'WH${(state.warehouses.length + 1).toString().padLeft(2, '0')}';
    final newWh = WarehouseNode(
      warehouseId: nextId,
      code: code,
      name: name,
      address: address,
      city: city,
      isCentralHub: isCentralHub,
      zones: [
        WarehouseZone(
          zoneId: 'ZONE-A',
          warehouseId: nextId,
          name: 'Zone A (General Storage)',
          description: 'Standard storage area',
          racks: [
            WarehouseRack(
              rackId: 'RACK-01',
              zoneId: 'ZONE-A',
              warehouseId: nextId,
              totalShelves: 3,
              bins: [
                WarehouseBin(binId: 'A01-01-01', rackId: 'RACK-01', zoneId: 'ZONE-A', warehouseId: nextId, barcode: 'LOC-A01-01-01'),
              ],
            ),
          ],
        ),
      ],
    );
    _repo.addWarehouse(newWh);
    state = state.copyWith(warehouses: _repo.getWarehouses());
  }

  void addZone({
    required String warehouseId,
    required String name,
    required String description,
  }) {
    final wh = state.activeWarehouse;
    final nextId = 'ZONE-${String.fromCharCode(65 + wh.zones.length)}';
    final zone = WarehouseZone(
      zoneId: nextId,
      warehouseId: warehouseId,
      name: name,
      description: description,
      racks: [],
    );
    _repo.addZone(warehouseId, zone);
    state = state.copyWith(warehouses: _repo.getWarehouses());
  }

  void addBin({
    required String warehouseId,
    required String zoneId,
    required String rackId,
    required String binCode,
    double maxWeightKg = 50.0,
  }) {
    final bin = WarehouseBin(
      binId: binCode,
      rackId: rackId,
      zoneId: zoneId,
      warehouseId: warehouseId,
      barcode: 'LOC-$binCode',
      maxWeightKg: maxWeightKg,
      currentOccupancyPercent: 0,
    );
    _repo.addBin(warehouseId, zoneId, rackId, bin);
    state = state.copyWith(warehouses: _repo.getWarehouses(), selectedBinId: binCode);
  }
}

final locationNotifierProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(InMemoryMasterDataRepository());
});
