import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/purchase_order.dart';
import '../controllers/inbound_controller.dart';
import 'po_form_modal.dart';
import 'qc_inspection_modal.dart';

/// Modal dialog for viewing complete Purchase Order details, line items, and lifecycle actions.
class PoDetailModal extends ConsumerWidget {
  final PurchaseOrder purchaseOrder;

  const PoDetailModal({super.key, required this.purchaseOrder});

  static Future<void> show(BuildContext context, {required PurchaseOrder purchaseOrder}) {
    return ModalShell.show(
      context: context,
      maxWidth: 720,
      child: PoDetailModal(purchaseOrder: purchaseOrder),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;

    // Get live PO data from state if available
    final inboundState = ref.watch(inboundNotifierProvider);
    final po = inboundState.purchaseOrders.firstWhere(
      (p) => p.id == purchaseOrder.id,
      orElse: () => purchaseOrder,
    );

    final canDockReceive = po.status == InboundStatus.inTransit || po.status == InboundStatus.approved;
    final canQcInspect = po.status == InboundStatus.atDock || po.status == InboundStatus.qcPending;
    final canEdit = po.status == InboundStatus.draft || po.status == InboundStatus.approved;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Bar
            _buildHeader(context, po, isDark, colorScheme, archetype),
            const Divider(height: AppSpacing.lg),

            // 2. 4-Metric KPI Grid
            _buildMetricGrid(context, po, isDark, colorScheme, isNarrow),
            AppGap.h16,

            // 3. Lifecycle Progress Stepper
            _buildPipelineStepper(context, po, isDark, colorScheme),
            AppGap.h16,

            // 4. Supplier & Logistics Card
            _buildSupplierCard(context, po, isDark, colorScheme),
            AppGap.h16,

            // 5. Line Items Breakdown
            _buildLineItemsSection(context, po, isDark, colorScheme),
            AppGap.h20,

            // 6. Action Footer Bar
            _buildActionFooter(
              context,
              ref,
              po,
              canEdit,
              canDockReceive,
              canQcInspect,
              isNarrow,
              colorScheme,
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(
    BuildContext context,
    PurchaseOrder po,
    bool isDark,
    ColorScheme colorScheme,
    dynamic archetype,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs + 2),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadii.r8),
          ),
          child: Icon(Icons.receipt_long_rounded, color: colorScheme.primary, size: AppSizes.iconMd),
        ),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  Text(
                    po.poNumber,
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(po.status, colorScheme),
                ],
              ),
              AppGap.h4,
              Text(
                'Supplier: ${po.vendorName} • Created ${po.orderDate.toString().substring(0, 10)}',
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
    );
  }

  // ---------------------------------------------------------------------------
  // 4-METRIC KPI GRID
  // ---------------------------------------------------------------------------
  Widget _buildMetricGrid(
    BuildContext context,
    PurchaseOrder po,
    bool isDark,
    ColorScheme colorScheme,
    bool isNarrow,
  ) {
    final expectedDate = po.expectedDeliveryDate != null
        ? po.expectedDeliveryDate!.toString().substring(0, 10)
        : 'Not Set';

    final items = [
      {
        'label': 'TOTAL VALUE',
        'value': '\$${po.totalAmount.toStringAsFixed(2)}',
        'icon': Icons.attach_money_rounded,
        'color': colorScheme.primary,
      },
      {
        'label': 'TOTAL UNITS',
        'value': '${po.totalOrderedUnits.toStringAsFixed(0)} units',
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.info,
      },
      {
        'label': 'RECEIVED',
        'value': '${po.totalReceivedUnits.toStringAsFixed(0)} units',
        'icon': Icons.input_rounded,
        'color': po.isFullyReceived ? AppColors.success : AppColors.warning,
      },
      {
        'label': 'EXPECTED DATE',
        'value': expectedDate,
        'icon': Icons.calendar_today_outlined,
        'color': isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      },
    ];

    if (isNarrow) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricTile(items[0], isDark, colorScheme)),
              AppGap.w8,
              Expanded(child: _buildMetricTile(items[1], isDark, colorScheme)),
            ],
          ),
          AppGap.h8,
          Row(
            children: [
              Expanded(child: _buildMetricTile(items[2], isDark, colorScheme)),
              AppGap.w8,
              Expanded(child: _buildMetricTile(items[3], isDark, colorScheme)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: _buildMetricTile(item, isDark, colorScheme),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricTile(Map<String, dynamic> item, bool isDark, ColorScheme colorScheme) {
    final color = item['color'] as Color;

    return Container(
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
                child: Text(
                  item['label'] as String,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(item['icon'] as IconData, size: AppSizes.iconSm - 2, color: color),
            ],
          ),
          AppGap.h4,
          Text(
            item['value'] as String,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PIPELINE STEPPER
  // ---------------------------------------------------------------------------
  Widget _buildPipelineStepper(
    BuildContext context,
    PurchaseOrder po,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    int currentStep;
    switch (po.status) {
      case InboundStatus.draft:
        currentStep = 0;
        break;
      case InboundStatus.approved:
      case InboundStatus.inTransit:
        currentStep = 1;
        break;
      case InboundStatus.atDock:
      case InboundStatus.receiving:
        currentStep = 2;
        break;
      case InboundStatus.qcPending:
      case InboundStatus.qcPassed:
      case InboundStatus.qcFailed:
        currentStep = 3;
        break;
      case InboundStatus.putawayReady:
        currentStep = 4;
        break;
      case InboundStatus.completed:
        currentStep = 5;
        break;
      case InboundStatus.cancelled:
        currentStep = -1;
        break;
    }

    final steps = ['Draft', 'Approved', 'Dock Intake', 'QC Gate', 'Putaway', 'Complete'];

    return Container(
      padding: AppPadding.p12,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: AppSizes.iconSm, color: colorScheme.primary),
              AppGap.w8,
              Text(
                'Inbound Pipeline Progress',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppGap.h12,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(steps.length, (index) {
                final isPassed = currentStep >= index;
                final isCurrent = currentStep == index;

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? colorScheme.primary.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                        border: Border.all(
                          color: isPassed ? colorScheme.primary : colorScheme.outline,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPassed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 12,
                            color: isPassed ? colorScheme.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                          AppGap.w4,
                          Text(
                            steps[index],
                            style: AppTypography.labelSmall.copyWith(
                              color: isPassed ? colorScheme.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              fontWeight: isPassed ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < steps.length - 1) ...[
                      Container(
                        width: 12,
                        height: 1,
                        color: isPassed ? colorScheme.primary : colorScheme.outline,
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUPPLIER & LOGISTICS CARD
  // ---------------------------------------------------------------------------
  Widget _buildSupplierCard(
    BuildContext context,
    PurchaseOrder po,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
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
            children: [
              Icon(Icons.local_shipping_outlined, size: AppSizes.iconSm, color: colorScheme.primary),
              AppGap.w8,
              Text(
                'Logistics & Supplier Information',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppGap.h8,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Vendor: ${po.vendorName}',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              if (po.vendorEmail != null)
                Text(
                  'Email: ${po.vendorEmail}',
                  style: AppTypography.bodySmall,
                ),
              Text(
                'Dock Bay: ${po.receivingDockId ?? "Dock Staging Bay 01"}',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          if (po.notes != null && po.notes!.isNotEmpty) ...[
            AppGap.h8,
            Text(
              'Notes: ${po.notes}',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LINE ITEMS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildLineItemsSection(
    BuildContext context,
    PurchaseOrder po,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Line Items (${po.items.length})',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        AppGap.h8,
        ...po.items.map((item) {
          final progress = item.orderedQty > 0 ? (item.receivedQty / item.orderedQty).clamp(0.0, 1.0) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
            padding: AppPadding.p12,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          AppGap.h4,
                          Text(
                            'SKU: ${item.sku} • UOM: ${item.uom}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGap.w8,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          '\$${item.unitPrice.toStringAsFixed(2)} / ${item.uom}',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AppGap.h8,
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item.isFullyReceived ? AppColors.success : colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    AppGap.w8,
                    Text(
                      '${item.receivedQty.toStringAsFixed(0)} / ${item.orderedQty.toStringAsFixed(0)} ${item.uom}',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: item.isFullyReceived ? AppColors.success : colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (item.customAttributes.isNotEmpty) ...[
                  AppGap.h8,
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    children: item.customAttributes.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: AppTypography.labelSmall.copyWith(fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildActionFooter(
    BuildContext context,
    WidgetRef ref,
    PurchaseOrder po,
    bool canEdit,
    bool canDockReceive,
    bool canQcInspect,
    bool isNarrow,
    ColorScheme colorScheme,
  ) {
    final editButton = OutlinedButton.icon(
      onPressed: canEdit
          ? () {
              Navigator.of(context).pop();
              PoFormModal.show(context, purchaseOrder: po);
            }
          : null,
      icon: const Icon(Icons.edit_rounded, size: AppSizes.iconSm),
      label: const Text('Edit PO'),
    );

    final dockReceiveButton = ElevatedButton.icon(
      onPressed: () async {
        Navigator.of(context).pop();
        final updatedItems = po.items.map((i) => i.copyWith(receivedQty: i.orderedQty)).toList();
        await ref.read(inboundNotifierProvider.notifier).receiveDockGoods(
          poId: po.id,
          receivedItems: updatedItems,
          dockId: po.receivingDockId ?? 'Dock Staging Bay 01',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('GRN Intake complete for ${po.poNumber}'),
              backgroundColor: colorScheme.primary,
            ),
          );
        }
      },
      icon: const Icon(Icons.input_rounded, size: AppSizes.iconSm),
      label: const Text('Dock Receive'),
    );

    final qcGateButton = ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        QcInspectionModal.show(context, purchaseOrder: po);
      },
      icon: const Icon(Icons.fact_check_rounded, size: AppSizes.iconSm),
      label: const Text('Open QC Gate'),
    );

    final closeButton = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Close'),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canDockReceive) ...[
            dockReceiveButton,
            AppGap.h8,
          ] else if (canQcInspect) ...[
            qcGateButton,
            AppGap.h8,
          ],
          Row(
            children: [
              if (canEdit) ...[
                Expanded(child: editButton),
                AppGap.w8,
              ],
              Expanded(child: closeButton),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canEdit) editButton else const SizedBox.shrink(),
        Row(
          children: [
            closeButton,
            AppGap.w8,
            if (canDockReceive) dockReceiveButton,
            if (canQcInspect && !canDockReceive) qcGateButton,
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(InboundStatus status, ColorScheme colorScheme) {
    Color bg;
    Color fg;

    switch (status) {
      case InboundStatus.draft:
      case InboundStatus.inTransit:
        bg = AppColors.info.withValues(alpha: 0.15);
        fg = AppColors.info;
        break;
      case InboundStatus.approved:
      case InboundStatus.atDock:
      case InboundStatus.receiving:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        break;
      case InboundStatus.qcPending:
        bg = colorScheme.primary.withValues(alpha: 0.15);
        fg = colorScheme.primary;
        break;
      case InboundStatus.qcPassed:
      case InboundStatus.putawayReady:
      case InboundStatus.completed:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
      case InboundStatus.qcFailed:
      case InboundStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.r4)),
      child: Text(
        status.label,
        style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
