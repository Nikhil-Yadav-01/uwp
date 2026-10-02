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
import '../../domain/models/return_request.dart';
import '../controllers/returns_controller.dart';
import '../widgets/return_card.dart';
import '../widgets/return_form_modal.dart';

class ReturnsScreen extends ConsumerStatefulWidget {
  const ReturnsScreen({super.key});

  @override
  ConsumerState<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends ConsumerState<ReturnsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final returnsState = ref.watch(returnsNotifierProvider);
    final returnsNotifier = ref.read(returnsNotifierProvider.notifier);
    final archetype = ref.watch(archetypeProvider).archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final returns = returnsState.filteredReturns;

    final pendingCount = returnsState.returns.where((r) => r.status == ReturnStatus.pending).length;
    final approvedCount = returnsState.returns.where((r) => r.status == ReturnStatus.approved).length;
    final receivedCount = returnsState.returns.where((r) => r.status == ReturnStatus.received).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < AppSpacing.breakpointMobile;

                  final titleSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Text('Customer Returns & RTO', style: AppTypography.headlineLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: archetype.brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              '${returnsState.returns.length} Return Requests',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: archetype.brandColor),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Handle reverse logistics, return approvals, RMA inspections & warehouse restock',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final newReturnBtn = ElevatedButton.icon(
                    onPressed: () => ReturnFormModal.show(context),
                    icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                    label: const Text('New Return Request'),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        SizedBox(width: double.infinity, child: newReturnBtn),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      newReturnBtn,
                    ],
                  );
                },
              ),
              AppGap.h20,

              // 2. Stage KPI Counter Tiles
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;

                  final stage1 = _buildStageCounter('Pending Review', '$pendingCount Orders', AppColors.warning, Icons.pending_actions_outlined, isDark, colorScheme);
                  final stage2 = _buildStageCounter('Approved In-Transit', '$approvedCount Shipments', AppColors.info, Icons.local_shipping_outlined, isDark, colorScheme);
                  final stage3 = _buildStageCounter('Dock Inspection', '$receivedCount Received', const Color(0xFF6366F1), Icons.fact_check_outlined, isDark, colorScheme);

                  if (isNarrow) {
                    return Column(
                      children: [
                        stage1,
                        AppGap.h8,
                        stage2,
                        AppGap.h8,
                        stage3,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: stage1),
                      AppGap.w12,
                      Expanded(child: stage2),
                      AppGap.w12,
                      Expanded(child: stage3),
                    ],
                  );
                },
              ),
              AppGap.h16,

              // 3. Search & Filter Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by RTN#, SO#, customer name, or SKU...',
                        prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm + 4),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  returnsNotifier.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: returnsNotifier.setSearchQuery,
                    ),
                    const Divider(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Statuses'),
                            selected: returnsState.selectedStatus == null,
                            onSelected: (_) => returnsNotifier.filterByStatus(null),
                          ),
                          AppGap.w8,
                          ...ReturnStatus.values.map((s) {
                            final isSelected = returnsState.selectedStatus == s;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(s.label),
                                selected: isSelected,
                                selectedColor: s.color.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: isSelected ? s.color : null,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (_) => returnsNotifier.filterByStatus(isSelected ? null : s),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h20,

              // 4. Returns List
              if (returns.isEmpty)
                Container(
                  width: double.infinity,
                  padding: AppPadding.p32,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_return_outlined, size: AppSizes.buttonHeightMd, color: colorScheme.primary.withValues(alpha: 0.5)),
                      AppGap.h16,
                      Text('No Return Requests Found', style: AppTypography.headlineSmall),
                      AppGap.h4,
                      Text(
                        _searchController.text.isNotEmpty ? 'Try changing your search terms or status filters.' : 'Create a return request for damaged, wrong or RTO items.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      AppGap.h16,
                      ElevatedButton.icon(
                        onPressed: () => ReturnFormModal.show(context),
                        icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                        label: const Text('New Return Request'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: returns.length,
                  separatorBuilder: (context, index) => AppGap.h12,
                  itemBuilder: (context, index) {
                    final item = returns[index];
                    return ReturnCard(
                      returnRequest: item,
                      onApprove: () => returnsNotifier.approveReturn(item.id),
                      onReceive: () => returnsNotifier.receiveReturn(item.id),
                      onRestock: (bin) => returnsNotifier.restockReturn(item.id, bin),
                      onScrap: () => returnsNotifier.scrapReturn(item.id),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageCounter(String title, String count, Color color, IconData icon, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: AppPadding.p16,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          AppGap.w12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
              Text(count, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
