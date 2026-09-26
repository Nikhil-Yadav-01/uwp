import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../../domain/models/sales_order.dart';
import '../../domain/models/picking_wave.dart';
import '../controllers/outbound_controller.dart';
import '../widgets/so_form_modal.dart';
import '../widgets/wave_generator_modal.dart';
import '../widgets/shipping_label_modal.dart';

class OutboundScreen extends ConsumerStatefulWidget {
  const OutboundScreen({super.key});

  @override
  ConsumerState<OutboundScreen> createState() => _OutboundScreenState();
}

class _OutboundScreenState extends ConsumerState<OutboundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _barcodeScanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _barcodeScanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;
    final outboundState = ref.watch(outboundNotifierProvider);
    final orders = outboundState.salesOrders;
    final waves = outboundState.activeWaves;
    final activeSession = outboundState.activePackingSession;

    final pendingOrdersCount = orders.where((o) => o.status == OutboundStatus.pending || o.status == OutboundStatus.allocated).length;
    final activeWavesCount = waves.where((w) => w.status != WaveStatus.completed).length;
    final packingCount = orders.where((o) => o.status == OutboundStatus.picked || o.status == OutboundStatus.packing).length;
    final shippedCount = orders.where((o) => o.status == OutboundStatus.shipped).length;

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
                        Text('Outbound Fulfillment & Waves', style: AppTypography.h1),
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
                      'Wave picking optimizer, barcode packing verification & shipping for ${archetype.name}',
                      style: AppTypography.body.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const SoFormModal(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: const Text('New Sales Order'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const WaveGeneratorModal(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                      icon: const Icon(Icons.bolt_rounded, size: 20),
                      label: const Text('Dispatch Wave Picklist'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Outbound KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;
                final cards = [
                  {
                    'title': '1. Orders Backlog',
                    'count': '$pendingOrdersCount Orders',
                    'icon': Icons.pending_actions_outlined,
                    'color': AppColors.info,
                    'tabIndex': 0,
                  },
                  {
                    'title': '2. Active Waves',
                    'count': '$activeWavesCount Waves',
                    'icon': Icons.alt_route_rounded,
                    'color': archetype.brandColor,
                    'tabIndex': 1,
                  },
                  {
                    'title': '3. Packing Station',
                    'count': '$packingCount Orders',
                    'icon': Icons.inventory_outlined,
                    'color': AppColors.warning,
                    'tabIndex': 2,
                  },
                  {
                    'title': '4. Shipped Manifests',
                    'count': '$shippedCount Dispatched',
                    'icon': Icons.local_shipping_outlined,
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
                  Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Sales Orders Backlog'),
                  Tab(icon: Icon(Icons.directions_walk_rounded), text: 'Wave Route Picking'),
                  Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Packing Station Scan'),
                  Tab(icon: Icon(Icons.local_shipping_rounded), text: 'Shipping & Manifests'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tab Views Container
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSalesOrdersView(context, orders, isDark, theme),
                  _buildWavePickingView(context, waves, isDark, theme),
                  _buildPackingStationView(context, orders, activeSession, isDark, theme),
                  _buildShippingManifestsView(context, isDark, theme),
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

  // 1. Sales Orders Backlog View
  Widget _buildSalesOrdersView(BuildContext context, List<SalesOrder> orders, bool isDark, ThemeData theme) {
    if (orders.isEmpty) {
      return Center(child: Text('No Sales Orders in fulfillment queue.', style: AppTypography.body));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isEmergency = order.priority == OrderPriority.emergencyCrashCart;
        final isRush = order.priority == OrderPriority.rush;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isEmergency
                  ? theme.colorScheme.error.withValues(alpha: 0.6)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isEmergency
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEmergency ? Icons.emergency_rounded : Icons.shopping_bag_outlined,
                  color: isEmergency ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order.soNumber, style: AppTypography.h3),
                        const SizedBox(width: 8),
                        if (isEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'EMERGENCY CRASH CART',
                              style: AppTypography.captionBold.copyWith(color: theme.colorScheme.onError, fontSize: 10),
                            ),
                          )
                        else if (isRush)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RUSH',
                              style: AppTypography.captionBold.copyWith(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        const SizedBox(width: 8),
                        _buildStatusChip(order.status, theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.customerName} • ${order.destinationWardOrAddress}',
                      style: AppTypography.bodyBold,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.items.length} items (${order.totalRequestedUnits.toStringAsFixed(0)} units) • \$${order.totalAmount.toStringAsFixed(2)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              if (order.status == OutboundStatus.picked || order.status == OutboundStatus.packing)
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(outboundNotifierProvider.notifier).startPacking(order.id);
                    _tabController.animateTo(2); // Jump to Packing Station
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                  label: const Text('Pack Order'),
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

  // 2. Wave Route Picking View
  Widget _buildWavePickingView(BuildContext context, List<PickingWave> waves, bool isDark, ThemeData theme) {
    if (waves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alt_route_rounded, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('No active picking waves dispatched.', style: AppTypography.body),
          ],
        ),
      );
    }

    final wave = waves.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wave Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(wave.waveNumber, style: AppTypography.h3),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: wave.isAllPicked
                              ? AppColors.success.withValues(alpha: 0.15)
                              : theme.colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          wave.isAllPicked ? '100% PICKED' : 'IN PROGRESS',
                          style: AppTypography.captionBold.copyWith(
                            color: wave.isAllPicked ? AppColors.success : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assigned to: ${wave.assignedPickerName ?? 'Voice Picker'} • ${wave.zone}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
              Text(
                '${wave.completedTasksCount} / ${wave.totalTasksCount} Picked',
                style: AppTypography.h2.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Pick Tasks List
        Expanded(
          child: ListView.builder(
            itemCount: wave.tasks.length,
            itemBuilder: (context, index) {
              final task = wave.tasks[index];
              final isDone = task.isCompleted;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDone
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isDone
                        ? theme.colorScheme.outlineVariant
                        : theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDone
                          ? theme.colorScheme.outline
                          : theme.colorScheme.primary,
                      child: Text(
                        '#${task.stepOrder}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(task.productName, style: AppTypography.bodyBold),
                              const SizedBox(width: 8),
                              Text(
                                '${task.quantityToPick} ${task.uom}',
                                style: AppTypography.captionBold.copyWith(color: theme.colorScheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Location: ${task.location} • SKU: ${task.sku}',
                            style: AppTypography.captionBold.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          if (task.expiryDate != null)
                            Text(
                              'FEFO Expiry: ${task.expiryDate!.toLocal().toString().substring(0, 10)} • Batch: ${task.batchLotNumber}',
                              style: AppTypography.caption.copyWith(color: AppColors.warning),
                            ),
                        ],
                      ),
                    ),
                    if (!isDone)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(outboundNotifierProvider.notifier).confirmPickTask(
                            waveId: wave.id,
                            taskId: task.id,
                            quantityPicked: task.quantityToPick,
                          );
                        },
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Confirm Pick'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                      )
                    else
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Packing Station View
  Widget _buildPackingStationView(
    BuildContext context,
    List<SalesOrder> orders,
    dynamic activeSession,
    bool isDark,
    ThemeData theme,
  ) {
    if (activeSession == null) {
      final readyOrders = orders.where((o) => o.status == OutboundStatus.picked || o.status == OutboundStatus.packing || o.status == OutboundStatus.allocated).toList();

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('No active packing session.', style: AppTypography.h3),
            const SizedBox(height: 6),
            Text('Select an order from the list below to begin scan verification.', style: AppTypography.caption),
            const SizedBox(height: 16),
            if (readyOrders.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(outboundNotifierProvider.notifier).startPacking(readyOrders.first.id);
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Start Packing Order ${readyOrders.first.soNumber}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
          ],
        ),
      );
    }

    return Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Packing Station #01 — ${activeSession.soNumber}', style: AppTypography.h2),
                  Text('Ship To: ${activeSession.customerName} • ${activeSession.destination}', style: AppTypography.caption),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('PACKING IN PROGRESS', style: AppTypography.captionBold.copyWith(color: AppColors.warning)),
              ),
            ],
          ),
          const Divider(height: 24),

          // Barcode Scanner Simulator Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barcodeScanController,
                  decoration: const InputDecoration(
                    labelText: 'Scan Item Barcode / SKU to Verify',
                    prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                    hintText: 'e.g. HC-FNT-50MCG-AMP or TECH-APEX16P-256-BLK',
                  ),
                  onSubmitted: (barcode) async {
                    if (barcode.trim().isNotEmpty) {
                      final ok = await ref.read(outboundNotifierProvider.notifier).scanPackItem(barcode.trim());
                      _barcodeScanController.clear();
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Scan Error: Barcode does not match expected items!'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_barcodeScanController.text.trim().isNotEmpty) {
                    final ok = await ref.read(outboundNotifierProvider.notifier).scanPackItem(_barcodeScanController.text.trim());
                    _barcodeScanController.clear();
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Scan Error: Barcode does not match expected items!'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Verify Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Verified Scanned Items (${activeSession.scannedItems.length})', style: AppTypography.bodyBold),
          const SizedBox(height: 8),

          Expanded(
            child: activeSession.scannedItems.isEmpty
                ? Center(
                    child: Text('Scan items one by one to verify before boxing.', style: AppTypography.caption),
                  )
                : ListView.builder(
                    itemCount: activeSession.scannedItems.length,
                    itemBuilder: (context, index) {
                      final item = activeSession.scannedItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('${item.productName} (${item.barcode})', style: AppTypography.body),
                            ),
                            Text('1.0 ${item.uom}', style: AppTypography.bodyBold),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Boxes: 1 Box • Weight: 3.2 KG', style: AppTypography.bodyBold),
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await ref.read(outboundNotifierProvider.notifier).dispatchShipment(
                    weightKg: 3.2,
                    carrier: 'Universal Freight Priority',
                    boxCount: 1,
                  );
                  if (ok && context.mounted) {
                    _tabController.animateTo(3); // Jump to Shipping Manifests
                  }
                },
                icon: const Icon(Icons.local_shipping_rounded, size: 18),
                label: const Text('Seal Parcel & Generate Shipping Label'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Shipping Manifests View
  Widget _buildShippingManifestsView(BuildContext context, bool isDark, ThemeData theme) {
    final outboundState = ref.watch(outboundNotifierProvider);
    final shippedOrders = outboundState.salesOrders.where((o) => o.status == OutboundStatus.shipped || o.status == OutboundStatus.packed).toList();

    if (shippedOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('No shipments dispatched yet.', style: AppTypography.body),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: shippedOrders.length,
      itemBuilder: (context, index) {
        final order = shippedOrders[index];

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
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: AppColors.success),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order.soNumber, style: AppTypography.h3),
                        const SizedBox(width: 8),
                        _buildStatusChip(order.status, theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${order.customerName} • ${order.destinationWardOrAddress}', style: AppTypography.bodyBold),
                    const SizedBox(height: 2),
                    Text('Dispatched with Verified Barcode Manifest • \$${order.totalAmount.toStringAsFixed(2)}', style: AppTypography.caption),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final session = outboundState.activePackingSession;
                  if (session != null) {
                    showDialog(
                      context: context,
                      builder: (_) => ShippingLabelModal(session: session),
                    );
                  }
                },
                icon: const Icon(Icons.print_rounded, size: 16),
                label: const Text('View 4x6 Label (ZPL)'),
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

  Widget _buildStatusChip(OutboundStatus status, ThemeData theme) {
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
        bg = theme.colorScheme.primary.withValues(alpha: 0.15);
        fg = theme.colorScheme.primary;
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
