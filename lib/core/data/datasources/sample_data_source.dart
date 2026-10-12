import '../../archetypes/models/archetype_definition.dart';
import '../../../features/customers/domain/models/customer.dart';
import '../../../features/inbound/domain/models/purchase_order.dart';
import '../../../features/inbound/domain/models/qc_inspection.dart';
import '../../../features/notifications/domain/models/notification_item.dart';
import '../../../features/outbound/domain/models/packing_session.dart';
import '../../../features/outbound/domain/models/sales_order.dart';
import '../../../features/products/domain/models/product.dart';
import '../../../features/returns/domain/models/return_request.dart';
import '../../../features/vendors/domain/models/vendor.dart';
import '../../inventory/domain/models/inventory_transaction.dart';
import '../../inventory/domain/models/stock_adjustment.dart';
import '../../inventory/domain/models/stock_transfer.dart';
import '../../master_data/domain/models/master_data_models.dart' as master;
import 'sample_inbound_data_source.dart';
import 'sample_ledger_and_returns_data_source.dart';
import 'sample_master_data_source.dart';
import 'sample_notifications_data_source.dart';
import 'sample_outbound_data_source.dart';
import 'sample_products_data_source.dart';

/// Clean Architecture Unified Fake Data Source.
/// Acts as the single central entry point for all mock datasets across the app.
class SampleDataSource {
  const SampleDataSource._();

  // Products & Catalog
  static List<Product> getProducts() => SampleProductsDataSource.getAll();

  static List<Product> getProductsForArchetype(BusinessArchetypeType type) {
    return getProducts().where((p) => p.archetypeType == type).toList();
  }

  /// Converts products of a given archetype to Map format for the Archetype Handlers
  static List<Map<String, dynamic>> getDemoProductMaps(BusinessArchetypeType type) {
    return getProductsForArchetype(type).map((p) {
      return {
        'id': p.id,
        'name': p.name,
        'sku': p.sku,
        'barcode': p.barcode,
        'category': p.category,
        'stock': p.stockQuantity,
        'uom': p.baseUom,
        'unitPrice': p.sellingPrice,
        'customAttributes': Map<String, dynamic>.from(p.customAttributes),
      };
    }).toList();
  }

  // Master Data & Locations
  static List<master.WarehouseNode> getWarehouses() => SampleMasterDataSource.getWarehouses();
  static List<Vendor> getVendors() => SampleMasterDataSource.getVendors();
  static List<master.Supplier> getMasterSuppliers() => SampleMasterDataSource.getMasterSuppliers();
  static List<Customer> getCustomers() => SampleMasterDataSource.getCustomers();
  static List<master.Customer> getMasterCustomers() => SampleMasterDataSource.getMasterCustomers();

  // Inbound & Outbound
  static List<PurchaseOrder> getPurchaseOrders() => SampleInboundDataSource.getPurchaseOrders();
  static List<QcInspectionReport> getQcReports() => SampleInboundDataSource.getQcReports();
  static List<SalesOrder> getSalesOrders() => SampleOutboundDataSource.getSalesOrders();
  static List<PackingSession> getPackingSessions() => SampleOutboundDataSource.getPackingSessions();

  // Ledger & Returns
  static List<InventoryTransaction> getTransactions() => SampleLedgerAndReturnsDataSource.getTransactions();
  static List<StockTransfer> getTransfers() => SampleLedgerAndReturnsDataSource.getTransfers();
  static List<StockAdjustment> getAdjustments() => SampleLedgerAndReturnsDataSource.getAdjustments();
  static List<ReturnRequest> getReturns() => SampleLedgerAndReturnsDataSource.getReturns();

  // Notifications
  static List<NotificationItem> getNotifications() => SampleNotificationsDataSource.getAll();
}
