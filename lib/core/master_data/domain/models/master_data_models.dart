/// Hierarchy: Warehouse -> Zone -> Rack -> Shelf -> Bin
class WarehouseBin {
  final String binId; // e.g. BIN-A01-01
  final String rackId;
  final String zoneId;
  final String warehouseId;
  final String barcode;
  final double maxVolumeM3;
  final double maxWeightKg;
  final double currentOccupancyPercent;
  final bool isColdZone;
  final bool isVaultZone;
  final bool isHazmatZone;

  const WarehouseBin({
    required this.binId,
    required this.rackId,
    required this.zoneId,
    required this.warehouseId,
    required this.barcode,
    this.maxVolumeM3 = 2.5,
    this.maxWeightKg = 500.0,
    this.currentOccupancyPercent = 0.0,
    this.isColdZone = false,
    this.isVaultZone = false,
    this.isHazmatZone = false,
  });
}

class WarehouseRack {
  final String rackId;
  final String zoneId;
  final String warehouseId;
  final int totalShelves;
  final List<WarehouseBin> bins;

  const WarehouseRack({
    required this.rackId,
    required this.zoneId,
    required this.warehouseId,
    required this.totalShelves,
    required this.bins,
  });
}

class WarehouseZone {
  final String zoneId;
  final String warehouseId;
  final String name;
  final String description;
  final List<WarehouseRack> racks;

  const WarehouseZone({
    required this.zoneId,
    required this.warehouseId,
    required this.name,
    required this.description,
    required this.racks,
  });
}

class WarehouseNode {
  final String warehouseId;
  final String code;
  final String name;
  final String address;
  final String city;
  final bool isCentralHub;
  final List<WarehouseZone> zones;

  const WarehouseNode({
    required this.warehouseId,
    required this.code,
    required this.name,
    required this.address,
    required this.city,
    this.isCentralHub = false,
    required this.zones,
  });
}

/// Supplier Master Model
class Supplier {
  final String supplierId;
  final String code;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final double rating;
  final String taxId;
  final String city;

  const Supplier({
    required this.supplierId,
    required this.code,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    this.rating = 4.8,
    required this.taxId,
    required this.city,
  });
}

/// Customer Master Model
class Customer {
  final String customerId;
  final String code;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String tier; // Enterprise, Wholesale, Retail
  final String taxId;
  final String city;

  const Customer({
    required this.customerId,
    required this.code,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    this.tier = 'Enterprise',
    required this.taxId,
    required this.city,
  });
}
