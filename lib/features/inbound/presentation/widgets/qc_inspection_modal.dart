import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../domain/models/purchase_order.dart';
import '../../domain/models/qc_inspection.dart';
import '../controllers/inbound_controller.dart';

/// Modal dialog for Quality Control inspection gate and dual-witness authorization.
class QcInspectionModal extends ConsumerStatefulWidget {
  final PurchaseOrder purchaseOrder;

  const QcInspectionModal({super.key, required this.purchaseOrder});

  static Future<void> show(BuildContext context, {required PurchaseOrder purchaseOrder}) {
    return ModalShell.show(
      context: context,
      maxWidth: 720,
      child: QcInspectionModal(purchaseOrder: purchaseOrder),
    );
  }

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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isHealthcare = widget.purchaseOrder.archetypeId == 'healthcare_pharma';
    final hasControlledItems = widget.purchaseOrder.items.any(
      (i) => i.customAttributes['isNarcotic'] == true || i.customAttributes['requiresDualSignoff'] == true,
    );
    final requiresDualSignoff = isHealthcare && hasControlledItems;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
                child: Icon(Icons.fact_check_rounded, color: colorScheme.primary, size: AppSizes.iconMd),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quality Inspection Gate',
                      style: AppTypography.headlineSmall.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppGap.h4,
                    Text(
                      'PO: ${widget.purchaseOrder.poNumber} • ${widget.purchaseOrder.vendorName}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),

          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Inspector Details
                  Text(
                    'Inspector Authorization',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppGap.h8,
                  if (isNarrow) ...[
                    TextFormField(
                      controller: _inspectorController,
                      decoration: const InputDecoration(
                        labelText: 'Lead QC Inspector *',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: AppSizes.iconSm),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    if (requiresDualSignoff) ...[
                      AppGap.h12,
                      TextFormField(
                        controller: _witnessController,
                        decoration: const InputDecoration(
                          labelText: 'Secondary Witness (Dual-Signoff) *',
                          prefixIcon: Icon(Icons.verified_user_outlined, size: AppSizes.iconSm),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Secondary witness required for controlled items' : null,
                      ),
                    ],
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _inspectorController,
                            decoration: const InputDecoration(
                              labelText: 'Lead QC Inspector *',
                              prefixIcon: Icon(Icons.person_outline_rounded, size: AppSizes.iconSm),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        if (requiresDualSignoff) ...[
                          AppGap.w12,
                          Expanded(
                            child: TextFormField(
                              controller: _witnessController,
                              decoration: const InputDecoration(
                                labelText: 'Secondary Witness (Dual-Signoff) *',
                                prefixIcon: Icon(Icons.verified_user_outlined, size: AppSizes.iconSm),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Secondary witness required' : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  AppGap.h16,

                  // 2. Regulated Narcotics Warning Banner
                  if (requiresDualSignoff)
                    Container(
                      padding: AppPadding.p12,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.r8),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security_rounded, color: AppColors.error, size: AppSizes.iconMd),
                          AppGap.w12,
                          Expanded(
                            child: Text(
                              'REGULATED CONTROLLED SUBSTANCE GATEWAY: High-potency Schedule II narcotics detected. Physical vault count and dual-witness digital signature mandatory before putaway.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 3. Line Items Inspection
                  Text(
                    'Inspected Line Items',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  AppGap.h8,
                  ...widget.purchaseOrder.items.map((item) {
                    final received = item.receivedQty > 0 ? item.receivedQty : item.orderedQty;
                    final passed = _passedCounts[item.id] ?? received;
                    final rejected = _rejectedCounts[item.id] ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: AppPadding.p12,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppRadii.r8),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                    AppGap.h4,
                                    Text(
                                      'SKU: ${item.sku} • Received: $received ${item.uom}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                                decoration: BoxDecoration(
                                  color: (rejected > 0 ? AppColors.error : AppColors.success).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppRadii.r4),
                                ),
                                child: Text(
                                  rejected > 0 ? 'Discrepancy' : 'Pass 100%',
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: rejected > 0 ? AppColors.error : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppGap.h12,
                          if (isNarrow) ...[
                            TextFormField(
                              initialValue: passed.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Passed Units',
                                isDense: true,
                                prefixIcon: Icon(Icons.check_circle_outline, size: AppSizes.iconSm),
                              ),
                              onChanged: (v) {
                                setState(() {
                                  final p = double.tryParse(v) ?? 0.0;
                                  _passedCounts[item.id] = p;
                                  _rejectedCounts[item.id] = (received - p).clamp(0.0, received);
                                });
                              },
                            ),
                            AppGap.h12,
                            TextFormField(
                              key: ValueKey('rej_${item.id}_${rejected.toStringAsFixed(0)}'),
                              initialValue: rejected.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Rejected / Quarantine Units',
                                isDense: true,
                                prefixIcon: Icon(Icons.cancel_outlined, size: AppSizes.iconSm),
                              ),
                              onChanged: (v) {
                                setState(() {
                                  final r = double.tryParse(v) ?? 0.0;
                                  _rejectedCounts[item.id] = r;
                                  _passedCounts[item.id] = (received - r).clamp(0.0, received);
                                });
                              },
                            ),
                          ] else
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: passed.toStringAsFixed(0),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Passed Units',
                                      isDense: true,
                                      prefixIcon: Icon(Icons.check_circle_outline, size: AppSizes.iconSm),
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
                                AppGap.w12,
                                Expanded(
                                  child: TextFormField(
                                    key: ValueKey('rej_${item.id}_${rejected.toStringAsFixed(0)}'),
                                    initialValue: rejected.toStringAsFixed(0),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Rejected / Quarantine Units',
                                      isDense: true,
                                      prefixIcon: Icon(Icons.cancel_outlined, size: AppSizes.iconSm),
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
                            AppGap.h8,
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Defect / Damage Reason *',
                                isDense: true,
                                prefixIcon: Icon(Icons.warning_amber_rounded, size: AppSizes.iconSm),
                              ),
                              onChanged: (v) => _defectReasons[item.id] = v,
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  AppGap.h16,

                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Overall QC Inspection Summary / Lab Notes',
                      prefixIcon: Icon(Icons.description_outlined, size: AppSizes.iconSm),
                    ),
                  ),

                  if (requiresDualSignoff) ...[
                    AppGap.h12,
                    CheckboxListTile(
                      title: const Text('I attest under regulatory compliance that narcotics counts and vault seals are verified.'),
                      value: _isDualSigned,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _isDualSigned = v ?? false),
                    ),
                  ],
                  AppGap.h16,

                  // Action Buttons
                  if (isNarrow)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _handleAuthorize(theme, requiresDualSignoff),
                          icon: const Icon(Icons.verified_rounded, size: AppSizes.iconSm),
                          label: const Text('Authorize & Sign Off QC'),
                        ),
                        AppGap.h8,
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        AppGap.w12,
                        ElevatedButton.icon(
                          onPressed: () => _handleAuthorize(theme, requiresDualSignoff),
                          icon: const Icon(Icons.verified_rounded, size: AppSizes.iconSm),
                          label: const Text('Authorize & Sign Off QC'),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleAuthorize(ThemeData theme, bool requiresDualSignoff) async {
    if (!_formKey.currentState!.validate()) return;
    if (requiresDualSignoff && !_isDualSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dual-signoff attestation checkbox is required for controlled substances.'),
          backgroundColor: AppColors.error,
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
    if (mounted && success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QC Inspection Submitted: ${qcStatus == QcStatus.passed ? 'PASSED 100%' : 'PASSED WITH DISCREPANCY'}'),
          backgroundColor: theme.colorScheme.primary,
        ),
      );
    }
  }
}
