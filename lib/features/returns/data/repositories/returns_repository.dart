import '../../../../core/data/datasources/sample_data_source.dart';
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

  final List<ReturnRequest> _returns = [];

  InMemoryReturnsRepository._internal() {
    _returns.addAll(SampleDataSource.getReturns());
  }

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
