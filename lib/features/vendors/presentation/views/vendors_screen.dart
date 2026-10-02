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
import '../../domain/models/vendor.dart';
import '../controllers/vendor_controller.dart';
import '../widgets/vendor_card.dart';
import '../widgets/vendor_form_modal.dart';

class VendorsScreen extends ConsumerStatefulWidget {
  const VendorsScreen({super.key});

  @override
  ConsumerState<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends ConsumerState<VendorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorState = ref.watch(vendorNotifierProvider);
    final vendorNotifier = ref.read(vendorNotifierProvider.notifier);
    final archetype = ref.watch(archetypeProvider).archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final vendors = vendorState.filteredVendors;

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
                          Text('Vendors & Suppliers', style: AppTypography.headlineLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: archetype.brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              '${vendorState.vendors.length} Suppliers',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: archetype.brandColor),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Supplier master data, payment terms, delivery lead times & GSTIN compliance',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final addVendorBtn = ElevatedButton.icon(
                    onPressed: () => VendorFormModal.show(context),
                    icon: const Icon(Icons.add_business_rounded, size: AppSizes.iconSm),
                    label: const Text('Add Vendor'),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        SizedBox(width: double.infinity, child: addVendorBtn),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      addVendorBtn,
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
                        hintText: 'Search vendor name, contact person, code, GSTIN, or city...',
                        prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSm + 4),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  vendorNotifier.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: vendorNotifier.setSearchQuery,
                    ),
                    const Divider(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Terms'),
                            selected: vendorState.selectedTerms == null,
                            onSelected: (_) => vendorNotifier.filterByTerms(null),
                          ),
                          AppGap.w8,
                          ...PaymentTerms.values.map((term) {
                            final isSelected = vendorState.selectedTerms == term;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(term.label),
                                selected: isSelected,
                                onSelected: (_) => vendorNotifier.filterByTerms(isSelected ? null : term),
                              ),
                            );
                          }),
                          AppGap.w8,
                          FilterChip(
                            label: Text(
                              vendorState.activeOnly == null
                                  ? 'Status: All'
                                  : (vendorState.activeOnly! ? 'Active Only' : 'Inactive Only'),
                              style: const TextStyle(fontSize: 11),
                            ),
                            selected: vendorState.activeOnly != null,
                            onSelected: (_) => vendorNotifier.toggleActiveOnly(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h20,

              // 3. Vendor List
              if (vendors.isEmpty)
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
                      Icon(Icons.storefront_outlined, size: AppSizes.buttonHeightMd, color: colorScheme.primary.withValues(alpha: 0.5)),
                      AppGap.h16,
                      Text('No Vendors Found', style: AppTypography.headlineSmall),
                      AppGap.h4,
                      Text(
                        _searchController.text.isNotEmpty ? 'Try changing your search terms or payment filters.' : 'Add your first supplier profile to get started.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      AppGap.h16,
                      ElevatedButton.icon(
                        onPressed: () => VendorFormModal.show(context),
                        icon: const Icon(Icons.add_business_rounded, size: AppSizes.iconSm),
                        label: const Text('Add Vendor'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vendors.length,
                  separatorBuilder: (context, index) => AppGap.h12,
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return VendorCard(
                      vendor: vendor,
                      onToggleStatus: () => vendorNotifier.toggleStatus(vendor.id),
                      onDelete: () => vendorNotifier.deleteVendor(vendor.id),
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
