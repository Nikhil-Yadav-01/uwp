import '../../domain/models/master_data_models.dart';

class InMemoryMasterDataRepository {
  static final InMemoryMasterDataRepository _instance = InMemoryMasterDataRepository._internal();
  factory InMemoryMasterDataRepository() => _instance;
  InMemoryMasterDataRepository._internal();

  final List<WarehouseNode> _warehouses = [
    WarehouseNode(
      warehouseId: 'WH01',
      code: 'WH-001',
      name: 'Delhi Central Distribution Hub #01',
      address: 'Plot 42, Logistics Park, Sector 18',
      city: 'Delhi NCR',
      isCentralHub: true,
      zones: [
        WarehouseZone(
          zoneId: 'ZONE-A',
          warehouseId: 'WH01',
          name: 'Zone A (Fast Velocity / Storage)',
          description: 'High turnover rapid picking aisles',
          racks: [
            WarehouseRack(
              rackId: 'RACK-A01',
              zoneId: 'ZONE-A',
              warehouseId: 'WH01',
              totalShelves: 4,
              bins: [
                WarehouseBin(binId: 'A01-01-01', rackId: 'RACK-A01', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A01-01-01', currentOccupancyPercent: 85, maxWeightKg: 50.0),
                WarehouseBin(binId: 'A01-01-02', rackId: 'RACK-A01', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A01-01-02', currentOccupancyPercent: 40, maxWeightKg: 50.0),
                WarehouseBin(binId: 'A01-01-03', rackId: 'RACK-A01', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A01-01-03', currentOccupancyPercent: 0, maxWeightKg: 50.0),
              ],
            ),
            WarehouseRack(
              rackId: 'RACK-A02',
              zoneId: 'ZONE-A',
              warehouseId: 'WH01',
              totalShelves: 3,
              bins: [
                WarehouseBin(binId: 'A02-01-01', rackId: 'RACK-A02', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A02-01-01', currentOccupancyPercent: 100, maxWeightKg: 75.0),
                WarehouseBin(binId: 'A02-01-02', rackId: 'RACK-A02', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A02-01-02', currentOccupancyPercent: 20, maxWeightKg: 75.0),
              ],
            ),
          ],
        ),
        WarehouseZone(
          zoneId: 'ZONE-B',
          warehouseId: 'WH01',
          name: 'Zone B (Climate Controlled / Cold Vault)',
          description: '0°C to 4°C chilled food & sensitive biologics vault',
          racks: [
            WarehouseRack(
              rackId: 'RACK-B01',
              zoneId: 'ZONE-B',
              warehouseId: 'WH01',
              totalShelves: 3,
              bins: [
                WarehouseBin(binId: 'B01-01-01', rackId: 'RACK-B01', zoneId: 'ZONE-B', warehouseId: 'WH01', barcode: 'LOC-B01-01-01', isColdZone: true, currentOccupancyPercent: 65, maxWeightKg: 100.0),
                WarehouseBin(binId: 'B01-01-02', rackId: 'RACK-B01', zoneId: 'ZONE-B', warehouseId: 'WH01', barcode: 'LOC-B01-01-02', isVaultZone: true, currentOccupancyPercent: 30, maxWeightKg: 100.0),
              ],
            ),
          ],
        ),
      ],
    ),
    WarehouseNode(
      warehouseId: 'WH02',
      code: 'WH-002',
      name: 'Mumbai Marine Forwarding Warehouse #02',
      address: 'Plot 104, Kalamboli Logistics Zone',
      city: 'Mumbai',
      isCentralHub: false,
      zones: [
        WarehouseZone(
          zoneId: 'ZONE-MUM-A',
          warehouseId: 'WH02',
          name: 'Zone A (General Merchandise)',
          description: 'Bulk transit staging',
          racks: [
            WarehouseRack(
              rackId: 'RACK-M01',
              zoneId: 'ZONE-MUM-A',
              warehouseId: 'WH02',
              totalShelves: 2,
              bins: [
                WarehouseBin(binId: 'M01-01-01', rackId: 'RACK-M01', zoneId: 'ZONE-MUM-A', warehouseId: 'WH02', barcode: 'LOC-M01-01-01', currentOccupancyPercent: 50, maxWeightKg: 100.0),
              ],
            ),
          ],
        ),
      ],
    ),
    WarehouseNode(
      warehouseId: 'WH03',
      code: 'WH-003',
      name: 'Bangalore Tech Park Depot #03',
      address: 'Electronic City Phase 2',
      city: 'Bangalore',
      isCentralHub: false,
      zones: [
        WarehouseZone(
          zoneId: 'ZONE-BLR-A',
          warehouseId: 'WH03',
          name: 'Zone A (Electronics Vault)',
          description: 'ESD-safe automated bins',
          racks: [],
        ),
      ],
    ),
    WarehouseNode(
      warehouseId: 'WH04',
      code: 'WH-004',
      name: 'Pune Industrial Transit Hub #04',
      address: 'Chakan MIDC Industrial Corridor',
      city: 'Pune',
      isCentralHub: false,
      zones: [],
    ),
  ];

  final List<Supplier> _suppliers = [
    const Supplier(
      supplierId: 'SUP-001',
      code: 'SUP-ABC-TRADERS',
      name: 'ABC Traders & Global Imports',
      contactPerson: 'Suresh Singhania',
      email: 'sales@abctraders.com',
      phone: '+91 98112 34567',
      rating: 4.8,
      taxId: '27AAAAA0000A1Z5',
      city: 'Mumbai',
    ),
    const Supplier(
      supplierId: 'SUP-002',
      code: 'SUP-GLOBAL-SUP',
      name: 'Global Suppliers & Co.',
      contactPerson: 'Harish Mehta',
      email: 'supply@globalsuppliers.in',
      phone: '+91 98223 45678',
      rating: 4.9,
      taxId: '27BBBBB0000B1Z6',
      city: 'Delhi',
    ),
    const Supplier(
      supplierId: 'SUP-003',
      code: 'SUP-TECH-CORP',
      name: 'Tech Corporation Ltd.',
      contactPerson: 'Amitabh Joshi',
      email: 'contact@techcorp.com',
      phone: '+91 98334 56789',
      rating: 4.95,
      taxId: '29CCCCC0000C1Z7',
      city: 'Bangalore',
    ),
    const Supplier(
      supplierId: 'SUP-004',
      code: 'SUP-TOSCANA-LEATH',
      name: 'Toscana Fine Leather Tannery S.p.A.',
      contactPerson: 'Marco Rossi',
      email: 'orders@toscanaleather.it',
      phone: '+39 055 1234567',
      rating: 4.9,
      taxId: 'IT-987654321',
      city: 'Florence',
    ),
    const Supplier(
      supplierId: 'SUP-005',
      code: 'SUP-APEX-SEMI',
      name: 'Apex Semiconductor & Tech Corp',
      contactPerson: 'Chen Wei',
      email: 'b2b@apexsemi.tw',
      phone: '+886 2 2345 6789',
      rating: 4.95,
      taxId: 'TW-87654321',
      city: 'Hsinchu',
    ),
  ];

  final List<Customer> _customers = [
    const Customer(
      customerId: 'CUST-001',
      code: 'CUST-XYZ-RET',
      name: 'XYZ Retailers Pvt Ltd',
      contactPerson: 'Karan Mehra',
      email: 'xyz@retailer.com',
      phone: '+91 99112 23344',
      tier: 'Enterprise Platinum',
      taxId: '27AAAAA0000A1Z5',
      city: 'Mumbai',
    ),
    const Customer(
      customerId: 'CUST-002',
      code: 'CUST-AMAZON-IN',
      name: 'Amazon Fulfillment Services',
      contactPerson: 'Pooja Nair',
      email: 'support@amazon.in',
      phone: '+91 99223 34455',
      tier: 'Enterprise',
      taxId: '29BBBBB0000B1Z2',
      city: 'Bangalore',
    ),
    const Customer(
      customerId: 'CUST-003',
      code: 'CUST-FLIPKART',
      name: 'Flipkart Logistics India',
      contactPerson: 'Rohit Verma',
      email: 'vendor-ops@flipkart.com',
      phone: '+91 99334 45566',
      tier: 'Enterprise',
      taxId: '29CCCCC0000C1Z4',
      city: 'Bangalore',
    ),
    const Customer(
      customerId: 'CUST-004',
      code: 'CUST-APOLLO-HOSP',
      name: 'Apollo Super Specialty Hospital',
      contactPerson: 'Dr. Vivek Menon',
      email: 'procure@apollohospitals.org',
      phone: '+91 99887 76655',
      tier: 'Healthcare Priority',
      taxId: '33AAACA9999P1Z2',
      city: 'Chennai',
    ),
    const Customer(
      customerId: 'CUST-005',
      code: 'CUST-LOCAL-STORE',
      name: 'Prime Local Department Store',
      contactPerson: 'Ramesh Gupta',
      email: 'store@localretail.com',
      phone: '+91 98445 56677',
      tier: 'Retail',
      taxId: '07DDDDD0000D1Z9',
      city: 'Delhi',
    ),
  ];

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
