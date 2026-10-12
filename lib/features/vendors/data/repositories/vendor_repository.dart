import '../../../../core/data/datasources/sample_data_source.dart';
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

  final List<Vendor> _vendors = [];

  InMemoryVendorRepository._internal() {
    _vendors.addAll(SampleDataSource.getVendors());
  }

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
