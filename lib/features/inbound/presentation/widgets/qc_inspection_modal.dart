import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/purchase_order.dart';
import '../../domain/models/qc_inspection.dart';
import '../controllers/inbound_controller.dart';

class QcInspectionModal extends ConsumerStatefulWidget {
  final PurchaseOrder purchaseOrder;

  const QcInspectionModal({super.key, required this.purchaseOrder});

  @override
  ConsumerState<QcInspectionModal> createState() => _QcInspectionModalState();
}

class _QcInspectionModalState extends ConsumerState<QcInspectionModal> {
  final _formKey = GlobalKey<FormState>();
  final _inspectorController = TextEditingController(text: 'Inspector Alex Vance');
  final _witnessController = TextEditingController();
  final _notesController = TextEditingController();

  late Map<String, double> _passedCounts;
  late Map<String, double> _rejectedCounts;
  late Map<String, String?> _defectReasons;
  bool _isDualSigned = false;

  @override
  void initState() {
    super.initState();
    _passedCounts = {
      for (final item in widget.purchaseOrder.items)
        item.id: item.receivedQty > 0 ? item.receivedQty : item.orderedQty,
    };
    _rejectedCounts = {
      for (final item in widget.purchaseOrder.items) item.id: 0.0,
    };
    _defectReasons = {
      for (final item in widget.purchaseOrder.items) item.id: null,
    };
  }

  @override
  void dispose() {
    _inspectorController.dispose();
    _witnessController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHealthcare = widget.purchaseOrder.archetypeId == 'healthcare_pharma';
    final hasControlledItems = widget.purchaseOrder.items.any(
      (i) => i.customAttributes['isNarcotic'] == true || i.customAttributes['requiresDualSignoff'] == true,
    );
    final requiresDualSignoff = isHealthcare && hasControlledItems;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 720,
        constraints: const BoxConstraints(maxHeight: 760),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.fact_check_rounded, color: theme.colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quality Inspection Gate', style: AppTypography.h2),
                          Text(
                            'PO: ${widget.purchaseOrder.poNumber} • ${widget.purchaseOrder.vendorName}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Inspector details
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _inspectorController,
                              decoration: const InputDecoration(
                                labelText: 'Lead QC Inspector *',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          if (requiresDualSignoff) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _witnessController,
                                decoration: const InputDecoration(
                                  labelText: 'Secondary Witness (Dual-Signoff) *',
                                  prefixIcon: Icon(Icons.verified_user_outlined),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Secondary witness required for Schedule II items' : null,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Regulated Narcotics Warning Banner
                      if (requiresDualSignoff)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.security_rounded, color: theme.colorScheme.error, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'REGULATED CONTROLLED SUBSTANCE GATEWAY: High-potency Schedule II narcotics detected. Physical vault count and dual-witness digital signature mandatory before putaway.',
                                  style: AppTypography.captionBold.copyWith(color: theme.colorScheme.onErrorContainer),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Text('Inspected Line Items', style: AppTypography.bodyBold),
                      const SizedBox(height: 8),

                      // Line item inspection cards
                      ...widget.purchaseOrder.items.map((item) {
                        final received = item.receivedQty > 0 ? item.receivedQty : item.orderedQty;
                        final passed = _passedCounts[item.id] ?? received;
                        final rejected = _rejectedCounts[item.id] ?? 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: AppTypography.bodyBold),
                                      Text('SKU: ${item.sku} • Received: $received ${item.uom}', style: AppTypography.caption),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: rejected > 0
                                          ? theme.colorScheme.error.withValues(alpha: 0.15)
                                          : theme.colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      rejected > 0 ? 'Discrepancy' : 'Pass 100%',
                                      style: AppTypography.captionBold.copyWith(
                                        color: rejected > 0 ? theme.colorScheme.error : theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: passed.toStringAsFixed(0),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Passed Units',
                                        isDense: true,
                                        prefixIcon: Icon(Icons.check_circle_outline, size: 18),
                                      ),
                                      onChanged: (v) {
                                        setState(() {
                                          final p = double.tryParse(v) ?? 0.0;
                                          _passedCounts[item.id] = p;
                                          _rejectedCounts[item.id] = (received - p).clamp(0.0, received);
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey('rej_${item.id}_${rejected.toStringAsFixed(0)}'),
                                      initialValue: rejected.toStringAsFixed(0),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Rejected / Quarantine',
                                        isDense: true,
                                        prefixIcon: Icon(Icons.cancel_outlined, size: 18),
                                      ),
                                      onChanged: (v) {
                                        setState(() {
                                          final r = double.tryParse(v) ?? 0.0;
                                          _rejectedCounts[item.id] = r;
                                          _passedCounts[item.id] = (received - r).clamp(0.0, received);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              if (rejected > 0) ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Defect / Damage Reason *',
                                    isDense: true,
                                    prefixIcon: Icon(Icons.warning_amber_rounded, size: 18),
                                  ),
                                  onChanged: (v) => _defectReasons[item.id] = v,
                                ),
                              ],
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Overall QC Inspection Summary / Lab Notes',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                      ),

                      if (requiresDualSignoff) ...[
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text('I attest under regulatory compliance that narcotics counts and vault seals are verified.'),
                          value: _isDualSigned,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setState(() => _isDualSigned = v ?? false),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),
              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      if (requiresDualSignoff && !_isDualSigned) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Dual-signoff attestation checkbox is required for controlled substances.'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }

                      final itemResults = widget.purchaseOrder.items.map((item) {
                        final passed = _passedCounts[item.id] ?? item.orderedQty;
                        final rejected = _rejectedCounts[item.id] ?? 0.0;
                        return QcItemResult(
                          productId: item.productId,
                          productName: item.productName,
                          sku: item.sku,
                          inspectedQty: item.receivedQty > 0 ? item.receivedQty : item.orderedQty,
                          passedQty: passed,
                          rejectedQty: rejected,
                          defectReason: _defectReasons[item.id],
                          disposition: rejected > 0 ? DefectDisposition.quarantineHold : DefectDisposition.acceptWithDiscount,
                        );
                      }).toList();

                      final hasRejections = itemResults.any((r) => r.rejectedQty > 0);
                      final qcStatus = hasRejections ? QcStatus.passedWithDiscrepancy : QcStatus.passed;

                      final report = QcInspectionReport(
                        id: 'QC-${DateTime.now().millisecondsSinceEpoch}',
                        poId: widget.purchaseOrder.id,
                        poNumber: widget.purchaseOrder.poNumber,
                        inspectorName: _inspectorController.text.trim(),
                        witnessName: _witnessController.text.trim().isNotEmpty ? _witnessController.text.trim() : null,
                        inspectionDate: DateTime.now(),
                        status: qcStatus,
                        requiresDualSignoff: requiresDualSignoff,
                        isDualSigned: _isDualSigned,
                        overallNotes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
                        itemResults: itemResults,
                      );

                      final success = await ref.read(inboundNotifierProvider.notifier).submitQcInspection(report);
                      if (context.mounted && success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('QC Inspection Submitted: ${qcStatus == QcStatus.passed ? 'PASSED 100%' : 'PASSED WITH DISCREPANCY'}'),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.verified_rounded, size: 18),
                    label: const Text('Authorize & Sign Off QC'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
