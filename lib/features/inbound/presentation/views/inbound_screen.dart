import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/purchase_order.dart';
import '../../domain/models/putaway_task.dart';
import '../controllers/inbound_controller.dart';
import '../widgets/po_form_modal.dart';
import '../widgets/putaway_confirm_modal.dart';
import '../widgets/qc_inspection_modal.dart';

/// Inbound Receiving, PO Pipeline, QC Gate & Directed Putaway Screen.
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
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Responsive Header Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < AppSpacing.breakpointMobile;

                  final titleSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Text(
                            'Inbound Receiving & POs',
                            style: AppTypography.headlineLarge.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                            decoration: BoxDecoration(
                              color: archetype.brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                              border: Border.all(color: archetype.brandColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              archetype.name,
                              style: AppTypography.labelSmall.copyWith(
                                color: archetype.brandColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Dock intake, QC inspection gate & directed putaway for ${archetype.name}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final newPoButton = ElevatedButton.icon(
                    onPressed: () => PoFormModal.show(context),
                    icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                    label: const Text('New Purchase Order'),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        SizedBox(width: double.infinity, child: newPoButton),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      newPoButton,
                    ],
                  );
                },
              ),
              AppGap.h20,

              // 2. Responsive 4-Stage KPI Pipeline Grid
              _buildKpiSection(context, pendingPoCount, dockCount, qcCount, putawayCount, archetype, isDark, colorScheme),
              AppGap.h24,

              // 3. Tab Navigation Bar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: colorScheme.primary,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  tabs: const [
                    Tab(icon: Icon(Icons.list_alt_rounded, size: AppSizes.iconSm), text: 'PO Pipeline'),
                    Tab(icon: Icon(Icons.dock_rounded, size: AppSizes.iconSm), text: 'Dock Receiving (GRN)'),
                    Tab(icon: Icon(Icons.verified_user_outlined, size: AppSizes.iconSm), text: 'QC Inspection Gate'),
                    Tab(icon: Icon(Icons.grid_view_rounded, size: AppSizes.iconSm), text: 'Directed Putaway'),
                  ],
                ),
              ),
              AppGap.h16,

              // 4. Active Tab Content View (Zero hardcoded height, natural scrolling)
              _buildActiveTabView(context, _tabController.index, pos, putawayTasks, isDark, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI PIPELINE GRID
  // ---------------------------------------------------------------------------
  Widget _buildKpiSection(
    BuildContext context,
    int pendingPoCount,
    int dockCount,
    int qcCount,
    int putawayCount,
    dynamic archetype,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final cards = [
      {
        'title': '1. PO Pipeline',
        'count': '$pendingPoCount Orders',
        'icon': Icons.description_outlined,
        'color': AppColors.info,
        'tabIndex': 0,
      },
      {
        'title': '2. Dock Intake',
        'count': '$dockCount Shipments',
        'icon': Icons.local_shipping_outlined,
        'color': AppColors.warning,
        'tabIndex': 1,
      },
      {
        'title': '3. QC Inspection',
        'count': '$qcCount Batches',
        'icon': Icons.fact_check_outlined,
        'color': archetype.brandColor as Color,
        'tabIndex': 2,
      },
      {
        'title': '4. Putaway Tasks',
        'count': '$putawayCount Tasks',
        'icon': Icons.move_to_inbox_outlined,
        'color': AppColors.success,
        'tabIndex': 3,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 960;

        if (isNarrow) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildKpiCard(context, cards[0], isDark, colorScheme)),
                  AppGap.w12,
                  Expanded(child: _buildKpiCard(context, cards[1], isDark, colorScheme)),
                ],
              ),
              AppGap.h12,
              Row(
                children: [
                  Expanded(child: _buildKpiCard(context, cards[2], isDark, colorScheme)),
                  AppGap.w12,
                  Expanded(child: _buildKpiCard(context, cards[3], isDark, colorScheme)),
                ],
              ),
            ],
          );
        }

        return Row(
          children: cards.map((c) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _buildKpiCard(context, c, isDark, colorScheme),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildKpiCard(
    BuildContext context,
    Map<String, dynamic> data,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final color = data['color'] as Color;
    final isSelected = _tabController.index == (data['tabIndex'] as int);

    return InkWell(
      onTap: () => _tabController.animateTo(data['tabIndex'] as int),
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: Container(
        padding: AppPadding.p12,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                  ),
                  child: Icon(data['icon'] as IconData, size: AppSizes.iconSm, color: color),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
              ],
            ),
            AppGap.h8,
            Text(
              data['count'] as String,
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppGap.h4,
            Text(
              data['title'] as String,
              style: AppTypography.labelSmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB CONTENT SELECTOR
  // ---------------------------------------------------------------------------
  Widget _buildActiveTabView(
    BuildContext context,
    int index,
    List<PurchaseOrder> pos,
    List<PutawayTask> putawayTasks,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    switch (index) {
      case 0:
        return _buildPoListView(context, pos, isDark, colorScheme);
      case 1:
        return _buildDockReceivingView(context, pos, isDark, colorScheme);
      case 2:
        return _buildQcGateView(context, pos, isDark, colorScheme);
      case 3:
      default:
        return _buildPutawayView(context, putawayTasks, isDark, colorScheme);
    }
  }

  // ---------------------------------------------------------------------------
  // 1. PURCHASE ORDERS LIST VIEW
  // ---------------------------------------------------------------------------
  Widget _buildPoListView(
    BuildContext context,
    List<PurchaseOrder> pos,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (pos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.description_outlined,
        title: 'No Purchase Orders found',
        subtitle: 'Create a new purchase order to start inbound intake.',
        actionLabel: 'Create Purchase Order',
        onAction: () => PoFormModal.show(context),
        colorScheme: colorScheme,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pos.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        final po = pos[index];
        final canDockReceive = po.status == InboundStatus.inTransit || po.status == InboundStatus.approved;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;

            return Container(
              padding: AppPadding.p16,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.r12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: AppSizes.buttonHeightSm,
                        height: AppSizes.buttonHeightSm,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: colorScheme.primary, size: AppSizes.iconSm),
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
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                _buildStatusChip(po.status, colorScheme),
                              ],
                            ),
                            AppGap.h4,
                            Text(
                              'Supplier: ${po.vendorName}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${po.items.length} line items  •  ${po.totalOrderedUnits.toStringAsFixed(0)} units total',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${po.totalAmount.toStringAsFixed(2)}',
                              style: AppTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            if (canDockReceive) ...[
                              AppGap.h8,
                              ElevatedButton.icon(
                                onPressed: () => _handleDockReceive(po),
                                icon: const Icon(Icons.input_rounded, size: AppSizes.iconSm),
                                label: const Text('Dock Receive'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (isNarrow) ...[
                    AppGap.h12,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: \$${po.totalAmount.toStringAsFixed(2)}',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (canDockReceive)
                          ElevatedButton.icon(
                            onPressed: () => _handleDockReceive(po),
                            icon: const Icon(Icons.input_rounded, size: AppSizes.iconSm),
                            label: const Text('Dock Receive'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 2. DOCK RECEIVING VIEW
  // ---------------------------------------------------------------------------
  Widget _buildDockReceivingView(
    BuildContext context,
    List<PurchaseOrder> pos,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final dockPos = pos.where((p) => p.status == InboundStatus.atDock || p.status == InboundStatus.receiving || p.status == InboundStatus.inTransit).toList();

    if (dockPos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No shipments waiting at Dock bays',
        subtitle: 'All in-transit purchase orders have been received at dock.',
        colorScheme: colorScheme,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dockPos.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        final po = dockPos[index];

        return Container(
          padding: AppPadding.p16,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      'DOCK: ${po.receivingDockId ?? "Dock Staging Bay 01"}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(po.status, colorScheme),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Text(
                '${po.poNumber} — ${po.vendorName}',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              AppGap.h8,
              ...po.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} (${item.sku})',
                          style: AppTypography.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${item.orderedQty} ${item.uom}',
                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
              AppGap.h16,
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _handleDockReceive(po),
                  icon: const Icon(Icons.check_rounded, size: AppSizes.iconSm),
                  label: const Text('Scan & Confirm GRN Intake'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 3. QC GATE VIEW
  // ---------------------------------------------------------------------------
  Widget _buildQcGateView(
    BuildContext context,
    List<PurchaseOrder> pos,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final qcPos = pos.where((p) => p.status == InboundStatus.qcPending || p.status == InboundStatus.atDock).toList();

    if (qcPos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.verified_rounded,
        title: 'QC Inspection Gate Clear',
        subtitle: 'All dock intake shipments have passed Quality Control inspection.',
        colorScheme: colorScheme,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: qcPos.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        final po = qcPos[index];
        final isHealthcare = po.archetypeId == 'healthcare_pharma';

        return Container(
          padding: AppPadding.p16,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Text(
                        po.poNumber,
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isHealthcare)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.r4),
                          ),
                          child: Text(
                            'DUAL-WITNESS MANDATORY',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  _buildStatusChip(po.status, colorScheme),
                ],
              ),
              AppGap.h4,
              Text(
                'Supplier: ${po.vendorName} • Arrived at: ${po.receivingDockId ?? "Dock-01"}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${po.items.length} items staged for inspection',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => QcInspectionModal.show(context, purchaseOrder: po),
                    icon: const Icon(Icons.fact_check_rounded, size: AppSizes.iconSm),
                    label: const Text('Open QC Gate'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4. DIRECTED PUTAWAY VIEW
  // ---------------------------------------------------------------------------
  Widget _buildPutawayView(
    BuildContext context,
    List<PutawayTask> tasks,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (tasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.move_to_inbox_outlined,
        title: 'No Active Putaway Tasks',
        subtitle: 'All items have been put away into their assigned shelf bin locations.',
        colorScheme: colorScheme,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isDone = task.isCompleted;

        return Container(
          padding: AppPadding.p16,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(
              color: isDone ? colorScheme.outline : colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSizes.buttonHeightSm,
                height: AppSizes.buttonHeightSm,
                decoration: BoxDecoration(
                  color: isDone
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.navigation_outlined,
                  color: isDone ? colorScheme.outline : colorScheme.primary,
                  size: AppSizes.iconSm + 4,
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
                          task.productName,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.r4),
                          ),
                          child: Text(
                            task.zoneType.name.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppGap.h4,
                    Text(
                      'Suggested Bin: ${task.suggestedLocation} (${task.quantity} ${task.uom})',
                      style: AppTypography.bodySmall.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (task.confirmedLocation != null) ...[
                      const SizedBox(height: 2),
                      Text('Confirmed at: ${task.confirmedLocation}', style: AppTypography.bodySmall),
                    ],
                  ],
                ),
              ),
              if (!isDone)
                ElevatedButton.icon(
                  onPressed: () => PutawayConfirmModal.show(context, task: task),
                  icon: const Icon(Icons.arrow_forward_rounded, size: AppSizes.iconSm),
                  label: const Text('Confirm Bin'),
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER SUB-COMPONENTS
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    required ColorScheme colorScheme,
  }) {
    return Container(
      width: double.infinity,
      padding: AppPadding.p32,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppSizes.buttonHeightMd, color: colorScheme.primary.withValues(alpha: 0.5)),
          AppGap.h16,
          Text(title, style: AppTypography.headlineSmall),
          AppGap.h4,
          Text(subtitle, style: AppTypography.bodySmall, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            AppGap.h16,
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
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

  Future<void> _handleDockReceive(PurchaseOrder po) async {
    final updatedItems = po.items.map((i) => i.copyWith(receivedQty: i.orderedQty)).toList();
    await ref.read(inboundNotifierProvider.notifier).receiveDockGoods(
      poId: po.id,
      receivedItems: updatedItems,
      dockId: po.receivingDockId ?? 'Dock Staging Bay 01',
    );
    _tabController.animateTo(2); // Jump to QC
  }
}
