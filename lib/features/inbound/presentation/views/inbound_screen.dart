import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/purchase_order.dart';
import '../../domain/models/putaway_task.dart';
import '../controllers/inbound_controller.dart';
import '../widgets/po_form_modal.dart';
import '../widgets/qc_inspection_modal.dart';
import '../widgets/putaway_confirm_modal.dart';

class InboundScreen extends ConsumerStatefulWidget {
  const InboundScreen({super.key});

  @override
  ConsumerState<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends ConsumerState<InboundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;
    final inboundState = ref.watch(inboundNotifierProvider);
    final pos = inboundState.purchaseOrders;
    final putawayTasks = inboundState.putawayTasks;

    final pendingPoCount = pos.where((p) => p.status == InboundStatus.draft || p.status == InboundStatus.approved || p.status == InboundStatus.inTransit).length;
    final dockCount = pos.where((p) => p.status == InboundStatus.atDock || p.status == InboundStatus.receiving).length;
    final qcCount = pos.where((p) => p.status == InboundStatus.qcPending).length;
    final putawayCount = putawayTasks.where((t) => t.status == PutawayStatus.pending).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Inbound Receiving & POs', style: AppTypography.h1),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: archetype.brandColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: archetype.brandColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            archetype.name,
                            style: AppTypography.captionBold.copyWith(color: archetype.brandColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dock intake, QC inspection gate & directed putaway for ${archetype.name}',
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const PoFormModal(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('New Purchase Order'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Inbound KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;
                final cards = [
                  {
                    'title': '1. PO Pipeline',
                    'count': '$pendingPoCount Orders',
                    'icon': Icons.description_outlined,
                    'color': AppColors.info,
                    'tabIndex': 0,
                  },
                  {
                    'title': '2. Dock Receiving',
                    'count': '$dockCount Shipments',
                    'icon': Icons.local_shipping_outlined,
                    'color': AppColors.warning,
                    'tabIndex': 1,
                  },
                  {
                    'title': '3. QC Inspection',
                    'count': '$qcCount Batches',
                    'icon': Icons.fact_check_outlined,
                    'color': archetype.brandColor,
                    'tabIndex': 2,
                  },
                  {
                    'title': '4. Directed Putaway',
                    'count': '$putawayCount Tasks',
                    'icon': Icons.move_to_inbox_outlined,
                    'color': AppColors.success,
                    'tabIndex': 3,
                  },
                ];

                if (isNarrow) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: cards.map((c) => SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: _buildKpiCard(context, c, isDark),
                    )).toList(),
                  );
                }

