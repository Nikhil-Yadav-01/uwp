import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/vendor.dart';
import '../controllers/vendor_controller.dart';

class VendorFormModal extends ConsumerStatefulWidget {
  final Vendor? vendorToEdit;

  const VendorFormModal({super.key, this.vendorToEdit});

  static Future<void> show(BuildContext context, [Vendor? vendor]) {
    return showDialog(
      context: context,
      builder: (context) => VendorFormModal(vendorToEdit: vendor),
    );
  }

  @override
  ConsumerState<VendorFormModal> createState() => _VendorFormModalState();
}

class _VendorFormModalState extends ConsumerState<VendorFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _contactPersonCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _gstinCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _leadTimeCtrl;
  late PaymentTerms _selectedTerms;

  @override
  void initState() {
    super.initState();
    final v = widget.vendorToEdit;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _contactPersonCtrl = TextEditingController(text: v?.contactPerson ?? '');
    _emailCtrl = TextEditingController(text: v?.email ?? '');
    _phoneCtrl = TextEditingController(text: v?.phone ?? '');
    _gstinCtrl = TextEditingController(text: v?.gstin ?? '');
    _cityCtrl = TextEditingController(text: v?.city ?? '');
    _addressCtrl = TextEditingController(text: v?.address ?? '');
    _leadTimeCtrl = TextEditingController(text: (v?.leadTimeDays ?? 3).toString());
    _selectedTerms = v?.paymentTerms ?? PaymentTerms.net30;
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
    _leadTimeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final leadDays = int.tryParse(_leadTimeCtrl.text.trim()) ?? 3;

    if (widget.vendorToEdit != null) {
      final updated = widget.vendorToEdit!.copyWith(
        name: _nameCtrl.text.trim(),
        contactPerson: _contactPersonCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        gstin: _gstinCtrl.text.trim().toUpperCase(),
        city: _cityCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        paymentTerms: _selectedTerms,
        leadTimeDays: leadDays,
      );
      ref.read(vendorNotifierProvider.notifier).updateVendor(updated);
    } else {
      ref.read(vendorNotifierProvider.notifier).addVendor(
            name: _nameCtrl.text.trim(),
            contactPerson: _contactPersonCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            gstin: _gstinCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            paymentTerms: _selectedTerms,
            leadTimeDays: leadDays,
          );
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.vendorToEdit != null ? 'Vendor updated successfully' : 'Vendor created successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.vendorToEdit != null;

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
                      child: Icon(Icons.storefront_outlined, color: colorScheme.primary, size: 20),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Vendor / Supplier' : 'Add New Vendor / Supplier',
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

                // Vendor Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Vendor / Company Name *',
                    hintText: 'e.g. ABC Traders & Global Imports',
                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter vendor name' : null,
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
                          hintText: 'e.g. Suresh Singhania',
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
                          hintText: 'e.g. sales@abctraders.com',
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
                          hintText: 'e.g. +91 98112 34567',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter phone number' : null,
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // Payment Terms & Lead Time Days
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: DropdownButtonFormField<PaymentTerms>(
                        initialValue: _selectedTerms,
                        decoration: const InputDecoration(
                          labelText: 'Payment Terms',
                          prefixIcon: Icon(Icons.payment_outlined, size: 20),
                        ),
                        items: PaymentTerms.values.map((term) {
                          return DropdownMenuItem(
                            value: term,
                            child: Text(term.label, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTerms = val);
                        },
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _leadTimeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lead Time (Days)',
                          hintText: 'e.g. 3',
                          prefixIcon: Icon(Icons.timer_outlined, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // City & Address
                TextFormField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'City / Region *',
                    hintText: 'e.g. Mumbai',
                    prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter city' : null,
                ),
                AppGap.h12,

                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Factory / Warehouse Dispatch Address',
                    hintText: 'Plot number, industrial area, district...',
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
                      label: Text(isEditing ? 'Save Changes' : 'Create Vendor'),
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
