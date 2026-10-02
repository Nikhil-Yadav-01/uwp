import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../domain/models/vendor.dart';

class VendorState {
  final List<Vendor> vendors;
  final String searchQuery;
  final PaymentTerms? selectedTerms;
  final bool? activeOnly;
  final bool isLoading;

  const VendorState({
    required this.vendors,
    this.searchQuery = '',
    this.selectedTerms,
    this.activeOnly,
    this.isLoading = false,
  });

  List<Vendor> get filteredVendors {
    return vendors.where((v) {
      if (selectedTerms != null && v.paymentTerms != selectedTerms) return false;
      if (activeOnly != null && v.isActive != activeOnly) return false;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchName = v.name.toLowerCase().contains(query);
        final matchCode = v.code.toLowerCase().contains(query);
        final matchContact = v.contactPerson.toLowerCase().contains(query);
        final matchGstin = v.gstin.toLowerCase().contains(query);
        final matchCity = v.city.toLowerCase().contains(query);
        return matchName || matchCode || matchContact || matchGstin || matchCity;
      }
      return true;
    }).toList();
  }

  VendorState copyWith({
    List<Vendor>? vendors,
    String? searchQuery,
    PaymentTerms? selectedTerms,
    bool? activeOnly,
    bool clearTerms = false,
    bool isLoading = false,
  }) {
    return VendorState(
      vendors: vendors ?? this.vendors,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTerms: clearTerms ? null : (selectedTerms ?? this.selectedTerms),
      activeOnly: activeOnly ?? this.activeOnly,
      isLoading: isLoading,
    );
  }
}

class VendorNotifier extends StateNotifier<VendorState> {
  final IVendorRepository _repository;

  VendorNotifier(this._repository)
      : super(VendorState(vendors: _repository.getAll()));

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void filterByTerms(PaymentTerms? terms) {
    if (terms == null) {
      state = state.copyWith(clearTerms: true);
    } else {
      state = state.copyWith(selectedTerms: terms);
    }
  }

  void toggleActiveOnly() {
    final next = state.activeOnly == null ? true : (state.activeOnly! ? false : null);
    state = state.copyWith(activeOnly: next);
  }

  void addVendor({
    required String name,
    required String contactPerson,
    required String email,
    required String phone,
    required String gstin,
    required String city,
    required String address,
    required PaymentTerms paymentTerms,
    required int leadTimeDays,
  }) {
    final nextId = 'SUP-${(state.vendors.length + 1).toString().padLeft(3, '0')}';
    final newVendor = Vendor(
      id: nextId,
      code: nextId,
      name: name,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      gstin: gstin.toUpperCase(),
      city: city,
      address: address,
      paymentTerms: paymentTerms,
      leadTimeDays: leadTimeDays,
      rating: 4.8,
      isActive: true,
      totalPurchaseOrders: 0,
      createdAt: DateTime.now(),
    );
    _repository.add(newVendor);
    state = state.copyWith(vendors: _repository.getAll());
  }

  void updateVendor(Vendor vendor) {
    _repository.update(vendor);
    state = state.copyWith(vendors: _repository.getAll());
  }

  void toggleStatus(String id) {
    _repository.toggleStatus(id);
    state = state.copyWith(vendors: _repository.getAll());
  }

  void deleteVendor(String id) {
    _repository.delete(id);
    state = state.copyWith(vendors: _repository.getAll());
  }
}

final vendorRepositoryProvider = Provider<IVendorRepository>((ref) {
  return InMemoryVendorRepository();
});

final vendorNotifierProvider = StateNotifierProvider<VendorNotifier, VendorState>((ref) {
  final repo = ref.watch(vendorRepositoryProvider);
  return VendorNotifier(repo);
});
