import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/features/customers/data/repositories/customer_repository.dart';
import 'package:warehouse/features/customers/domain/models/customer.dart';
import 'package:warehouse/features/customers/presentation/controllers/customer_controller.dart';
import 'package:warehouse/features/vendors/data/repositories/vendor_repository.dart';
import 'package:warehouse/features/vendors/domain/models/vendor.dart';
import 'package:warehouse/features/vendors/presentation/controllers/vendor_controller.dart';

void main() {
  group('Customers Module Tests', () {
    late InMemoryCustomerRepository repo;
    late CustomerNotifier notifier;

    setUp(() {
      repo = InMemoryCustomerRepository();
      notifier = CustomerNotifier(repo);
    });

    test('Loads initial customers correctly', () {
      expect(notifier.state.customers.isNotEmpty, true);
      expect(notifier.state.filteredCustomers.length, notifier.state.customers.length);
    });

    test('Filters customers by search query', () {
      notifier.setSearchQuery('Amazon');
      expect(notifier.state.filteredCustomers.length, 1);
      expect(notifier.state.filteredCustomers.first.name, contains('Amazon'));

      notifier.setSearchQuery('29BBBBB0000B1Z2');
      expect(notifier.state.filteredCustomers.length, 1);
      expect(notifier.state.filteredCustomers.first.gstin, '29BBBBB0000B1Z2');

      notifier.setSearchQuery('');
      expect(notifier.state.filteredCustomers.length, notifier.state.customers.length);
    });

    test('Filters customers by tier', () {
      notifier.filterByTier(CustomerTier.enterprise);
      for (final c in notifier.state.filteredCustomers) {
        expect(c.tier, CustomerTier.enterprise);
      }

      notifier.filterByTier(null);
      expect(notifier.state.filteredCustomers.length, notifier.state.customers.length);
    });

    test('Adds, updates, toggles status, and deletes customer', () {
      final initialCount = notifier.state.customers.length;

      notifier.addCustomer(
        name: 'Test Customer LLC',
        contactPerson: 'Jane Doe',
        email: 'jane@test.com',
        phone: '+1 555 1234',
        gstin: '07TEST0000A1Z1',
        city: 'Delhi',
        address: '123 Main St',
        tier: CustomerTier.retail,
      );

      expect(notifier.state.customers.length, initialCount + 1);
      final created = notifier.state.customers.firstWhere((c) => c.name == 'Test Customer LLC');
      expect(created.isActive, true);

      // Toggle status
      notifier.toggleStatus(created.id);
      final toggled = notifier.state.customers.firstWhere((c) => c.id == created.id);
      expect(toggled.isActive, false);

      // Update
      notifier.updateCustomer(toggled.copyWith(name: 'Updated Test Customer LLC'));
      final updated = notifier.state.customers.firstWhere((c) => c.id == created.id);
      expect(updated.name, 'Updated Test Customer LLC');

      // Delete
      notifier.deleteCustomer(created.id);
      expect(notifier.state.customers.length, initialCount);
    });
  });

  group('Vendors Module Tests', () {
    late InMemoryVendorRepository repo;
    late VendorNotifier notifier;

    setUp(() {
      repo = InMemoryVendorRepository();
      notifier = VendorNotifier(repo);
    });

    test('Loads initial vendors correctly', () {
      expect(notifier.state.vendors.isNotEmpty, true);
      expect(notifier.state.filteredVendors.length, notifier.state.vendors.length);
    });

    test('Filters vendors by search query', () {
      notifier.setSearchQuery('ABC Traders');
      expect(notifier.state.filteredVendors.length, 1);
      expect(notifier.state.filteredVendors.first.name, contains('ABC Traders'));

      notifier.setSearchQuery('27AAAAA0000A1Z5');
      expect(notifier.state.filteredVendors.length, 1);

      notifier.setSearchQuery('');
      expect(notifier.state.filteredVendors.length, notifier.state.vendors.length);
    });

    test('Filters vendors by payment terms', () {
      notifier.filterByTerms(PaymentTerms.net30);
      for (final v in notifier.state.filteredVendors) {
        expect(v.paymentTerms, PaymentTerms.net30);
      }

      notifier.filterByTerms(null);
      expect(notifier.state.filteredVendors.length, notifier.state.vendors.length);
    });

    test('Adds, updates, toggles status, and deletes vendor', () {
      final initialCount = notifier.state.vendors.length;

      notifier.addVendor(
        name: 'New Apex Supplier Inc',
        contactPerson: 'Alex Smith',
        email: 'alex@apexsup.com',
        phone: '+91 99999 88888',
        gstin: '29TEST0000B1Z2',
        city: 'Bangalore',
        address: '456 Tech Park',
        paymentTerms: PaymentTerms.net15,
        leadTimeDays: 5,
      );

      expect(notifier.state.vendors.length, initialCount + 1);
      final created = notifier.state.vendors.firstWhere((v) => v.name == 'New Apex Supplier Inc');
      expect(created.isActive, true);
      expect(created.leadTimeDays, 5);

      // Toggle status
      notifier.toggleStatus(created.id);
      final toggled = notifier.state.vendors.firstWhere((v) => v.id == created.id);
      expect(toggled.isActive, false);

      // Update
      notifier.updateVendor(toggled.copyWith(name: 'Updated Apex Supplier Inc'));
      final updated = notifier.state.vendors.firstWhere((v) => v.id == created.id);
      expect(updated.name, 'Updated Apex Supplier Inc');

      // Delete
      notifier.deleteVendor(created.id);
      expect(notifier.state.vendors.length, initialCount);
    });
  });
}
