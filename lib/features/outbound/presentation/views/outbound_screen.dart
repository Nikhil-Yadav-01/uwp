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
import '../../domain/models/packing_session.dart';
import '../../domain/models/picking_wave.dart';
import '../../domain/models/sales_order.dart';
import '../controllers/outbound_controller.dart';
import '../widgets/outbound_packing_card.dart';
import '../widgets/outbound_shipping_card.dart';
import '../widgets/outbound_so_card.dart';
import '../widgets/outbound_wave_card.dart';
import '../widgets/so_form_modal.dart';
import '../widgets/wave_generator_modal.dart';

/// Redesigned Outbound Screen featuring a Unified Interactive Pipeline Stage Bar,
/// real-time search & priority filtering, and responsive modular cards.
class OutboundScreen extends ConsumerStatefulWidget {
  const OutboundScreen({super.key});

  @override
  ConsumerState<OutboundScreen> createState() => _OutboundScreenState();
}

class _OutboundScreenState extends ConsumerState<OutboundScreen> {
  int _selectedStageIndex = 0;
  String _searchQuery = '';
  OrderPriority? _selectedPriorityFilter;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToStage(int index) {
    setState(() {
      _selectedStageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;
    final outboundState = ref.watch(outboundNotifierProvider);

    final orders = outboundState.salesOrders;
    final waves = outboundState.activeWaves;
    final activeSession = outboundState.activePackingSession;

    final backlogOrders = orders.where((o) => o.status == OutboundStatus.pending || o.status == OutboundStatus.allocated).toList();
    final activeWaves = waves.where((w) => w.status != WaveStatus.completed).toList();
    final packingOrders = orders.where((o) => o.status == OutboundStatus.picked || o.status == OutboundStatus.packing).toList();
    final shippedOrders = orders.where((o) => o.status == OutboundStatus.shipped || o.status == OutboundStatus.packed).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Archetype badge & Quick Actions
              _buildScreenHeader(context, archetype, isDark, colorScheme),
              AppGap.h20,

              // 2. Unified Interactive Pipeline Stage Bar
              _buildUnifiedPipelineBar(
                context,
                backlogOrders.length,
                activeWaves.length,
                packingOrders.length,
                shippedOrders.length,
                archetype,
                isDark,
                colorScheme,
              ),
              AppGap.h16,

              // 3. Search & Filter Utility Toolbar
              _buildSearchAndFilterBar(context, isDark, colorScheme),
              AppGap.h16,

              // 4. Active Stage Card List
              _buildActiveStageContent(
                context,
                orders: orders,
                waves: waves,
                activeSession: activeSession,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. SCREEN HEADER
  // ---------------------------------------------------------------------------
  Widget _buildScreenHeader(
    BuildContext context,
    dynamic archetype,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < AppSpacing.breakpointMobile;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                Text(
                  'Outbound Fulfillment & Waves',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
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
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h4,
            Text(
              'Collect items from shelves, scan barcodes into shipping boxes, and dispatch orders',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        );

        final actionButtons = Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            OutlinedButton.icon(
              onPressed: () => SoFormModal.show(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r8)),
              ),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: AppSizes.iconSm),
              label: const Text('New Customer Order'),
            ),
            ElevatedButton.icon(
              onPressed: () => WaveGeneratorModal.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.r8)),
              ),
              icon: const Icon(Icons.bolt_rounded, size: AppSizes.iconSm),
              label: const Text('Start Picking Batch'),
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              AppGap.h12,
              SizedBox(width: double.infinity, child: actionButtons),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            AppGap.w16,
            actionButtons,
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
    int backlogCount,
    int activeWavesCount,
    int packingCount,
    int shippedCount,
    dynamic archetype,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final stages = [
      {
        'stage': '1',
        'title': '1. Orders to Process',
        'count': '$backlogCount Orders Waiting',
        'icon': Icons.pending_actions_outlined,
        'color': AppColors.info,
      },
      {
        'stage': '2',
        'title': '2. Gathering from Shelves',
        'count': '$activeWavesCount Pick Lists',
        'icon': Icons.alt_route_rounded,
        'color': archetype.brandColor as Color,
      },
      {
        'stage': '3',
        'title': '3. Packing & Boxing',
        'count': '$packingCount Orders',
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.warning,
      },
      {
        'stage': '4',
        'title': '4. Shipped Orders',
        'count': '$shippedCount Dispatched',
        'icon': Icons.local_shipping_outlined,
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
    final isSelected = _selectedStageIndex == index;
    final color = data['color'] as Color;

    return Material(
      color: isSelected
          ? color.withValues(alpha: isDark ? 0.20 : 0.12)
          : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
      borderRadius: BorderRadius.circular(AppRadii.r12),
      child: InkWell(
        onTap: () => _navigateToStage(index),
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
  // 3. SEARCH & FILTER TOOLBAR
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilterBar(BuildContext context, bool isDark, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Container(
          padding: AppPadding.p12,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: colorScheme.outline),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search orders, SKU, customer or picker...',
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                    AppGap.h8,
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Priorities', null),
                          AppGap.w4,
                          _buildFilterChip('Standard', OrderPriority.standard),
                          AppGap.w4,
                          _buildFilterChip('Rush', OrderPriority.rush),
                          AppGap.w4,
                          _buildFilterChip('Emergency', OrderPriority.emergencyCrashCart),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search orders by SO#, customer name, destination, SKU or picker...',
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      ),
                    ),
                    AppGap.w12,
                    _buildFilterChip('All', null),
                    AppGap.w4,
                    _buildFilterChip('Standard', OrderPriority.standard),
                    AppGap.w4,
                    _buildFilterChip('Rush', OrderPriority.rush),
                    AppGap.w4,
                    _buildFilterChip('Emergency', OrderPriority.emergencyCrashCart),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, OrderPriority? priority) {
    final isSelected = _selectedPriorityFilter == priority;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedPriorityFilter = priority),
      visualDensity: VisualDensity.compact,
      selectedColor: colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? colorScheme.primary : null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. ACTIVE STAGE CONTENT
  // ---------------------------------------------------------------------------
  Widget _buildActiveStageContent(
    BuildContext context, {
    required List<SalesOrder> orders,
    required List<PickingWave> waves,
    required PackingSession? activeSession,
    required bool isDark,
  }) {
    switch (_selectedStageIndex) {
      case 0:
        return _buildStageBacklog(context, orders, isDark);
      case 1:
        return _buildStageWaves(context, waves, isDark);
      case 2:
        return _buildStagePacking(context, orders, activeSession, isDark);
      case 3:
        return _buildStageShipping(context, orders, activeSession, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // Stage 0: Orders Backlog
  Widget _buildStageBacklog(BuildContext context, List<SalesOrder> orders, bool isDark) {
    var filtered = orders.where((o) {
      if (_selectedPriorityFilter != null && o.priority != _selectedPriorityFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final matchesSo = o.soNumber.toLowerCase().contains(q);
        final matchesCust = o.customerName.toLowerCase().contains(q);
        final matchesDest = o.destinationWardOrAddress.toLowerCase().contains(q);
        final matchesItem = o.items.any((i) => i.productName.toLowerCase().contains(q) || i.sku.toLowerCase().contains(q));
        return matchesSo || matchesCust || matchesDest || matchesItem;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Sales Orders Found',
        subtitle: _searchQuery.isNotEmpty ? 'Try changing your search query or priority filter.' : 'Create a new Sales Order to start the fulfillment pipeline.',
        actionLabel: 'Create Sales Order',
        onAction: () => SoFormModal.show(context),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (context, index) {
        final order = filtered[index];
        return OutboundSoCard(
          order: order,
          onStartPacking: () async {
            await ref.read(outboundNotifierProvider.notifier).startPacking(order.id);
            _navigateToStage(2); // Jump to Packing Station stage
          },
          onNavigateStage: _navigateToStage,
        );
      },
    );
  }

  // Stage 1: Wave Route Picking
  Widget _buildStageWaves(BuildContext context, List<PickingWave> waves, bool isDark) {
    var filtered = waves.where((w) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final matchesWave = w.waveNumber.toLowerCase().contains(q);
        final matchesPicker = (w.assignedPickerName ?? '').toLowerCase().contains(q);
        final matchesZone = w.zone.toLowerCase().contains(q);
        final matchesTask = w.tasks.any((t) => t.productName.toLowerCase().contains(q) || t.sku.toLowerCase().contains(q) || t.location.toLowerCase().contains(q));
        return matchesWave || matchesPicker || matchesZone || matchesTask;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(
        icon: Icons.alt_route_rounded,
        title: 'No Active Picking Waves',
        subtitle: 'Batch orders into an optimized FEFO picking wave picklist to guide floor pickers.',
        actionLabel: 'Dispatch Wave Picklist',
        onAction: () => WaveGeneratorModal.show(context),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (context, index) {
        final wave = filtered[index];
        return OutboundWaveCard(wave: wave);
      },
    );
  }

  // Stage 2: Packing Station
  Widget _buildStagePacking(
    BuildContext context,
    List<SalesOrder> orders,
    PackingSession? activeSession,
    bool isDark,
  ) {
    if (activeSession == null) {
      final readyOrders = orders.where((o) => o.status == OutboundStatus.picked || o.status == OutboundStatus.packing || o.status == OutboundStatus.allocated).toList();

      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Active Packing Session',
        subtitle: readyOrders.isNotEmpty
            ? 'You have ${readyOrders.length} order(s) ready for scan verification and boxing.'
            : 'Picked orders from wave runs will appear here for scan verification.',
        actionLabel: readyOrders.isNotEmpty ? 'Start Packing ${readyOrders.first.soNumber}' : null,
        onAction: readyOrders.isNotEmpty
            ? () async {
                await ref.read(outboundNotifierProvider.notifier).startPacking(readyOrders.first.id);
              }
            : null,
      );
    }

    return OutboundPackingCard(session: activeSession);
  }

  // Stage 3: Shipping & Manifests
  Widget _buildStageShipping(
    BuildContext context,
    List<SalesOrder> orders,
    PackingSession? activeSession,
    bool isDark,
  ) {
    final shippedOrders = orders.where((o) => o.status == OutboundStatus.shipped || o.status == OutboundStatus.packed).toList();

    var filtered = shippedOrders.where((o) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final matchesSo = o.soNumber.toLowerCase().contains(q);
        final matchesCust = o.customerName.toLowerCase().contains(q);
        final matchesDest = o.destinationWardOrAddress.toLowerCase().contains(q);
        return matchesSo || matchesCust || matchesDest;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No Dispatched Manifests',
        subtitle: 'Completed carton packing sessions generate shipping labels and tracking manifests here.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final session = (activeSession != null && (activeSession.orderId == order.id || activeSession.soNumber == order.soNumber))
            ? activeSession
            : null;
        return OutboundShippingCard(order: order, session: session);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: AppPadding.p32,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconLg, color: colorScheme.primary.withValues(alpha: 0.6)),
            AppGap.h12,
            Text(title, style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            AppGap.h4,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
      ),
    );
  }
}