                return Row(
                  children: cards.map((c) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: _buildKpiCard(context, c, isDark),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tab Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                tabs: const [
                  Tab(icon: Icon(Icons.list_alt_rounded), text: 'Purchase Orders'),
                  Tab(icon: Icon(Icons.dock_rounded), text: 'Dock Receiving (GRN)'),
                  Tab(icon: Icon(Icons.verified_user_outlined), text: 'QC Inspection Gate'),
                  Tab(icon: Icon(Icons.grid_view_rounded), text: 'Directed Putaway'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tab Views Container
            SizedBox(
              height: 580,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPoListView(context, pos, isDark, theme),
                  _buildDockReceivingView(context, pos, isDark, theme),
                  _buildQcGateView(context, pos, isDark, theme),
                  _buildPutawayView(context, putawayTasks, isDark, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, Map<String, dynamic> data, bool isDark) {
    final theme = Theme.of(context);
    final color = data['color'] as Color;

    return InkWell(
      onTap: () => _tabController.animateTo(data['tabIndex'] as int),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(data['icon'] as IconData, size: 22, color: color),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(data['count'] as String, style: AppTypography.h2),
            const SizedBox(height: 2),
            Text(
              data['title'] as String,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Purchase Orders List
  Widget _buildPoListView(BuildContext context, List<PurchaseOrder> pos, bool isDark, ThemeData theme) {
    if (pos.isEmpty) {
      return Center(child: Text('No Purchase Orders found.', style: AppTypography.body));
    }

    return ListView.builder(
      itemCount: pos.length,
      itemBuilder: (context, index) {
        final po = pos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(po.poNumber, style: AppTypography.h3),
                        const SizedBox(width: 8),
                        _buildStatusChip(po.status, theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${po.vendorName} • ${po.items.length} items (${po.totalOrderedUnits.toStringAsFixed(0)} units) • \$${po.totalAmount.toStringAsFixed(2)}',
                      style: AppTypography.caption,
                    ),
                    if (po.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${po.notes}',
                        style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (po.status == InboundStatus.inTransit || po.status == InboundStatus.approved)
                ElevatedButton.icon(
                  onPressed: () async {
                    final updatedItems = po.items.map((i) => i.copyWith(receivedQty: i.orderedQty)).toList();
                    await ref.read(inboundNotifierProvider.notifier).receiveDockGoods(
                      poId: po.id,
                      receivedItems: updatedItems,
                      dockId: 'Dock Staging Bay 01',
                    );
                    _tabController.animateTo(2); // Jump to QC
                  },
                  icon: const Icon(Icons.input_rounded, size: 16),
                  label: const Text('Dock Receive'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 2. Dock Receiving View
  Widget _buildDockReceivingView(BuildContext context, List<PurchaseOrder> pos, bool isDark, ThemeData theme) {
    final dockPos = pos.where((p) => p.status == InboundStatus.atDock || p.status == InboundStatus.receiving || p.status == InboundStatus.inTransit).toList();

    if (dockPos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('No shipments currently waiting at Dock bays.', style: AppTypography.body),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: dockPos.length,
      itemBuilder: (context, index) {
        final po = dockPos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dock Bay: ${po.receivingDockId ?? 'Dock-01 (Inbound)'}', style: AppTypography.bodyBold),
                  _buildStatusChip(po.status, theme),
                ],
              ),
              const Divider(height: 16),
              Text('${po.poNumber} — ${po.vendorName}', style: AppTypography.h3),
              const SizedBox(height: 6),
              ...po.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.productName} (${item.sku})', style: AppTypography.body),
                      Text('${item.orderedQty} ${item.uom}', style: AppTypography.bodyBold),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final updatedItems = po.items.map((i) => i.copyWith(receivedQty: i.orderedQty)).toList();
                      await ref.read(inboundNotifierProvider.notifier).receiveDockGoods(
                        poId: po.id,
                        receivedItems: updatedItems,
                        dockId: po.receivingDockId ?? 'Dock-01',
                      );
                      _tabController.animateTo(2); // Jump to QC
                    },
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Scan & Confirm GRN Intake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. QC Gate View
  Widget _buildQcGateView(BuildContext context, List<PurchaseOrder> pos, bool isDark, ThemeData theme) {
    final qcPos = pos.where((p) => p.status == InboundStatus.qcPending || p.status == InboundStatus.atDock).toList();

    if (qcPos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('All dock intake shipments have passed QC inspection!', style: AppTypography.bodyBold),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: qcPos.length,
      itemBuilder: (context, index) {
        final po = qcPos[index];
        final isHealthcare = po.archetypeId == 'healthcare_pharma';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(po.poNumber, style: AppTypography.h3),
                      if (isHealthcare) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DUAL-WITNESS MANDATORY',
                            style: AppTypography.captionBold.copyWith(color: theme.colorScheme.onErrorContainer, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  _buildStatusChip(po.status, theme),
                ],
              ),
              const SizedBox(height: 6),
              Text('Supplier: ${po.vendorName} • Arrived at: ${po.receivingDockId ?? 'Dock-01'}', style: AppTypography.caption),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${po.items.length} items staged for inspection', style: AppTypography.bodyBold),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => QcInspectionModal(purchaseOrder: po),
                      );
                    },
                    icon: const Icon(Icons.fact_check_rounded, size: 16),
                    label: const Text('Open QC Gate Inspection'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 4. Directed Putaway View
  Widget _buildPutawayView(BuildContext context, List<PutawayTask> tasks, bool isDark, ThemeData theme) {
    if (tasks.isEmpty) {
      return Center(child: Text('No active Putaway tasks pending.', style: AppTypography.body));
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isDone = task.isCompleted;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDone
                  ? theme.colorScheme.outlineVariant
                  : theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isDone
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primaryContainer,
                child: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.navigation_outlined,
                  color: isDone ? theme.colorScheme.outline : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(task.productName, style: AppTypography.bodyBold),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.zoneType.name.toUpperCase(),
                            style: AppTypography.captionBold.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Suggested: ${task.suggestedLocation} (${task.quantity} ${task.uom})',
                      style: AppTypography.captionBold.copyWith(color: theme.colorScheme.primary),
                    ),
                    if (task.confirmedLocation != null) ...[
                      const SizedBox(height: 2),
                      Text('Confirmed at: ${task.confirmedLocation}', style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
              if (!isDone)
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => PutawayConfirmModal(task: task),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Confirm Bin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(InboundStatus status, ThemeData theme) {
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
        bg = theme.colorScheme.primary.withValues(alpha: 0.15);
        fg = theme.colorScheme.primary;
        break;
      case InboundStatus.qcPassed:
      case InboundStatus.putawayReady:
      case InboundStatus.completed:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
      case InboundStatus.qcFailed:
      case InboundStatus.cancelled:
        bg = theme.colorScheme.error.withValues(alpha: 0.15);
        fg = theme.colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(status.label, style: AppTypography.captionBold.copyWith(color: fg)),
    );
  }
}
