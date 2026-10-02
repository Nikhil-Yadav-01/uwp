import '../../domain/models/vendor.dart';

abstract class IVendorRepository {
  List<Vendor> getAll();
  Vendor? getById(String id);
  void add(Vendor vendor);
  void update(Vendor vendor);
  void toggleStatus(String id);
  void delete(String id);
}

class InMemoryVendorRepository implements IVendorRepository {
  static final InMemoryVendorRepository _instance = InMemoryVendorRepository._internal();
  factory InMemoryVendorRepository() => _instance;
  InMemoryVendorRepository._internal();

  final List<Vendor> _vendors = [
    Vendor(
      id: 'SUP-001',
      code: 'SUP-001',
      name: 'ABC Traders & Global Imports',
      contactPerson: 'Suresh Singhania',
      email: 'sales@abctraders.com',
      phone: '+91 98112 34567',
      gstin: '27AAAAA0000A1Z5',
      city: 'Mumbai',
      address: 'Plot 18, Kalbadevi Wholesale Market',
      rating: 4.8,
      paymentTerms: PaymentTerms.net30,
      leadTimeDays: 2,
      isActive: true,
      totalPurchaseOrders: 48,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Vendor(
      id: 'SUP-002',
      code: 'SUP-002',
      name: 'Global Suppliers & Co.',
      contactPerson: 'Harish Mehta',
      email: 'supply@globalsuppliers.in',
      phone: '+91 98223 45678',
      gstin: '27BBBBB0000B1Z6',
      city: 'Delhi NCR',
      address: 'Warehouse No. 5, Okhla Industrial Area Phase II',
      rating: 4.9,
      paymentTerms: PaymentTerms.net15,
      leadTimeDays: 1,
      isActive: true,
      totalPurchaseOrders: 82,
      createdAt: DateTime.now().subtract(const Duration(days: 280)),
    ),
    Vendor(
      id: 'SUP-003',
      code: 'SUP-003',
      name: 'Tech Corporation Ltd.',
      contactPerson: 'Amitabh Joshi',
      email: 'contact@techcorp.com',
      phone: '+91 98334 56789',
      gstin: '29CCCCC0000C1Z7',
      city: 'Bangalore',
      address: 'Plot 98, Peenya Industrial Complex',
      rating: 4.95,
      paymentTerms: PaymentTerms.advance,
      leadTimeDays: 4,
      isActive: true,
      totalPurchaseOrders: 110,
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
    ),
    Vendor(
      id: 'SUP-004',
      code: 'SUP-004',
      name: 'Toscana Fine Leather Tannery S.p.A.',
      contactPerson: 'Marco Rossi',
      email: 'orders@toscanaleather.it',
      phone: '+39 055 1234567',
      gstin: 'IT-987654321',
      city: 'Florence',
      address: 'Via delle Concerie 14, Santa Croce sull\'Arno',
      rating: 4.9,
      paymentTerms: PaymentTerms.net60,
      leadTimeDays: 14,
      isActive: true,
      totalPurchaseOrders: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    Vendor(
      id: 'SUP-005',
      code: 'SUP-005',
      name: 'Apex Semiconductor & Micro-Tech Corp',
      contactPerson: 'Chen Wei',
      email: 'b2b@apexsemi.tw',
      phone: '+886 2 2345 6789',
      gstin: 'TW-87654321',
      city: 'Hsinchu',
      address: 'Hsinchu Science Park, Innovation Rd',
      rating: 4.95,
      paymentTerms: PaymentTerms.net30,
      leadTimeDays: 7,
      isActive: true,
      totalPurchaseOrders: 65,
      createdAt: DateTime.now().subtract(const Duration(days: 220)),
    ),
  ];

  @override
  List<Vendor> getAll() => List.unmodifiable(_vendors);

  @override
  Vendor? getById(String id) {
    try {
      return _vendors.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void add(Vendor vendor) {
    _vendors.insert(0, vendor);
  }

  @override
  void update(Vendor vendor) {
    final idx = _vendors.indexWhere((v) => v.id == vendor.id);
    if (idx != -1) {
      _vendors[idx] = vendor;
    }
  }

  @override
  void toggleStatus(String id) {
    final idx = _vendors.indexWhere((v) => v.id == id);
    if (idx != -1) {
      final current = _vendors[idx];
      _vendors[idx] = current.copyWith(isActive: !current.isActive);
    }
  }

  @override
  void delete(String id) {
    _vendors.removeWhere((v) => v.id == id);
  }
}
