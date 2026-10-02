import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/return_request.dart';
import '../controllers/returns_controller.dart';

class ReturnFormModal extends ConsumerStatefulWidget {
  const ReturnFormModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ReturnFormModal(),
    );
  }

  @override
  ConsumerState<ReturnFormModal> createState() => _ReturnFormModalState();
}

class _ReturnFormModalState extends ConsumerState<ReturnFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _soCtrl = TextEditingController(text: 'SO-0456');
  final _customerCtrl = TextEditingController(text: 'XYZ Retailers Pvt Ltd');
  final _skuCtrl = TextEditingController(text: 'MOB-SAM-A55');
  final _productCtrl = TextEditingController(text: 'Samsung Galaxy A55 5G');
  final _qtyCtrl = TextEditingController(text: '1');
  final _trackingCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  ReturnReason _selectedReason = ReturnReason.damagedInTransit;

  @override
  void dispose() {
    _soCtrl.dispose();
    _customerCtrl.dispose();
    _skuCtrl.dispose();
    _productCtrl.dispose();
    _qtyCtrl.dispose();
    _trackingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(returnsNotifierProvider.notifier).createReturn(
          salesOrderNumber: _soCtrl.text.trim(),
          customerName: _customerCtrl.text.trim(),
          sku: _skuCtrl.text.trim(),
          productName: _productCtrl.text.trim(),
          quantity: int.tryParse(_qtyCtrl.text.trim()) ?? 1,
          reason: _selectedReason,
          trackingNumber: _trackingCtrl.text.trim().isNotEmpty ? _trackingCtrl.text.trim() : null,
          notes: _notesCtrl.text.trim(),
        );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Return request created successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r16)),
      backgroundColor: colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
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
                      child: Icon(Icons.assignment_return_outlined, color: colorScheme.primary, size: 20),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Text('Create Return / RTO Request', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Order Number & Customer Name
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _soCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Sales Order No. *',
                          hintText: 'e.g. SO-0456',
                          prefixIcon: Icon(Icons.receipt_outlined, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter SO #' : null,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: TextFormField(
                        controller: _customerCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Customer / Account *',
                          hintText: 'e.g. XYZ Retailers',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter Customer' : null,
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // SKU & Product Name
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _skuCtrl,
                        decoration: const InputDecoration(
                          labelText: 'SKU Code *',
                          hintText: 'e.g. MOB-SAM-A55',
                          prefixIcon: Icon(Icons.qr_code, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter SKU' : null,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _productCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Product Name *',
                          hintText: 'e.g. Samsung Galaxy A55',
                          prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter Product Name' : null,
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // Quantity & Return Reason
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Qty *',
                          prefixIcon: Icon(Icons.tag, size: 20),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter qty' : null,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      flex: 7,
                      child: DropdownButtonFormField<ReturnReason>(
                        initialValue: _selectedReason,
                        decoration: const InputDecoration(
                          labelText: 'Return Reason',
                          prefixIcon: Icon(Icons.help_outline_rounded, size: 20),
                        ),
                        items: ReturnReason.values.map((reason) {
                          return DropdownMenuItem(
                            value: reason,
                            child: Text(reason.label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedReason = val);
                        },
                      ),
                    ),
                  ],
                ),
                AppGap.h12,

                // Courier Tracking Number
                TextFormField(
                  controller: _trackingCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Courier RTO / Return Tracking Number',
                    hintText: 'e.g. DTDC-RET-9912',
                    prefixIcon: Icon(Icons.local_shipping_outlined, size: 20),
                  ),
                ),
                AppGap.h12,

                // Notes
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Inspection Notes / Customer Feedback',
                    hintText: 'Describe box condition, damage, or customer reason...',
                    prefixIcon: Icon(Icons.notes_outlined, size: 20),
                  ),
                ),
                AppGap.h24,

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    AppGap.w8,
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create Request'),
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
