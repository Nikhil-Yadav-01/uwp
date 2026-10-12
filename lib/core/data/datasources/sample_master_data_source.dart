import '../../../features/customers/domain/models/customer.dart';
import '../../../features/vendors/domain/models/vendor.dart';
import '../../master_data/domain/models/master_data_models.dart' as master;

/// Clean data source providing realistic warehouse facilities, suppliers, and customers.
/// Written in friendly, everyday language.
class SampleMasterDataSource {
  const SampleMasterDataSource._();

  // ===========================================================================
  // WAREHOUSES & STORAGE BINS
  // ===========================================================================
  static List<master.WarehouseNode> getWarehouses() {
    return const [
      master.WarehouseNode(
        warehouseId: 'WH01',
        code: 'WH-001',
        name: 'Main Central Warehouse',
        address: 'Plot 42, Logistics Park, Sector 18',
        city: 'Delhi NCR',
        isCentralHub: true,
        zones: [
          master.WarehouseZone(
            zoneId: 'ZONE-A',
            warehouseId: 'WH01',
            name: 'Zone A (Fast-Pick Everyday Items)',
            description: 'Easy-access shelves for high-demand products',
            racks: [
              master.WarehouseRack(
                rackId: 'RACK-A01',
                zoneId: 'ZONE-A',
                warehouseId: 'WH01',
                totalShelves: 4,
                bins: [
                  master.WarehouseBin(
                    binId: 'A01-01-01',
                    rackId: 'RACK-A01',
                    zoneId: 'ZONE-A',
                    warehouseId: 'WH01',
                    barcode: 'LOC-A01-01-01',
                    currentOccupancyPercent: 85,
                    maxWeightKg: 100.0,
                  ),
                  master.WarehouseBin(
                    binId: 'A01-01-02',
                    rackId: 'RACK-A01',
                    zoneId: 'ZONE-A',
                    warehouseId: 'WH01',
                    barcode: 'LOC-A01-01-02',
                    currentOccupancyPercent: 40,
                    maxWeightKg: 100.0,
                  ),
                  master.WarehouseBin(
                    binId: 'A01-01-03',
                    rackId: 'RACK-A01',
                    zoneId: 'ZONE-A',
                    warehouseId: 'WH01',
                    barcode: 'LOC-A01-01-03',
                    currentOccupancyPercent: 10,
                    maxWeightKg: 100.0,
                  ),
                ],
              ),
              master.WarehouseRack(
                rackId: 'RACK-A02',
                zoneId: 'ZONE-A',
                warehouseId: 'WH01',
                totalShelves: 3,
                bins: [
                  master.WarehouseBin(
                    binId: 'A02-01-01',
                    rackId: 'RACK-A02',
                    zoneId: 'ZONE-A',
                    warehouseId: 'WH01',
                    barcode: 'LOC-A02-01-01',
                    currentOccupancyPercent: 95,
                    maxWeightKg: 150.0,
                  ),
                  master.WarehouseBin(
                    binId: 'A02-01-02',
                    rackId: 'RACK-A02',
                    zoneId: 'ZONE-A',
                    warehouseId: 'WH01',
                    barcode: 'LOC-A02-01-02',
                    currentOccupancyPercent: 25,
                    maxWeightKg: 150.0,
                  ),
                ],
              ),
            ],
          ),
          master.WarehouseZone(
            zoneId: 'ZONE-B',
            warehouseId: 'WH01',
            name: 'Zone B (Walk-in Cold Room & Locked Safe)',
            description: 'Cold room (+2°C to +4°C) and locked medicine safe',
            racks: [
              master.WarehouseRack(
                rackId: 'RACK-B01',
                zoneId: 'ZONE-B',
                warehouseId: 'WH01',
                totalShelves: 3,
                bins: [
                  master.WarehouseBin(
                    binId: 'B01-01-01',
                    rackId: 'RACK-B01',
                    zoneId: 'ZONE-B',
                    warehouseId: 'WH01',
                    barcode: 'LOC-B01-01-01',
                    isColdZone: true,
                    currentOccupancyPercent: 65,
                    maxWeightKg: 200.0,
                  ),
                  master.WarehouseBin(
                    binId: 'B01-01-02',
                    rackId: 'RACK-B01',
                    zoneId: 'ZONE-B',
                    warehouseId: 'WH01',
                    barcode: 'LOC-B01-01-02',
                    isVaultZone: true,
                    currentOccupancyPercent: 30,
                    maxWeightKg: 200.0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      master.WarehouseNode(
        warehouseId: 'WH02',
        code: 'WH-002',
        name: 'Harbor Transit Warehouse',
        address: 'Plot 104, Marine Logistics Hub',
        city: 'Mumbai',
        isCentralHub: false,
        zones: [
          master.WarehouseZone(
            zoneId: 'ZONE-MUM-A',
            warehouseId: 'WH02',
            name: 'Zone A (In-Transit Shipping Goods)',
            description: 'Cross-dock staging area for ocean and road cargo',
            racks: [
              master.WarehouseRack(
                rackId: 'RACK-M01',
                zoneId: 'ZONE-MUM-A',
                warehouseId: 'WH02',
                totalShelves: 2,
                bins: [
                  master.WarehouseBin(
                    binId: 'M01-01-01',
                    rackId: 'RACK-M01',
                    zoneId: 'ZONE-MUM-A',
                    warehouseId: 'WH02',
                    barcode: 'LOC-M01-01-01',
                    currentOccupancyPercent: 55,
                    maxWeightKg: 300.0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      master.WarehouseNode(
        warehouseId: 'WH03',
        code: 'WH-003',
        name: 'Tech & Electronics Hub',
        address: 'Electronic City Phase 2',
        city: 'Bangalore',
        isCentralHub: false,
        zones: [
          master.WarehouseZone(
            zoneId: 'ZONE-BLR-A',
            warehouseId: 'WH03',
            name: 'Zone A (Clean Tech Storage)',
            description: 'Secure dust-free rooms for smartphones and laptops',
            racks: [],
          ),
        ],
      ),
      master.WarehouseNode(
        warehouseId: 'WH04',
        code: 'WH-004',
        name: 'Heavy Parts & Tools Depot',
        address: 'Chakan Industrial Corridor',
        city: 'Pune',
        isCentralHub: false,
        zones: [],
      ),
    ];
  }

  // ===========================================================================
  // SUPPLIERS / VENDORS
  // ===========================================================================
  static List<Vendor> getVendors() {
    final now = DateTime.now();

    return [
      Vendor(
        id: 'SUP-001',
        code: 'SUP-001',
        name: 'ABC Traders & Leather Tannery',
        contactPerson: 'Marco Rossi',
        email: 'orders@abctraders-leather.com',
        phone: '+39 055 1234567',
        gstin: '27AAAAA0000A1Z5',
        city: 'Florence & Mumbai',
        address: 'Via delle Concerie 14 / Lower Parel Hub',
        rating: 4.9,
        paymentTerms: PaymentTerms.net60,
        leadTimeDays: 14,
        isActive: true,
        totalPurchaseOrders: 28,
        createdAt: now.subtract(const Duration(days: 360)),
      ),
      Vendor(
        id: 'SUP-002',
        code: 'SUP-002',
        name: 'Alpine Fresh Dairy & Farms',
        contactPerson: 'David Miller',
        email: 'orders@alpinedairy.com',
        phone: '+1 707 555 0192',
        gstin: 'US-941038291',
        city: 'Sonoma, California',
        address: '1400 Valley View Farm Road',
        rating: 4.95,
        paymentTerms: PaymentTerms.net15,
        leadTimeDays: 2,
        isActive: true,
        totalPurchaseOrders: 94,
        createdAt: now.subtract(const Duration(days: 300)),
      ),
      Vendor(
        id: 'SUP-003',
        code: 'SUP-003',
        name: 'Apex Electronics Distribution',
        contactPerson: 'Chen Wei',
        email: 'b2b@apextech.com',
        phone: '+886 2 2345 6789',
        gstin: 'TW-87654321',
        city: 'Hsinchu Science Park',
        address: 'Innovation Road Building 4',
        rating: 4.9,
        paymentTerms: PaymentTerms.net30,
        leadTimeDays: 5,
        isActive: true,
        totalPurchaseOrders: 62,
        createdAt: now.subtract(const Duration(days: 240)),
      ),
      Vendor(
        id: 'SUP-004',
        code: 'SUP-004',
        name: 'Highland Craft Beverage & Distillers',
        contactPerson: 'Callum MacLeod',
        email: 'supply@highlandcraft.co.uk',
        phone: '+44 1343 555018',
        gstin: 'GB-992138401',
        city: 'Speyside, Scotland',
        address: 'Highland Glen Distillery Estate',
        rating: 4.85,
        paymentTerms: PaymentTerms.net30,
        leadTimeDays: 7,
        isActive: true,
        totalPurchaseOrders: 42,
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      Vendor(
        id: 'SUP-005',
        code: 'SUP-005',
        name: 'City Pharmaceutical Distributors',
        contactPerson: 'Dr. Rebecca Evans',
        email: 'procurement@citypharma.org',
        phone: '+1 908 555 0144',
        gstin: 'US-229910482',
        city: 'Bridgewater, New Jersey',
        address: 'Route 202 Life Sciences Campus',
        rating: 4.98,
        paymentTerms: PaymentTerms.net30,
        leadTimeDays: 3,
        isActive: true,
        totalPurchaseOrders: 78,
        createdAt: now.subtract(const Duration(days: 180)),
      ),
      Vendor(
        id: 'SUP-006',
        code: 'SUP-006',
        name: 'Brembo Auto Parts & Brakes',
        contactPerson: 'Matteo Ferrari',
        email: 'sales@brembo-supply.de',
        phone: '+49 711 555019',
        gstin: 'DE-812390142',
        city: 'Stuttgart, Germany',
        address: 'Industriestrasse 22',
        rating: 4.88,
        paymentTerms: PaymentTerms.advance,
        leadTimeDays: 4,
        isActive: true,
        totalPurchaseOrders: 35,
        createdAt: now.subtract(const Duration(days: 150)),
      ),
      Vendor(
        id: 'SUP-007',
        code: 'SUP-007',
        name: 'Tokyo Cotton & Garment Mills',
        contactPerson: 'Kenji Sato',
        email: 'orders@tokyotextiles.jp',
        phone: '+81 3 5555 0188',
        gstin: 'JP-901482019',
        city: 'Okayama, Japan',
        address: 'Kurashiki Textile Quarter 8',
        rating: 4.92,
        paymentTerms: PaymentTerms.net60,
        leadTimeDays: 12,
        isActive: true,
        totalPurchaseOrders: 51,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
    ];
  }

  // Master Supplier list mapped from Vendor models
  static List<master.Supplier> getMasterSuppliers() {
    return getVendors().map((v) {
      return master.Supplier(
        supplierId: v.id,
        code: v.code,
        name: v.name,
        contactPerson: v.contactPerson,
        email: v.email,
        phone: v.phone,
        rating: v.rating,
        taxId: v.gstin,
        city: v.city,
      );
    }).toList();
  }

  // ===========================================================================
  // CUSTOMERS
  // ===========================================================================
  static List<Customer> getCustomers() {
    final now = DateTime.now();

    return [
      Customer(
        id: 'CUST-001',
        code: 'CUST-001',
        name: 'City General Hospital (Emergency & ICU)',
        contactPerson: 'Dr. Vivek Menon',
        email: 'pharmacy@citygeneral.org',
        phone: '+1 212 555 0199',
        gstin: 'US-HOSP-99120',
        city: 'New York City',
        address: 'First Avenue Medical Center',
        tier: CustomerTier.healthcarePriority,
        isActive: true,
        totalOrders: 64,
        outstandingBalance: 125000.0,
        createdAt: now.subtract(const Duration(days: 280)),
      ),
      Customer(
        id: 'CUST-002',
        code: 'CUST-002',
        name: 'The Corner Cocktail Lounge & Bar',
        contactPerson: 'Liam Gallagher',
        email: 'manager@cornercocktails.com',
        phone: '+1 312 555 0177',
        gstin: 'US-BAR-88123',
        city: 'Chicago, Illinois',
        address: '224 Michigan Avenue',
        tier: CustomerTier.retail,
        isActive: true,
        totalOrders: 38,
        outstandingBalance: 4200.0,
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      Customer(
        id: 'CUST-003',
        code: 'CUST-003',
        name: 'Fresh Market Supermarket',
        contactPerson: 'Sarah Jenkins',
        email: 'orders@freshmarket.com',
        phone: '+1 415 555 0144',
        gstin: 'US-GROC-77142',
        city: 'San Francisco, California',
        address: 'Market Street Store #12',
        tier: CustomerTier.wholesale,
        isActive: true,
        totalOrders: 86,
        outstandingBalance: 18500.0,
        createdAt: now.subtract(const Duration(days: 180)),
      ),
      Customer(
        id: 'CUST-004',
        code: 'CUST-004',
        name: 'Downtown Tech & Mobile Store',
        contactPerson: 'Karan Mehra',
        email: 'contact@downtowntech.com',
        phone: '+1 206 555 0188',
        gstin: 'US-TECH-66129',
        city: 'Seattle, Washington',
        address: 'Pine Street Shopping Mall',
        tier: CustomerTier.enterprise,
        isActive: true,
        totalOrders: 45,
        outstandingBalance: 14500.0,
        createdAt: now.subtract(const Duration(days: 150)),
      ),
      Customer(
        id: 'CUST-005',
        code: 'CUST-005',
        name: 'Fashion Street Clothing Boutique',
        contactPerson: 'Emma Watson',
        email: 'buyer@fashionstreet.co',
        phone: '+1 310 555 0122',
        gstin: 'US-FSH-55104',
        city: 'Los Angeles, California',
        address: 'Rodeo Drive Boutique #4',
        tier: CustomerTier.retail,
        isActive: true,
        totalOrders: 22,
        outstandingBalance: 6400.0,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      Customer(
        id: 'CUST-006',
        code: 'CUST-006',
        name: 'Express Fleet Auto Repair Center',
        contactPerson: 'Carlos Rodriguez',
        email: 'parts@expressfleet.com',
        phone: '+1 214 555 0133',
        gstin: 'US-AUTO-44198',
        city: 'Dallas, Texas',
        address: 'Industrial Boulevard Bay 3',
        tier: CustomerTier.wholesale,
        isActive: true,
        totalOrders: 54,
        outstandingBalance: 24800.0,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      Customer(
        id: 'CUST-007',
        code: 'CUST-007',
        name: 'Amazon Central Warehouse Depot',
        contactPerson: 'Pooja Nair',
        email: 'support@amazon.in',
        phone: '+91 80 5555 0199',
        gstin: '29BBBBB0000B1Z2',
        city: 'Bangalore, India',
        address: 'FC BLR1 Logistics Corridor',
        tier: CustomerTier.enterprise,
        isActive: true,
        totalOrders: 142,
        outstandingBalance: 84000.0,
        createdAt: now.subtract(const Duration(days: 300)),
      ),
    ];
  }

  // Master Customer list mapped from Customer models
  static List<master.Customer> getMasterCustomers() {
    return getCustomers().map((c) {
      return master.Customer(
        customerId: c.id,
        code: c.code,
        name: c.name,
        contactPerson: c.contactPerson,
        email: c.email,
        phone: c.phone,
        tier: c.tier.label,
        taxId: c.gstin,
        city: c.city,
      );
    }).toList();
  }
}
