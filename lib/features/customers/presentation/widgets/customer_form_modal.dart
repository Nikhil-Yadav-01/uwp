import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/customer.dart';
import '../controllers/customer_controller.dart';

class CustomerFormModal extends ConsumerStatefulWidget {
  final Customer? customerToEdit;

  const CustomerFormModal({super.key, this.customerToEdit});

  static Future<void> show(BuildContext context, [Customer? customer]) {
    return showDialog(
      context: context,
      builder: (context) => CustomerFormModal(customerToEdit: customer),
    );
  }

  @override
  ConsumerState<CustomerFormModal> createState() => _CustomerFormModalState();
}

class _CustomerFormModalState extends ConsumerState<CustomerFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _contactPersonCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _gstinCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _addressCtrl;
  late CustomerTier _selectedTier;

  @override
  void initState() {
    super.initState();
    final c = widget.customerToEdit;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _contactPersonCtrl = TextEditingController(text: c?.contactPerson ?? '');
    _emailCtrl = TextEditingController(text: c?.email ?? '');
    _phoneCtrl = TextEditingController(text: c?.phone ?? '');
    _gstinCtrl = TextEditingController(text: c?.gstin ?? '');
    _cityCtrl = TextEditingController(text: c?.city ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _selectedTier = c?.tier ?? CustomerTier.enterprise;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactPersonCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _gstinCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.customerToEdit != null) {
      final updated = widget.customerToEdit!.copyWith(
        name: _nameCtrl.text.trim(),
        contactPerson: _contactPersonCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        gstin: _gstinCtrl.text.trim().toUpperCase(),
        city: _cityCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        tier: _selectedTier,
      );
      ref.read(customerNotifierProvider.notifier).updateCustomer(updated);
    } else {
      ref.read(customerNotifierProvider.notifier).addCustomer(
            name: _nameCtrl.text.trim(),
            contactPerson: _contactPersonCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            gstin: _gstinCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            tier: _selectedTier,
          );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.customerToEdit != null ? 'Customer updated successfully' : 'Customer created successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.customerToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r16)),
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: AppPadding.p24,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadii.r8),
                      ),
                      child: Icon(Icons.person_add_alt_1_rounded, color: colorScheme.primary, size: 20),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Customer' : 'Add New Customer',
                        style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Customer Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company / Customer Name *',
                    hintText: 'e.g. XYZ Retailers Pvt Ltd',
                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter customer name' : null,
                ),
                AppGap.h12,

                // Contact Person & GSTIN
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactPersonCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person *',
                          hintText: 'e.g. Karan Mehra',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter contact person' : null,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: TextFormField(
                        controller: _gstinCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'GSTIN / Tax ID *',
                          hintText: 'e.g. 27AAAAA0000A1Z5',
                          prefixIcon: Icon(Icons.receipt_outlined, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter GSTIN' : null,
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // Email & Phone
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'e.g. info@company.com',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter email';
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          hintText: 'e.g. +91 98112 23344',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter phone number' : null,
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // Customer Tier & City
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CustomerTier>(
                        initialValue: _selectedTier,
                        decoration: const InputDecoration(
                          labelText: 'Customer Tier',
                          prefixIcon: Icon(Icons.stars_outlined, size: 20),
                        ),
                        items: CustomerTier.values.map((tier) {
                          return DropdownMenuItem(
                            value: tier,
                            child: Text(tier.label, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTier = val);
                        },
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: TextFormField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(
                          labelText: 'City / Region *',
                          hintText: 'e.g. Mumbai',
                          prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter city' : null,
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // Address
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Full Billing & Shipping Address',
                    hintText: 'Street address, building, postal code...',
                    prefixIcon: Icon(Icons.pin_drop_outlined, size: 20),
                  ),
                ),
                AppGap.h24,

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    AppGap.w8,
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(isEditing ? Icons.check_rounded : Icons.add_rounded, size: 18),
                      label: Text(isEditing ? 'Save Changes' : 'Create Customer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
