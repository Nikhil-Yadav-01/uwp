import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/sales_order.dart';
import '../controllers/outbound_controller.dart';
import 'so_form_modal.dart';

/// Modal dialog for inspecting Sales Order details, line items, and fulfillment actions.
class SoDetailModal extends ConsumerWidget {
  final SalesOrder salesOrder;
  final void Function(int tabIndex)? onNavigateStage;

  const SoDetailModal({
    super.key,
    required this.salesOrder,
    this.onNavigateStage,
  });

  static Future<void> show(
    BuildContext context, {
    required SalesOrder salesOrder,
    void Function(int tabIndex)? onNavigateStage,
  }) {
    return ModalShell.show(
      context: context,
      maxWidth: 720,
      child: SoDetailModal(
        salesOrder: salesOrder,
        onNavigateStage: onNavigateStage,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;

    final outboundState = ref.watch(outboundNotifierProvider);
    final order = outboundState.salesOrders.firstWhere(
      (o) => o.id == salesOrder.id,
      orElse: () => salesOrder,
    );

    final isEmergency = order.priority == OrderPriority.emergencyCrashCart;
    final isRush = order.priority == OrderPriority.rush;
    final canEdit = order.status == OutboundStatus.pending || order.status == OutboundStatus.allocated;
    final canPack = order.status == OutboundStatus.picked || order.status == OutboundStatus.packing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header Bar
            _buildHeader(context, order, isEmergency, isRush, isDark, colorScheme, archetype),
            const Divider(height: AppSpacing.lg),

            // 2. 4-Metric KPI Grid
            _buildMetricGrid(context, order, isDark, colorScheme, isNarrow),
            AppGap.h16,

            // 3. Fulfillment Progress Stepper
            _buildFulfillmentStepper(context, order, isDark, colorScheme),
            AppGap.h16,

            // 4. Recipient & Destination Details Card
            _buildDestinationCard(context, order, isDark, colorScheme),
            AppGap.h16,

            // 5. Line Items Breakdown
            _buildLineItemsSection(context, order, isDark, colorScheme),
            AppGap.h20,

            // 6. Action Footer Bar
            _buildActionFooter(
              context,
              ref,
              order,
              canEdit,
              canPack,
              isNarrow,
              colorScheme,
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1. HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(
    BuildContext context,
    SalesOrder order,
    bool isEmergency,
    bool isRush,
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
            color: isEmergency
                ? colorScheme.error.withValues(alpha: 0.15)
                : colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadii.r8),
          ),
          child: Icon(
            isEmergency ? Icons.emergency_rounded : Icons.outbox_rounded,
            color: isEmergency ? colorScheme.error : colorScheme.primary,
            size: AppSizes.iconMd,
          ),
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
                    order.soNumber,
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: order.soNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied ${order.soNumber} to clipboard'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(Icons.copy_rounded, size: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                  _buildPriorityBadge(order.priority, colorScheme),
                  _buildStatusChip(order.status, colorScheme),
                ],
              ),
              AppGap.h4,
              Text(
                'Customer: ${order.customerName} • Ordered ${order.orderDate.toString().substring(0, 10)}',
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
  // 2. 4-METRIC KPI GRID
  // ---------------------------------------------------------------------------
  Widget _buildMetricGrid(
    BuildContext context,
    SalesOrder order,
    bool isDark,
    ColorScheme colorScheme,
    bool isNarrow,
  ) {
    final items = [
      {
        'label': 'TOTAL ORDER VALUE',
        'value': '\$${order.totalAmount.toStringAsFixed(2)}',
        'icon': Icons.attach_money_rounded,
        'color': colorScheme.primary,
      },
      {
        'label': 'REQUESTED UNITS',
        'value': '${order.totalRequestedUnits.toStringAsFixed(0)} units',
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.info,
      },
      {
        'label': 'DESTINATION TYPE',
        'value': order.customerType.name.toUpperCase(),
        'icon': Icons.domain_outlined,
        'color': colorScheme.secondary,
      },
      {
        'label': 'PRIORITY',
        'value': order.priority.name.toUpperCase(),
        'icon': Icons.bolt_rounded,
        'color': order.priority == OrderPriority.emergencyCrashCart ? AppColors.error : AppColors.warning,
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
                    fontSize: 9,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(item['icon'] as IconData, size: 14, color: color),
            ],
          ),
          AppGap.h4,
          Text(
            item['value'] as String,
            style: AppTypography.bodyMedium.copyWith(
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
  // 3. FULFILLMENT STEPPER
  // ---------------------------------------------------------------------------
  Widget _buildFulfillmentStepper(
    BuildContext context,
    SalesOrder order,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    int currentStep;
    switch (order.status) {
      case OutboundStatus.pending:
        currentStep = 0;
        break;
      case OutboundStatus.allocated:
      case OutboundStatus.waveAssigned:
      case OutboundStatus.picking:
        currentStep = 1;
        break;
      case OutboundStatus.picked:
        currentStep = 2;
        break;
      case OutboundStatus.packing:
      case OutboundStatus.packed:
        currentStep = 3;
        break;
      case OutboundStatus.shipped:
      case OutboundStatus.delivered:
        currentStep = 4;
        break;
      case OutboundStatus.cancelled:
        currentStep = -1;
        break;
    }

    final steps = ['Backlog', 'Allocated', 'Picked', 'Packing', 'Shipped'];

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
                'Outbound Fulfillment Lifecycle',
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
  // 4. RECIPIENT & DESTINATION CARD
  // ---------------------------------------------------------------------------
  Widget _buildDestinationCard(
    BuildContext context,
    SalesOrder order,
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
              Icon(Icons.location_on_outlined, size: AppSizes.iconSm, color: colorScheme.primary),
              AppGap.w8,
              Text(
                'Recipient & Delivery Station',
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
                'Customer: ${order.customerName}',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Delivery Station / Ward: ${order.destinationWardOrAddress}',
                style: AppTypography.bodySmall,
              ),
              Text(
                'Type: ${order.customerType.name.toUpperCase()}',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            AppGap.h8,
            Text(
              'Handling Notes: ${order.notes}',
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
  // 5. LINE ITEMS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildLineItemsSection(
    BuildContext context,
    SalesOrder order,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordered Line Items (${order.items.length})',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        AppGap.h8,
        ...order.items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
            padding: AppPadding.p12,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
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
                        'SKU: ${item.sku} • Quantity: ${item.requestedQty.toStringAsFixed(0)} ${item.uom}',
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
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. ACTION FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildActionFooter(
    BuildContext context,
    WidgetRef ref,
    SalesOrder order,
    bool canEdit,
    bool canPack,
    bool isNarrow,
    ColorScheme colorScheme,
  ) {
    final editButton = OutlinedButton.icon(
      onPressed: canEdit
          ? () {
              Navigator.of(context).pop();
              SoFormModal.show(context, salesOrder: order);
            }
          : null,
      icon: const Icon(Icons.edit_rounded, size: AppSizes.iconSm),
      label: const Text('Edit Order'),
    );

    final packButton = ElevatedButton.icon(
      onPressed: () async {
        Navigator.of(context).pop();
        await ref.read(outboundNotifierProvider.notifier).startPacking(order.id);
        onNavigateStage?.call(2); // Jump to Packing Station stage
      },
      icon: const Icon(Icons.qr_code_scanner_rounded, size: AppSizes.iconSm),
      label: const Text('Start Packing Session'),
    );

    final closeButton = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Close'),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canPack) ...[
            packButton,
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
            if (canPack) ...[
              AppGap.w8,
              packButton,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(OrderPriority priority, ColorScheme colorScheme) {
    Color bg;
    Color fg;
    String label;

    switch (priority) {
      case OrderPriority.emergencyCrashCart:
        bg = colorScheme.error;
        fg = colorScheme.onError;
        label = 'EMERGENCY CRASH CART';
        break;
      case OrderPriority.rush:
        bg = AppColors.warning;
        fg = Colors.white;
        label = 'RUSH';
        break;
      case OrderPriority.standard:
        bg = colorScheme.outline.withValues(alpha: 0.2);
        fg = colorScheme.onSurface;
        label = 'STANDARD';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.r4)),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 9),
      ),
    );
  }

  Widget _buildStatusChip(OutboundStatus status, ColorScheme colorScheme) {
    Color bg;
    Color fg;

    switch (status) {
      case OutboundStatus.pending:
      case OutboundStatus.allocated:
        bg = AppColors.info.withValues(alpha: 0.15);
        fg = AppColors.info;
        break;
      case OutboundStatus.waveAssigned:
      case OutboundStatus.picking:
        bg = colorScheme.primary.withValues(alpha: 0.15);
        fg = colorScheme.primary;
        break;
      case OutboundStatus.picked:
      case OutboundStatus.packing:
      case OutboundStatus.packed:
        bg = AppColors.warning.withValues(alpha: 0.15);
        fg = AppColors.warning;
        break;
      case OutboundStatus.shipped:
      case OutboundStatus.delivered:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
      case OutboundStatus.cancelled:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.r4)),
      child: Text(
        status.name.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
