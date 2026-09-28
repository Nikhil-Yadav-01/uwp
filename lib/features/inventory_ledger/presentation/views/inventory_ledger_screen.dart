import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/inventory/domain/models/inventory_transaction.dart';
import '../../../../core/inventory/domain/models/stock_transfer.dart';
import '../../../../core/inventory/presentation/controllers/inventory_ledger_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../widgets/stock_adjustment_card.dart';
import '../widgets/stock_adjustment_modal.dart';
import '../widgets/stock_ledger_transaction_card.dart';
import '../widgets/stock_transfer_card.dart';
import '../widgets/stock_transfer_modal.dart';

class InventoryLedgerScreen extends ConsumerStatefulWidget {
  const InventoryLedgerScreen({super.key});

  @override
  ConsumerState<InventoryLedgerScreen> createState() => _InventoryLedgerScreenState();
}

class _InventoryLedgerScreenState extends ConsumerState<InventoryLedgerScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final ledgerState = ref.watch(inventoryLedgerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 640;

          return SingleChildScrollView(
            padding: isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Responsive Page Header
                _buildHeader(context, archetype, isDark, isMobile),
                AppGap.h20,

                // 2. Interactive Category Selector Bar
                _buildCategorySelector(ledgerState, archetype.brandColor, colorScheme, isDark, isMobile),
                AppGap.h16,

                // 3. Search & Multi-Filter Toolbar
                _buildFilterToolbar(ledgerState, colorScheme, isDark, isMobile),
                AppGap.h16,

                // 4. Fluid Category Content
                _buildSelectedCategoryContent(ledgerState, archetype.brandColor, colorScheme, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic archetype, bool isDark, bool isMobile) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Movement Ledger & Audit Trail',
          style: AppTypography.headlineLarge,
        ),
        AppGap.h4,
        Text(
          'Immutable inventory transactions, multi-depot transfers & reconciliation for ${archetype.name}',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );

    final actionsSection = Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          onPressed: () => StockAdjustmentModal.show(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          ),
          icon: const Icon(Icons.tune_rounded, size: 18),
          label: const Text('New Adjustment'),
        ),
        FilledButton.icon(
          onPressed: () => StockTransferModal.show(context),
          style: FilledButton.styleFrom(
            backgroundColor: archetype.brandColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          ),
          icon: const Icon(Icons.swap_horiz_rounded, size: 18),
          label: const Text('New WH Transfer'),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          AppGap.h12,
          actionsSection,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleSection),
        AppGap.w16,
        actionsSection,
      ],
    );
  }

  Widget _buildCategorySelector(
    LedgerState ledgerState,
    Color brandColor,
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
  ) {
    final inTransitCount = ledgerState.transfers.where((t) => t.status == TransferStatus.inTransit).length;

    final categories = [
      _LedgerCategory(
        title: 'Stock Ledger Transactions',
        count: ledgerState.transactions.length,
        icon: Icons.receipt_long_outlined,
        subtitle: 'Audit trail of movements',
      ),
      _LedgerCategory(
        title: 'Inter-Warehouse Transfers',
        count: ledgerState.transfers.length,
        badgeText: inTransitCount > 0 ? '$inTransitCount in-transit' : null,
        icon: Icons.swap_horiz_rounded,
        subtitle: 'Multi-depot dispatches',
      ),
      _LedgerCategory(
        title: 'Stock Adjustments',
        count: ledgerState.adjustments.length,
        icon: Icons.tune_rounded,
        subtitle: 'Cycle counts & variances',
      ),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            final cat = categories[index];
            final isSelected = _selectedCategoryIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                borderRadius: BorderRadius.circular(AppRadii.r8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? brandColor.withValues(alpha: 0.15) : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                    border: Border.all(
                      color: isSelected ? brandColor : colorScheme.outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 16, color: isSelected ? brandColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      AppGap.w8,
                      Text(
                        cat.title,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? brandColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                      AppGap.w8,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? brandColor : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${cat.count}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

        return Row(
          children: List.generate(categories.length, (index) {
            final cat = categories[index];
            final isSelected = _selectedCategoryIndex == index;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < categories.length - 1 ? 12.0 : 0),
                child: Material(
                  color: isSelected ? brandColor.withValues(alpha: 0.08) : colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                    child: Container(
                      padding: AppPadding.p16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.r12),
                        border: Border.all(
                          color: isSelected ? brandColor : colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isSelected ? brandColor : colorScheme.primary).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadii.r8),
                                ),
                                child: Icon(cat.icon, size: 18, color: isSelected ? brandColor : colorScheme.primary),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected ? brandColor : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${cat.count}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppGap.h12,
                          Text(
                            cat.title,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? brandColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isNarrow) ...[
                            AppGap.h4,
                            Text(
                              cat.badgeText ?? cat.subtitle,
                              style: AppTypography.bodySmall.copyWith(
                                color: cat.badgeText != null ? AppColors.warning : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                fontWeight: cat.badgeText != null ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildFilterToolbar(LedgerState ledgerState, ColorScheme colorScheme, bool isDark, bool isMobile) {
    final searchField = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: _selectedCategoryIndex == 0
            ? 'Search SKU, product name, PO/SO # or bin...'
            : (_selectedCategoryIndex == 1 ? 'Search transfer #, carrier, SKU or depot...' : 'Search adjustment #, reason or SKU...'),
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
    );

    if (_selectedCategoryIndex != 0) {
      return searchField;
    }

    final typeDropdown = DropdownButtonFormField<InventoryTransactionType?>(
      initialValue: ledgerState.selectedType,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Filter Movement Type'),
      items: [
        const DropdownMenuItem(value: null, child: Text('All Movement Types', maxLines: 1, overflow: TextOverflow.ellipsis)),
        ...InventoryTransactionType.values.map(
          (type) => DropdownMenuItem(value: type, child: Text(type.displayName, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ),
      ],
      onChanged: (val) => ref.read(inventoryLedgerProvider.notifier).filterType(val),
    );

    if (isMobile) {
      return Column(
        children: [
          searchField,
          AppGap.h12,
          typeDropdown,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 6, child: searchField),
        AppGap.w12,
        Expanded(flex: 4, child: typeDropdown),
      ],
    );
  }

  Widget _buildSelectedCategoryContent(
    LedgerState ledgerState,
    Color brandColor,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildTransactionsList(ledgerState);
      case 1:
        return _buildTransfersList(ledgerState);
      case 2:
        return _buildAdjustmentsList(ledgerState);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTransactionsList(LedgerState ledgerState) {
    final transactions = ledgerState.transactions;

    if (transactions.isEmpty) {
      return _buildEmptyState('No stock transactions found matching search / filter criteria.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        return StockLedgerTransactionCard(transaction: transactions[index]);
      },
    );
  }

  Widget _buildTransfersList(LedgerState ledgerState) {
    final transfers = ledgerState.transfers;

    if (transfers.isEmpty) {
      return _buildEmptyState('No inter-warehouse transfers recorded.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transfers.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        return StockTransferCard(transfer: transfers[index]);
      },
    );
  }

  Widget _buildAdjustmentsList(LedgerState ledgerState) {
    final adjustments = ledgerState.adjustments;

    if (adjustments.isEmpty) {
      return _buildEmptyState('No stock adjustments recorded.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adjustments.length,
      separatorBuilder: (context, index) => AppGap.h12,
      itemBuilder: (context, index) {
        return StockAdjustmentCard(adjustment: adjustments[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: AppSizes.iconLg, color: AppColors.textSecondaryLight),
            AppGap.h12,
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerCategory {
  final String title;
  final int count;
  final String? badgeText;
  final IconData icon;
  final String subtitle;

  _LedgerCategory({
    required this.title,
    required this.count,
    this.badgeText,
    required this.icon,
    required this.subtitle,
  });
}
