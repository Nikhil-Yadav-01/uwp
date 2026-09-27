import '../../domain/models/master_data_models.dart';

class InMemoryMasterDataRepository {
  static final InMemoryMasterDataRepository _instance = InMemoryMasterDataRepository._internal();
  factory InMemoryMasterDataRepository() => _instance;
  InMemoryMasterDataRepository._internal();

  final List<WarehouseNode> _warehouses = [
    WarehouseNode(
      warehouseId: 'WH01',
      code: 'WH-CENTRAL',
      name: 'Central Distribution Hub #01',
      address: 'Plot 42, Logistics Park, Sector 18',
      city: 'Gurugram',
      isCentralHub: true,
      zones: [
        WarehouseZone(
          zoneId: 'ZONE-A',
          warehouseId: 'WH01',
          name: 'Zone A (Fast Velocity / Pallet Racks)',
          description: 'High turnover rapid picking aisles',
          racks: [
            WarehouseRack(
              rackId: 'RACK-A01',
              zoneId: 'ZONE-A',
              warehouseId: 'WH01',
              totalShelves: 4,
              bins: [
                WarehouseBin(binId: 'BIN-A01-01', rackId: 'RACK-A01', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A01-01', currentOccupancyPercent: 85),
                WarehouseBin(binId: 'BIN-A01-02', rackId: 'RACK-A01', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A01-02', currentOccupancyPercent: 40),
                WarehouseBin(binId: 'BIN-A01-03', rackId: 'RACK-A01', zoneId: 'ZONE-A', warehouseId: 'WH01', barcode: 'LOC-A01-03', currentOccupancyPercent: 90),
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
                WarehouseBin(binId: 'BIN-B01-01', rackId: 'RACK-B01', zoneId: 'ZONE-B', warehouseId: 'WH01', barcode: 'LOC-B01-01', isColdZone: true, currentOccupancyPercent: 65),
                WarehouseBin(binId: 'BIN-B01-02', rackId: 'RACK-B01', zoneId: 'ZONE-B', warehouseId: 'WH01', barcode: 'LOC-B01-02', isVaultZone: true, currentOccupancyPercent: 30),
              ],
            ),
          ],
        ),
      ],
    ),
    WarehouseNode(
      warehouseId: 'WH02',
      code: 'WH-RETAIL-NORTH',
      name: 'North Retail Fulfillment Depot #02',
      address: 'Industrial Area Phase 1',
      city: 'Chandigarh',
      isCentralHub: false,
      zones: [
        WarehouseZone(
          zoneId: 'ZONE-NORTH-A',
          warehouseId: 'WH02',
          name: 'Zone North-A (Counter Stock)',
          description: 'Front store rapid restock bins',
          racks: [],
        ),
      ],
    ),
    WarehouseNode(
      warehouseId: 'WH03',
      code: 'WH-PORT-SOUTH',
      name: 'Port Export Freight Terminal #03',
      address: 'Dockyard Marine Drive',
      city: 'Mumbai',
      isCentralHub: false,
      zones: [],
    ),
  ];

  final List<Supplier> _suppliers = [
    const Supplier(
      supplierId: 'SUP-001',
      code: 'SUP-ITAL-LEATH',
      name: 'Toscana Fine Leather Tannery S.p.A.',
      contactPerson: 'Marco Rossi',
      email: 'orders@toscanaleather.it',
      phone: '+39 055 1234567',
      rating: 4.9,
      taxId: 'IT-987654321',
      city: 'Florence',
    ),
    const Supplier(
      supplierId: 'SUP-002',
      code: 'SUP-AGRO-FRESH',
      name: 'Himalayan Organic Farms Pvt Ltd',
      contactPerson: 'Rajesh Sharma',
      email: 'supply@himalayanfresh.in',
      phone: '+91 98123 45678',
      rating: 4.8,
      taxId: 'GSTIN07AAACH1234F1Z5',
      city: 'Shimla',
    ),
    const Supplier(
      supplierId: 'SUP-003',
      code: 'SUP-SILICON-ASIA',
      name: 'Apex Semiconductor & Micro-Optics Co.',
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
      code: 'CUST-LUX-RETAIL',
      name: 'Milan Flagship Luxury Boutique',
      contactPerson: 'Elena Bianchi',
      email: 'buyer@milanboutique.com',
      phone: '+39 02 8765432',
      tier: 'Enterprise Platinum',
      taxId: 'IT-112233445',
      city: 'Milan',
    ),
    const Customer(
      customerId: 'CUST-002',
      code: 'CUST-METRO-HOSP',
      name: 'Apollo Super Specialty Hospital & Trauma Ward',
      contactPerson: 'Dr. Vivek Menon',
      email: 'pharmacy.procure@apollohospitals.org',
      phone: '+91 99887 76655',
      tier: 'Healthcare Priority',
      taxId: 'GSTIN33AAACA9999P1Z2',
      city: 'Chennai',
    ),
    const Customer(
      customerId: 'CUST-003',
      code: 'CUST-TECH-MART',
      name: 'CyberTech Electronics Retail Superstore',
      contactPerson: 'Alex Vance',
      email: 'orders@cybertechmart.com',
      phone: '+1 415 555 0199',
      tier: 'Wholesale Tier 1',
      taxId: 'US-941234567',
      city: 'San Francisco',
    ),
  ];

  List<WarehouseNode> getWarehouses() => List.unmodifiable(_warehouses);
  List<Supplier> getSuppliers() => List.unmodifiable(_suppliers);
  List<Customer> getCustomers() => List.unmodifiable(_customers);
}
