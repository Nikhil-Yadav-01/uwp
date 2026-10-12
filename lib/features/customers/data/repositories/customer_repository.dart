import '../../../../core/data/datasources/sample_data_source.dart';
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

  final List<Customer> _customers = [];

  InMemoryCustomerRepository._internal() {
    _customers.addAll(SampleDataSource.getCustomers());
  }

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
