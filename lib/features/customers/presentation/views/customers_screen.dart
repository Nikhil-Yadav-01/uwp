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
import '../../domain/models/customer.dart';
import '../controllers/customer_controller.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_form_modal.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerNotifierProvider);
    final customerNotifier = ref.read(customerNotifierProvider.notifier);
    final archetype = ref.watch(archetypeProvider).archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final customers = customerState.filteredCustomers;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Responsive.constrainedContent(
        child: SingleChildScrollView(
          padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Bar
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
                          Text('Customers & Accounts', style: AppTypography.headlineLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: archetype.brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              '${customerState.customers.length} Accounts',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: archetype.brandColor),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Customer master data, GSTIN validation, credit limits & shipping addresses',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final addCustomerBtn = ElevatedButton.icon(
                    onPressed: () => CustomerFormModal.show(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: AppSizes.iconSm),
                    label: const Text('Add Customer'),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        SizedBox(width: double.infinity, child: addCustomerBtn),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      addCustomerBtn,
                    ],
                  );
                },
              ),
              AppGap.h20,

              // 2. Search & Filter Bar
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
                        hintText: 'Search customer name, contact person, code, GSTIN, or city...',
                        prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm + 4),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  customerNotifier.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: customerNotifier.setSearchQuery,
                    ),
                    const Divider(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Tiers'),
                            selected: customerState.selectedTier == null,
                            onSelected: (_) => customerNotifier.filterByTier(null),
                          ),
                          AppGap.w8,
                          ...CustomerTier.values.map((tier) {
                            final isSelected = customerState.selectedTier == tier;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(tier.label),
                                selected: isSelected,
                                selectedColor: tier.color.withValues(alpha: 0.15),
                                labelStyle: TextStyle(
                                  color: isSelected ? tier.color : null,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (_) => customerNotifier.filterByTier(isSelected ? null : tier),
                              ),
                            );
                          }),
                          AppGap.w8,
                          FilterChip(
                            label: Text(
                              customerState.activeOnly == null
                                  ? 'Status: All'
                                  : (customerState.activeOnly! ? 'Active Only' : 'Inactive Only'),
                              style: const TextStyle(fontSize: 11),
                            ),
                            selected: customerState.activeOnly != null,
                            onSelected: (_) => customerNotifier.toggleActiveOnly(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h20,

              // 3. Customer List
              if (customers.isEmpty)
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
                      Icon(Icons.people_outline_rounded, size: AppSizes.buttonHeightMd, color: colorScheme.primary.withValues(alpha: 0.5)),
                      AppGap.h16,
                      Text('No Customers Found', style: AppTypography.headlineSmall),
                      AppGap.h4,
                      Text(
                        _searchController.text.isNotEmpty ? 'Try changing your search terms or tier filters.' : 'Add your first customer account to get started.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      AppGap.h16,
                      ElevatedButton.icon(
                        onPressed: () => CustomerFormModal.show(context),
                        icon: const Icon(Icons.person_add_alt_1_rounded, size: AppSizes.iconSm),
                        label: const Text('Add Customer'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customers.length,
                  separatorBuilder: (context, index) => AppGap.h12,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return CustomerCard(
                      customer: customer,
                      onToggleStatus: () => customerNotifier.toggleStatus(customer.id),
                      onDelete: () => customerNotifier.deleteCustomer(customer.id),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
