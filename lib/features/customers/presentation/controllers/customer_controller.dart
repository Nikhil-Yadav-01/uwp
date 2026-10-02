import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/customer_repository.dart';
import '../../domain/models/customer.dart';

class CustomerState {
  final List<Customer> customers;
  final String searchQuery;
  final CustomerTier? selectedTier;
  final bool? activeOnly;
  final bool isLoading;

  const CustomerState({
    required this.customers,
    this.searchQuery = '',
    this.selectedTier,
    this.activeOnly,
    this.isLoading = false,
  });

  List<Customer> get filteredCustomers {
    return customers.where((c) {
      if (selectedTier != null && c.tier != selectedTier) return false;
      if (activeOnly != null && c.isActive != activeOnly) return false;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchName = c.name.toLowerCase().contains(query);
        final matchCode = c.code.toLowerCase().contains(query);
        final matchContact = c.contactPerson.toLowerCase().contains(query);
        final matchGstin = c.gstin.toLowerCase().contains(query);
        final matchCity = c.city.toLowerCase().contains(query);
        return matchName || matchCode || matchContact || matchGstin || matchCity;
      }
      return true;
    }).toList();
  }

  CustomerState copyWith({
    List<Customer>? customers,
    String? searchQuery,
    CustomerTier? selectedTier,
    bool? activeOnly,
    bool clearTier = false,
    bool isLoading = false,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTier: clearTier ? null : (selectedTier ?? this.selectedTier),
      activeOnly: activeOnly ?? this.activeOnly,
      isLoading: isLoading,
    );
  }
}

class CustomerNotifier extends StateNotifier<CustomerState> {
  final ICustomerRepository _repository;

  CustomerNotifier(this._repository)
      : super(CustomerState(customers: _repository.getAll()));

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void filterByTier(CustomerTier? tier) {
    if (tier == null) {
      state = state.copyWith(clearTier: true);
    } else {
      state = state.copyWith(selectedTier: tier);
    }
  }

  void toggleActiveOnly() {
    final next = state.activeOnly == null ? true : (state.activeOnly! ? false : null);
    state = state.copyWith(activeOnly: next);
  }

  void addCustomer({
    required String name,
    required String contactPerson,
    required String email,
    required String phone,
    required String gstin,
    required String city,
    required String address,
    required CustomerTier tier,
  }) {
    final nextId = 'CUST-${(state.customers.length + 1).toString().padLeft(3, '0')}';
    final newCustomer = Customer(
      id: nextId,
      code: nextId,
      name: name,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      gstin: gstin.toUpperCase(),
      city: city,
      address: address,
      tier: tier,
      isActive: true,
      totalOrders: 0,
      outstandingBalance: 0.0,
      createdAt: DateTime.now(),
    );
    _repository.add(newCustomer);
    state = state.copyWith(customers: _repository.getAll());
  }

  void updateCustomer(Customer customer) {
    _repository.update(customer);
    state = state.copyWith(customers: _repository.getAll());
  }

  void toggleStatus(String id) {
    _repository.toggleStatus(id);
    state = state.copyWith(customers: _repository.getAll());
  }

  void deleteCustomer(String id) {
    _repository.delete(id);
    state = state.copyWith(customers: _repository.getAll());
  }
}

final customerRepositoryProvider = Provider<ICustomerRepository>((ref) {
  return InMemoryCustomerRepository();
});

final customerNotifierProvider = StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  return CustomerNotifier(repo);
});
