import '../../../data/datasources/sample_data_source.dart';
import '../../domain/models/master_data_models.dart';

class InMemoryMasterDataRepository {
  static final InMemoryMasterDataRepository _instance = InMemoryMasterDataRepository._internal();
  factory InMemoryMasterDataRepository() => _instance;

  final List<WarehouseNode> _warehouses = [];
  final List<Supplier> _suppliers = [];
  final List<Customer> _customers = [];

  InMemoryMasterDataRepository._internal() {
    _warehouses.addAll(SampleDataSource.getWarehouses());
    _suppliers.addAll(SampleDataSource.getMasterSuppliers());
    _customers.addAll(SampleDataSource.getMasterCustomers());
  }

  List<WarehouseNode> getWarehouses() => List.unmodifiable(_warehouses);
  List<Supplier> getSuppliers() => List.unmodifiable(_suppliers);
  List<Customer> getCustomers() => List.unmodifiable(_customers);

  void addWarehouse(WarehouseNode wh) {
    _warehouses.add(wh);
  }

  void addSupplier(Supplier supplier) {
    _suppliers.add(supplier);
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
  }

  void addZone(String warehouseId, WarehouseZone zone) {
    final idx = _warehouses.indexWhere((w) => w.warehouseId == warehouseId);
    if (idx != -1) {
      final wh = _warehouses[idx];
      final updatedZones = List<WarehouseZone>.from(wh.zones)..add(zone);
      _warehouses[idx] = WarehouseNode(
        warehouseId: wh.warehouseId,
        code: wh.code,
        name: wh.name,
        address: wh.address,
        city: wh.city,
        isCentralHub: wh.isCentralHub,
        zones: updatedZones,
      );
    }
  }

  void addBin(String warehouseId, String zoneId, String rackId, WarehouseBin bin) {
    final whIdx = _warehouses.indexWhere((w) => w.warehouseId == warehouseId);
    if (whIdx == -1) return;
    final wh = _warehouses[whIdx];
    final zoneIdx = wh.zones.indexWhere((z) => z.zoneId == zoneId);
    if (zoneIdx == -1) return;
    final zone = wh.zones[zoneIdx];
    final rackIdx = zone.racks.indexWhere((r) => r.rackId == rackId);
    if (rackIdx == -1) return;
    final rack = zone.racks[rackIdx];

    final updatedBins = List<WarehouseBin>.from(rack.bins)..add(bin);
    final updatedRack = WarehouseRack(
      rackId: rack.rackId,
      zoneId: rack.zoneId,
      warehouseId: rack.warehouseId,
      totalShelves: rack.totalShelves,
      bins: updatedBins,
    );
    final updatedRacks = List<WarehouseRack>.from(zone.racks)..[rackIdx] = updatedRack;
    final updatedZone = WarehouseZone(
      zoneId: zone.zoneId,
      warehouseId: zone.warehouseId,
      name: zone.name,
      description: zone.description,
      racks: updatedRacks,
    );
    final updatedZones = List<WarehouseZone>.from(wh.zones)..[zoneIdx] = updatedZone;
    _warehouses[whIdx] = WarehouseNode(
      warehouseId: wh.warehouseId,
      code: wh.code,
      name: wh.name,
      address: wh.address,
      city: wh.city,
      isCentralHub: wh.isCentralHub,
      zones: updatedZones,
    );
  }
}
