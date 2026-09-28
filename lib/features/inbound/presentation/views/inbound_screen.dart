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
import '../widgets/inbound_dock_card.dart';
import '../widgets/inbound_po_card.dart';
import '../widgets/inbound_putaway_card.dart';
import '../widgets/inbound_qc_card.dart';
import '../widgets/po_form_modal.dart';

/// Inbound Receiving, PO Pipeline, QC Gate & Directed Putaway Screen.
/// Clean, unified, non-redundant UI with interactive pipeline stage navigation and search.
class InboundScreen extends ConsumerStatefulWidget {
  const InboundScreen({super.key});

  @override
  ConsumerState<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends ConsumerState<InboundScreen> {
  int _activeStageIndex = 0;
  String _searchQuery = '';
  InboundStatus? _statusFilter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
              // 1. Responsive Top Header Bar
              _buildHeaderBar(context, archetype, isDark, colorScheme),
              AppGap.h20,

              // 2. Unified Interactive Pipeline Stage Bar (Replaces duplicate TabBar + KPI cards)
              _buildUnifiedPipelineBar(
                context,
                pendingPoCount,
                dockCount,
                qcCount,
                putawayCount,
                archetype,
                isDark,
                colorScheme,
              ),
              AppGap.h16,

              // 3. Search & Filter Utility Toolbar
              _buildUtilityToolbar(context, isDark, colorScheme),
              AppGap.h16,

              // 4. Active Stage List Content
              _buildActiveStageContent(
                context,
                pos,
                putawayTasks,
                isDark,
                colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP HEADER BAR
  // ---------------------------------------------------------------------------
  Widget _buildHeaderBar(
    BuildContext context,
    dynamic archetype,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return LayoutBuilder(
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
    );
  }

  // ---------------------------------------------------------------------------
  // 2. UNIFIED INTERACTIVE PIPELINE STAGE BAR
  // ---------------------------------------------------------------------------
  Widget _buildUnifiedPipelineBar(
    BuildContext context,
    int pendingPoCount,
    int dockCount,
    int qcCount,
    int putawayCount,
    dynamic archetype,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final stages = [
      {
        'stage': '1',
        'title': 'PO Pipeline',
        'count': '$pendingPoCount Orders',
        'icon': Icons.description_outlined,
        'color': AppColors.info,
      },
      {
        'stage': '2',
        'title': 'Dock Intake',
        'count': '$dockCount Shipments',
        'icon': Icons.local_shipping_outlined,
        'color': AppColors.warning,
      },
      {
        'stage': '3',
        'title': 'QC Inspection',
        'count': '$qcCount Batches',
        'icon': Icons.fact_check_outlined,
        'color': archetype.brandColor as Color,
      },
      {
        'stage': '4',
        'title': 'Directed Putaway',
        'count': '$putawayCount Tasks',
        'icon': Icons.move_to_inbox_outlined,
        'color': AppColors.success,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;

        if (isNarrow) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStageTile(0, stages[0], isDark, colorScheme)),
                  AppGap.w8,
                  Expanded(child: _buildStageTile(1, stages[1], isDark, colorScheme)),
                ],
              ),
              AppGap.h8,
              Row(
                children: [
                  Expanded(child: _buildStageTile(2, stages[2], isDark, colorScheme)),
                  AppGap.w8,
                  Expanded(child: _buildStageTile(3, stages[3], isDark, colorScheme)),
                ],
              ),
            ],
          );
        }

        return Row(
          children: List.generate(stages.length, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < stages.length - 1 ? AppSpacing.sm : 0,
                ),
                child: _buildStageTile(index, stages[index], isDark, colorScheme),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStageTile(
    int index,
    Map<String, dynamic> data,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final isSelected = _activeStageIndex == index;
    final color = data['color'] as Color;

    return Material(
      color: isSelected
          ? color.withValues(alpha: isDark ? 0.20 : 0.12)
          : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: InkWell(
        onTap: () {
          setState(() {
            _activeStageIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(AppRadii.r12),
        child: Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(
              color: isSelected ? color : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    data['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
              AppGap.w8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'STAGE ${data['stage']}',
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      data['title'] as String,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      data['count'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. SEARCH & FILTER UTILITY TOOLBAR
  // ---------------------------------------------------------------------------
  Widget _buildUtilityToolbar(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final searchField = TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search by PO#, Supplier, SKU, or Product...',
            prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          ),
        );

        final filterDropdown = DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: DropdownButton<InboundStatus?>(
              value: _statusFilter,
              hint: Text('Status: All', style: AppTypography.bodySmall),
              isDense: true,
              items: [
                DropdownMenuItem<InboundStatus?>(
                  value: null,
                  child: Text('Status: All', style: AppTypography.bodySmall),
                ),
                ...InboundStatus.values.map((s) {
                  return DropdownMenuItem<InboundStatus?>(
                    value: s,
                    child: Text(s.label, style: AppTypography.bodySmall),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _statusFilter = val),
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              AppGap.h8,
              Align(alignment: Alignment.centerLeft, child: filterDropdown),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            AppGap.w12,
            filterDropdown,
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4. ACTIVE STAGE CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildActiveStageContent(
    BuildContext context,
    List<PurchaseOrder> pos,
    List<PutawayTask> putawayTasks,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    switch (_activeStageIndex) {
      case 0:
        return _buildPoStage(context, pos, isDark, colorScheme);
      case 1:
        return _buildDockStage(context, pos, isDark, colorScheme);
      case 2:
        return _buildQcStage(context, pos, isDark, colorScheme);
      case 3:
      default:
        return _buildPutawayStage(context, putawayTasks, isDark, colorScheme);
    }
  }

  // ---------------------------------------------------------------------------
  // STAGE 0: PO PIPELINE
  // ---------------------------------------------------------------------------
  Widget _buildPoStage(
    BuildContext context,
    List<PurchaseOrder> pos,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    var filtered = pos;

    if (_statusFilter != null) {
      filtered = filtered.where((p) => p.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final matchPo = p.poNumber.toLowerCase().contains(_searchQuery);
        final matchVendor = p.vendorName.toLowerCase().contains(_searchQuery);
        final matchItems = p.items.any((i) =>
            i.productName.toLowerCase().contains(_searchQuery) ||
            i.sku.toLowerCase().contains(_searchQuery));
        return matchPo || matchVendor || matchItems;
      }).toList();
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(
        icon: Icons.description_outlined,
        title: _searchQuery.isNotEmpty ? 'No Matching Purchase Orders' : 'No Purchase Orders Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'Try changing your search terms or status filters.'
            : 'Create a new purchase order to start inbound intake.',
        actionLabel: _searchQuery.isNotEmpty ? 'Clear Filters' : 'Create Purchase Order',
        onAction: _searchQuery.isNotEmpty
            ? () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _statusFilter = null;
                });
              }
            : () => PoFormModal.show(context),
        colorScheme: colorScheme,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        final po = filtered[index];
        return InboundPoCard(
          po: po,
          onDockReceive: () => _handleDockReceive(po),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STAGE 1: DOCK RECEIVING
  // ---------------------------------------------------------------------------
  Widget _buildDockStage(
    BuildContext context,
    List<PurchaseOrder> pos,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    var dockPos = pos.where((p) => p.status == InboundStatus.atDock || p.status == InboundStatus.receiving || p.status == InboundStatus.inTransit).toList();

    if (_searchQuery.isNotEmpty) {
      dockPos = dockPos.where((p) {
        final matchPo = p.poNumber.toLowerCase().contains(_searchQuery);
        final matchVendor = p.vendorName.toLowerCase().contains(_searchQuery);
        final matchItems = p.items.any((i) =>
            i.productName.toLowerCase().contains(_searchQuery) ||
            i.sku.toLowerCase().contains(_searchQuery));
        return matchPo || matchVendor || matchItems;
      }).toList();
    }

    if (dockPos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No Shipments Waiting at Dock Bays',
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
        return InboundDockCard(
          po: po,
          onScanAndConfirm: () => _handleDockReceive(po),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STAGE 2: QC INSPECTION GATE
  // ---------------------------------------------------------------------------
  Widget _buildQcStage(
    BuildContext context,
    List<PurchaseOrder> pos,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    var qcPos = pos.where((p) => p.status == InboundStatus.qcPending || p.status == InboundStatus.atDock).toList();

    if (_searchQuery.isNotEmpty) {
      qcPos = qcPos.where((p) {
        final matchPo = p.poNumber.toLowerCase().contains(_searchQuery);
        final matchVendor = p.vendorName.toLowerCase().contains(_searchQuery);
        final matchItems = p.items.any((i) =>
            i.productName.toLowerCase().contains(_searchQuery) ||
            i.sku.toLowerCase().contains(_searchQuery));
        return matchPo || matchVendor || matchItems;
      }).toList();
    }

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
        return InboundQcCard(po: po);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // STAGE 3: DIRECTED PUTAWAY
  // ---------------------------------------------------------------------------
  Widget _buildPutawayStage(
    BuildContext context,
    List<PutawayTask> tasks,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    var filtered = tasks;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.productName.toLowerCase().contains(_searchQuery) ||
            t.sku.toLowerCase().contains(_searchQuery) ||
            t.suggestedLocation.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (filtered.isEmpty) {
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
      itemCount: filtered.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        final task = filtered[index];
        return InboundPutawayCard(task: task);
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
          Text(title, style: AppTypography.headlineSmall, textAlign: TextAlign.center),
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

  Future<void> _handleDockReceive(PurchaseOrder po) async {
    final updatedItems = po.items.map((i) => i.copyWith(receivedQty: i.orderedQty)).toList();
    await ref.read(inboundNotifierProvider.notifier).receiveDockGoods(
      poId: po.id,
      receivedItems: updatedItems,
      dockId: po.receivingDockId ?? 'Dock Staging Bay 01',
    );
    setState(() {
      _activeStageIndex = 2; // Jump directly to QC inspection stage
    });
  }
}
