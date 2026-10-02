import '../../domain/models/customer.dart';

abstract class ICustomerRepository {
  List<Customer> getAll();
  Customer? getById(String id);
  void add(Customer customer);
  void update(Customer customer);
  void toggleStatus(String id);
  void delete(String id);
}

class InMemoryCustomerRepository implements ICustomerRepository {
  static final InMemoryCustomerRepository _instance = InMemoryCustomerRepository._internal();
  factory InMemoryCustomerRepository() => _instance;
  InMemoryCustomerRepository._internal();

  final List<Customer> _customers = [
    Customer(
      id: 'CUST-001',
      code: 'CUST-001',
      name: 'XYZ Retailers Pvt Ltd',
      contactPerson: 'Karan Mehra',
      email: 'xyz@retailer.com',
      phone: '+91 99112 23344',
      gstin: '27AAAAA0000A1Z5',
      city: 'Mumbai',
      address: 'Shop 42, Phoenix Paragon Mall, Lower Parel',
      tier: CustomerTier.enterprise,
      isActive: true,
      totalOrders: 34,
      outstandingBalance: 14500.0,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    Customer(
      id: 'CUST-002',
      code: 'CUST-002',
      name: 'Amazon Fulfillment Services',
      contactPerson: 'Pooja Nair',
      email: 'support@amazon.in',
      phone: '+91 99223 34455',
      gstin: '29BBBBB0000B1Z2',
      city: 'Bangalore',
      address: 'Amazon FC BLR1, Devanahalli Logistics Corridor',
      tier: CustomerTier.enterprise,
      isActive: true,
      totalOrders: 142,
      outstandingBalance: 84000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
    Customer(
      id: 'CUST-003',
      code: 'CUST-003',
      name: 'Flipkart Logistics Hub',
      contactPerson: 'Rohit Verma',
      email: 'vendor-ops@flipkart.com',
      phone: '+91 99334 45566',
      gstin: '29CCCCC0000C1Z4',
      city: 'Bangalore',
      address: 'Kudlu Gate Sorting Hub, Hosur Main Road',
      tier: CustomerTier.wholesale,
      isActive: true,
      totalOrders: 98,
      outstandingBalance: 42000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 210)),
    ),
    Customer(
      id: 'CUST-004',
      code: 'CUST-004',
      name: 'Apollo Super Specialty Hospital',
      contactPerson: 'Dr. Vivek Menon',
      email: 'pharmacy.procure@apollohospitals.org',
      phone: '+91 99887 76655',
      gstin: '33AAACA9999P1Z2',
      city: 'Chennai',
      address: 'Greams Lane, Thousand Lights',
      tier: CustomerTier.healthcarePriority,
      isActive: true,
      totalOrders: 56,
      outstandingBalance: 125000.0,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    Customer(
      id: 'CUST-005',
      code: 'CUST-005',
      name: 'Prime Local Store & Supermarket',
      contactPerson: 'Ramesh Gupta',
      email: 'store@localretail.com',
      phone: '+91 98445 56677',
      gstin: '07DDDDD0000D1Z9',
      city: 'Delhi NCR',
      address: 'Market Block B, Connaught Place',
      tier: CustomerTier.retail,
      isActive: true,
      totalOrders: 18,
      outstandingBalance: 3200.0,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  @override
  List<Customer> getAll() => List.unmodifiable(_customers);

  @override
  Customer? getById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void add(Customer customer) {
    _customers.insert(0, customer);
  }

  @override
  void update(Customer customer) {
    final idx = _customers.indexWhere((c) => c.id == customer.id);
    if (idx != -1) {
      _customers[idx] = customer;
    }
  }

  @override
  void toggleStatus(String id) {
    final idx = _customers.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final current = _customers[idx];
      _customers[idx] = current.copyWith(isActive: !current.isActive);
    }
  }

  @override
  void delete(String id) {
    _customers.removeWhere((c) => c.id == id);
  }
}
