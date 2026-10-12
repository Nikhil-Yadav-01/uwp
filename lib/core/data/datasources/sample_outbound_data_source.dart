import '../../../features/outbound/domain/models/packing_session.dart';
import '../../../features/outbound/domain/models/sales_order.dart';

/// Clean data source providing realistic outbound customer sales orders and packing sessions.
/// Uses clear, easy-to-understand words.
class SampleOutboundDataSource {
  const SampleOutboundDataSource._();

  static List<SalesOrder> getSalesOrders() {
    final now = DateTime.now();

    return [
      // 1. Hospital Emergency Order (City General Hospital)
      SalesOrder(
        id: 'SO-HC-001',
        soNumber: 'SO-2026-HOSP-402',
        customerName: 'City General Hospital (Emergency & ICU)',
        customerType: CustomerType.hospitalWard,
        destinationWardOrAddress: 'First Avenue Medical Center • Emergency Room 4',
        orderDate: now.subtract(const Duration(hours: 3)),
        requiredDeliveryDate: now.add(const Duration(hours: 2)),
        priority: OrderPriority.emergencyCrashCart,
        status: OutboundStatus.picking,
        archetypeId: 'healthcare_pharma',
        notes: 'Urgent Hospital Order: Immediate delivery for Emergency ICU Room 4. Signed upon arrival.',
        items: const [
          SalesOrderItem(
            id: 'SOI-HC-01',
            productId: 'prod_med_001',
            productName: 'Prescription Pain Relief Medicine (10mg / 1ml)',
            sku: 'MED-RX-PAIN-10',
            requestedQty: 10.0,
            pickedQty: 10.0,
            unitPrice: 12.00,
            uom: 'vials',
            customAttributes: {
              'storage': 'Locked Medicine Safe',
              'requiresDualSignoff': true,
            },
          ),
          SalesOrderItem(
            id: 'SOI-HC-02',
            productId: 'prod_med_005',
            productName: 'Antibiotic Oral Capsules 500mg (Box of 100)',
            sku: 'MED-RX-AMX-500',
            requestedQty: 5.0,
            pickedQty: 5.0,
            unitPrice: 22.00,
            uom: 'box',
          ),
        ],
      ),

      // 2. Bar Restock Order (The Corner Cocktail Lounge & Bar)
      SalesOrder(
        id: 'SO-BAR-002',
        soNumber: 'SO-2026-BAR-771',
        customerName: 'The Corner Cocktail Lounge & Bar',
        customerType: CustomerType.barCounter,
        destinationWardOrAddress: '224 Michigan Avenue • Main Bar Tap Station',
        orderDate: now.subtract(const Duration(hours: 5)),
        priority: OrderPriority.rush,
        status: OutboundStatus.allocated,
        archetypeId: 'bars_hospitality',
        notes: 'Friday Night Bar Restock: Bottles for weekend service at the main bar counter.',
        items: const [
          SalesOrderItem(
            id: 'SOI-BAR-01',
            productId: 'prod_bar_001',
            productName: 'Highland Single Malt Scotch Whisky 18-Year (700ml)',
            sku: 'BAR-SCOTCH-18Y',
            requestedQty: 6.0,
            unitPrice: 195.00,
            uom: 'bottle',
          ),
        ],
      ),

      // 3. Supermarket Delivery Order (Fresh Market Supermarket)
      SalesOrder(
        id: 'SO-GROC-003',
        soNumber: 'SO-2026-GROC-109',
        customerName: 'Fresh Market Supermarket',
        customerType: CustomerType.b2bWholesale,
        destinationWardOrAddress: 'Market Street Store #12 • Bay Area Distribution Hub',
        orderDate: now.subtract(const Duration(hours: 6)),
        priority: OrderPriority.standard,
        status: OutboundStatus.pending,
        archetypeId: 'grocery_foods',
        notes: 'Regular store delivery. Send cartons with closest expiration dates first.',
        items: const [
          SalesOrderItem(
            id: 'SOI-GROC-01',
            productId: 'prod_gro_002',
            productName: 'Farm-Fresh Whole Milk (1 Gallon / 3.8L)',
            sku: 'GRO-MLK-GAL-01',
            requestedQty: 48.0,
            unitPrice: 4.20,
            uom: 'bottle',
          ),
        ],
      ),

      // 4. Electronics Store Order (Downtown Tech & Mobile Store)
      SalesOrder(
        id: 'SO-TECH-004',
        soNumber: 'SO-2026-TECH-902',
        customerName: 'Downtown Tech & Mobile Store',
        customerType: CustomerType.retailStore,
        destinationWardOrAddress: 'Pine Street Shopping Mall • Unit 402 Tech Plaza',
        orderDate: now.subtract(const Duration(days: 1)),
        priority: OrderPriority.standard,
        status: OutboundStatus.packed,
        archetypeId: 'electronics_tech',
        notes: 'Packed, weighed, and verified. Ready for FedEx pickup.',
        items: const [
          SalesOrderItem(
            id: 'SOI-TECH-01',
            productId: 'prod_ele_001',
            productName: 'Pro Flagship Smartphone 256GB (Midnight Black)',
            sku: 'TECH-APEX16P-256-BLK',
            requestedQty: 5.0,
            pickedQty: 5.0,
            packedQty: 5.0,
            unitPrice: 999.00,
            uom: 'units',
          ),
        ],
      ),

      // 5. Fashion Boutique Order (Fashion Street Clothing Boutique)
      SalesOrder(
        id: 'SO-FSH-005',
        soNumber: 'SO-2026-FSH-310',
        customerName: 'Fashion Street Clothing Boutique',
        customerType: CustomerType.retailStore,
        destinationWardOrAddress: 'Rodeo Drive Boutique #4, Los Angeles',
        orderDate: now.subtract(const Duration(hours: 8)),
        priority: OrderPriority.standard,
        status: OutboundStatus.pending,
        archetypeId: 'fashion_apparel',
        notes: 'Weekend stock order for hoodies and denim jeans.',
        items: const [
          SalesOrderItem(
            id: 'SOI-FSH-01',
            productId: 'prod_fsh_001',
            productName: 'Heavyweight Cotton Hoodie',
            sku: 'FSH-HD-BLK',
            requestedQty: 12.0,
            unitPrice: 88.00,
            uom: 'pcs',
          ),
        ],
      ),
    ];
  }

