import '../../domain/models/return_request.dart';

abstract class IReturnsRepository {
  List<ReturnRequest> getAll();
  ReturnRequest? getById(String id);
  void add(ReturnRequest returnRequest);
  void update(ReturnRequest returnRequest);
  void updateStatus(String id, ReturnStatus status, {String? binLocation});
}

class InMemoryReturnsRepository implements IReturnsRepository {
  static final InMemoryReturnsRepository _instance = InMemoryReturnsRepository._internal();
  factory InMemoryReturnsRepository() => _instance;
  InMemoryReturnsRepository._internal();

  final List<ReturnRequest> _returns = [
    ReturnRequest(
      id: 'RTN-0012',
      returnNumber: 'RTN-0012',
      salesOrderNumber: 'SO-0456',
      customerName: 'XYZ Retailers Pvt Ltd',
      sku: 'MOB-SAM-A55',
      productName: 'Samsung Galaxy A55 5G (128GB)',
      quantity: 2,
      reason: ReturnReason.damagedInTransit,
      status: ReturnStatus.pending,
      trackingNumber: 'DTDC-RET-9912',
      notes: 'Outer package crushed during courier transit.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    ReturnRequest(
      id: 'RTN-0011',
      returnNumber: 'RTN-0011',
      salesOrderNumber: 'SO-0455',
      customerName: 'Amazon Fulfillment Services',
      sku: 'LAP-HP-15',
      productName: 'HP Pavilion 15" i7 Laptop',
      quantity: 1,
      reason: ReturnReason.wrongItemShipped,
      status: ReturnStatus.approved,
      trackingNumber: 'BD-RET-8821',
      notes: 'Customer ordered 16GB RAM model, 8GB dispatched.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReturnRequest(
      id: 'RTN-0010',
      returnNumber: 'RTN-0010',
      salesOrderNumber: 'SO-0454',
      customerName: 'Prime Local Store & Supermarket',
      sku: 'TV-SONY-55',
      productName: 'Sony Bravia 55" 4K UHD LED TV',
      quantity: 1,
      reason: ReturnReason.customerReturn,
      status: ReturnStatus.received,
      assignedBinLocation: 'A01-01-02',
      trackingNumber: 'DEL-RTO-7714',
      notes: 'Customer canceled delivery upon arrival. Sealed box intact.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ReturnRequest(
      id: 'RTN-0009',
      returnNumber: 'RTN-0009',
      salesOrderNumber: 'SO-0450',
      customerName: 'Flipkart Logistics Hub',
      sku: 'BT-JBL-001',
      productName: 'JBL Wireless Headphones',
      quantity: 5,
      reason: ReturnReason.undeliveredRto,
      status: ReturnStatus.restocked,
      assignedBinLocation: 'A01-01-01',
      notes: 'Address incomplete. Restocked back into primary picking bin.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  @override
  List<ReturnRequest> getAll() => List.unmodifiable(_returns);

  @override
  ReturnRequest? getById(String id) {
    try {
      return _returns.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void add(ReturnRequest returnRequest) {
    _returns.insert(0, returnRequest);
  }

  @override
  void update(ReturnRequest returnRequest) {
    final idx = _returns.indexWhere((r) => r.id == returnRequest.id);
    if (idx != -1) {
      _returns[idx] = returnRequest;
    }
  }

  @override
  void updateStatus(String id, ReturnStatus status, {String? binLocation}) {
    final idx = _returns.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final current = _returns[idx];
      _returns[idx] = current.copyWith(
        status: status,
        assignedBinLocation: binLocation ?? current.assignedBinLocation,
      );
    }
  }
}
