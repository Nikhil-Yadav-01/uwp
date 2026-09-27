import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/inventory/domain/models/inventory_transaction.dart';
import '../../../../core/inventory/domain/models/stock_transfer.dart';
import '../../../../core/inventory/domain/models/stock_adjustment.dart';
import '../../../../core/inventory/presentation/controllers/inventory_ledger_controller.dart';
import '../../../../core/master_data/data/repositories/in_memory_master_data_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../widgets/stock_transfer_modal.dart';
import '../widgets/stock_adjustment_modal.dart';

class InventoryLedgerScreen extends ConsumerStatefulWidget {
  const InventoryLedgerScreen({super.key});

  @override
  ConsumerState<InventoryLedgerScreen> createState() => _InventoryLedgerScreenState();
}

class _InventoryLedgerScreenState extends ConsumerState<InventoryLedgerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final ledgerState = ref.watch(inventoryLedgerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warehouses = InMemoryMasterDataRepository().getWarehouses();

    return Scaffold(
      body: SingleChildScrollView(
        padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Movement Ledger & Audit Trail', style: AppTypography.h1),
                    const SizedBox(height: 4),
                    Text(
                      'Immutable inventory transactions, multi-depot transfers & reconciliation for ${archetype.name}',
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
                          builder: (context) => const StockAdjustmentModal(),
                        );
                      },
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('New Adjustment'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const StockTransferModal(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: archetype.brandColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('New WH Transfer'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Top Summary KPI Metrics
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isDesktop ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isDesktop ? 2.3 : 1.8,
                  children: [
                    _buildKpiCard('Total Transactions', '${ledgerState.transactions.length}', Icons.receipt_long_outlined, AppColors.info, isDark),
                    _buildKpiCard('Active Transfers', '${ledgerState.transfers.where((t) => t.status == TransferStatus.inTransit).length} In-Transit', Icons.local_shipping_outlined, const Color(0xFF8B5CF6), isDark),
                    _buildKpiCard('Adjustments Logged', '${ledgerState.adjustments.length}', Icons.tune_rounded, AppColors.warning, isDark),
                    _buildKpiCard('Active Depots', '${warehouses.length} Warehouses', Icons.warehouse_outlined, AppColors.success, isDark),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Navigation Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: archetype.brandColor,
              unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              indicatorColor: archetype.brandColor,
              tabs: [
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.list_alt_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text('Stock Ledger (${ledgerState.transactions.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text('Inter-Warehouse Transfers (${ledgerState.transfers.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text('Stock Adjustments (${ledgerState.adjustments.length})'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),

            // Tab Content
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLedgerTab(ledgerState, archetype.brandColor, isDark, warehouses),
                  _buildTransfersTab(ledgerState, archetype.brandColor, isDark),
                  _buildAdjustmentsTab(ledgerState, archetype.brandColor, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.h3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTab(LedgerState ledgerState, Color brandColor, bool isDark, List<dynamic> warehouses) {
    return Column(
      children: [
        // Filter Bar
        Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search SKU, product name, PO/SO # or bin...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(inventoryLedgerProvider.notifier).search('');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => ref.read(inventoryLedgerProvider.notifier).search(val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<InventoryTransactionType?>(
                initialValue: ledgerState.selectedType,
                decoration: const InputDecoration(labelText: 'Filter by Movement Type'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Movement Types')),
                  ...InventoryTransactionType.values.map(
                    (type) => DropdownMenuItem(value: type, child: Text(type.displayName)),
                  ),
                ],
                onChanged: (val) => ref.read(inventoryLedgerProvider.notifier).filterType(val),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Ledger Data Table
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: ledgerState.transactions.isEmpty
                ? const Center(child: Text('No stock transactions found matching criteria.'))
                : ListView.separated(
                    itemCount: ledgerState.transactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final tx = ledgerState.transactions[index];
                      final isAdd = tx.transactionType.isAddition;

                      return ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: tx.transactionType.badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: tx.transactionType.badgeColor),
                          ),
                          child: Text(
                            tx.transactionType.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: tx.transactionType.badgeColor,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(tx.productName, style: AppTypography.bodyBold),
                            const SizedBox(width: 8),
                            Text('(${tx.sku})', style: AppTypography.caption),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text('${tx.warehouseName} • ${tx.locationId}', style: AppTypography.caption),
                            const SizedBox(width: 12),
                            Text('Ref: ${tx.referenceType} #${tx.referenceId}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text('• ${tx.notes}', style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isAdd ? "+" : "-"}${tx.quantity} ${tx.uom}',
                              style: AppTypography.h3.copyWith(
                                color: isAdd ? AppColors.success : (tx.transactionType == InventoryTransactionType.damage ? AppColors.error : AppColors.warning),
                              ),
                            ),
                            Text(
                              'Bal: ${tx.balanceAfter} ${tx.uom}',
                              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransfersTab(LedgerState ledgerState, Color brandColor, bool isDark) {
    if (ledgerState.transfers.isEmpty) {
      return const Center(child: Text('No inter-warehouse transfers logged.'));
    }

    return ListView.builder(
      itemCount: ledgerState.transfers.length,
      itemBuilder: (context, index) {
        final transfer = ledgerState.transfers[index];
        final isInTransit = transfer.status == TransferStatus.inTransit;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(transfer.transferNumber, style: AppTypography.h3),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: transfer.status.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: transfer.status.color),
                          ),
                          child: Text(
                            transfer.status.displayName,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: transfer.status.color),
                          ),
                        ),
                      ],
                    ),
                    if (isInTransit)
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(inventoryLedgerProvider.notifier).updateTransferStatus(transfer.transferId, TransferStatus.completed);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Transfer ${transfer.transferNumber} received at ${transfer.destinationWarehouseName}'), backgroundColor: Colors.green),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Receive & Put Away'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From (Origin):', style: AppTypography.caption),
                          Text(transfer.originWarehouseName, style: AppTypography.bodyBold),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('To (Destination):', style: AppTypography.caption),
                          Text(transfer.destinationWarehouseName, style: AppTypography.bodyBold),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text('Transferred Items:', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                ...transfer.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.productName} (${item.sku})', style: AppTypography.body),
                        Text('${item.quantity} ${item.uom}', style: AppTypography.bodyBold.copyWith(color: brandColor)),
                      ],
                    ),
                  );
                }),
                if (transfer.carrier != null) ...[
                  const SizedBox(height: 8),
                  Text('Carrier: ${transfer.carrier} • Tracking: ${transfer.trackingNumber ?? "N/A"}', style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdjustmentsTab(LedgerState ledgerState, Color brandColor, bool isDark) {
    if (ledgerState.adjustments.isEmpty) {
      return const Center(child: Text('No stock adjustments recorded.'));
    }

    return ListView.builder(
      itemCount: ledgerState.adjustments.length,
      itemBuilder: (context, index) {
        final adj = ledgerState.adjustments[index];
        final isLoss = adj.varianceQuantity < 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLoss ? Colors.red.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(adj.reason.icon, color: isLoss ? Colors.red : Colors.green, size: 20),
            ),
            title: Row(
              children: [
                Text(adj.adjustmentNumber, style: AppTypography.bodyBold),
                const SizedBox(width: 8),
                Text('• ${adj.reason.displayName}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            subtitle: Text('${adj.productName} (${adj.sku}) • Location: ${adj.locationId}\nNotes: ${adj.notes ?? "Audited physical recount"}'),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${adj.varianceQuantity >= 0 ? "+" : ""}${adj.varianceQuantity} ${adj.uom}',
                  style: AppTypography.h3.copyWith(color: isLoss ? Colors.red : Colors.green),
                ),
                Text('Physical: ${adj.physicalQuantity}', style: AppTypography.caption),
              ],
            ),
          ),
        );
      },
    );
  }
}