  static List<PackingSession> getPackingSessions() {
    final now = DateTime.now();

    return [
      PackingSession(
        id: 'PACK-TECH-001',
        orderId: 'SO-TECH-004',
        soNumber: 'SO-2026-TECH-902',
        customerName: 'Downtown Tech & Mobile Store',
        destination: 'Pine Street Shopping Mall • Unit 402 Tech Plaza',
        packerName: 'Elena Rostova (Station 2)',
        status: PackingStatus.shippingLabelGenerated,
        boxCount: 1,
        totalWeightKg: 2.8,
        trackingNumber: 'TRK-2026-FEDEX-998812',
        shippingCarrier: 'FedEx Priority Air Overnight',
        magicTrackingUrl: 'https://wms.universal.io/track/TRK-2026-FEDEX-998812',
        startedAt: now.subtract(const Duration(minutes: 45)),
        completedAt: now.subtract(const Duration(minutes: 10)),
        scannedItems: [
          PackedItem(
            productId: 'prod_ele_001',
            productName: 'Pro Flagship Smartphone 256GB (Midnight Black)',
            sku: 'ELE-PHN-PRO-256',
            barcode: '8903003001',
            quantity: 5.0,
            uom: 'units',
            scannedAt: now.subtract(const Duration(minutes: 15)),
          ),
        ],
      ),
    ];
  }
}
