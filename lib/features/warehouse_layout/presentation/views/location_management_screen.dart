import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/master_data/domain/models/master_data_models.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../controllers/location_controller.dart';

class LocationManagementScreen extends ConsumerStatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  ConsumerState<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends ConsumerState<LocationManagementScreen> {
  int _activeViewTab = 0; // 0 = Location Hierarchy, 1 = Warehouses List

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);
    final archetype = ref.watch(archetypeProvider).archetype;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeWarehouse = locationState.activeWarehouse;
    final activeBin = locationState.activeBin;

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
                          Text('Warehouse & Location Hierarchy', style: AppTypography.headlineLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: archetype.brandColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadii.r4),
                            ),
                            child: Text(
                              '${locationState.warehouses.length} Facilities',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: archetype.brandColor),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h4,
                      Text(
                        'Manage warehouses, zones, racks, shelves, and high-density storage bins',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );

                  final addWhButton = ElevatedButton.icon(
                    onPressed: () => _showAddWarehouseModal(context),
                    icon: const Icon(Icons.add_business_rounded, size: AppSizes.iconSm),
                    label: const Text('Add Warehouse'),
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        AppGap.h12,
                        SizedBox(width: double.infinity, child: addWhButton),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      AppGap.w16,
                      addWhButton,
                    ],
                  );
                },
              ),
              AppGap.h20,

              // 2. View Mode Tabs (Hierarchy vs Warehouse List)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Zone / Rack / Bin Hierarchy'),
                    selected: _activeViewTab == 0,
                    avatar: const Icon(Icons.account_tree_outlined, size: 16),
                    onSelected: (_) => setState(() => _activeViewTab = 0),
                  ),
                  ChoiceChip(
                    label: const Text('All Warehouses Table'),
                    selected: _activeViewTab == 1,
                    avatar: const Icon(Icons.warehouse_outlined, size: 16),
                    onSelected: (_) => setState(() => _activeViewTab = 1),
                  ),
                ],
              ),
              AppGap.h16,

              if (_activeViewTab == 0) ...[
                // Warehouse Selector Dropdown / Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: locationState.warehouses.map((wh) {
                      final isSelected = wh.warehouseId == locationState.selectedWarehouseId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Icon(Icons.warehouse_outlined, size: 16, color: isSelected ? Colors.white : null),
                          label: Text('${wh.code} (${wh.city})'),
                          selected: isSelected,
                          selectedColor: archetype.brandColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => locationNotifier.selectWarehouse(wh.warehouseId),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                AppGap.h16,

                // 3. Location Structure (Left Tree + Right Bin Card)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 850;

                    final hierarchyTree = _buildHierarchyTree(
                      context,
                      activeWarehouse,
                      locationState,
                      locationNotifier,
                      archetype.brandColor,
                      isDark,
                      colorScheme,
                    );

                    final binDetailsCard = _buildBinDetailsCard(
                      context,
                      activeBin,
                      archetype.brandColor,
                      isDark,
                      colorScheme,
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: hierarchyTree),
                          AppGap.w16,
                          Expanded(flex: 4, child: binDetailsCard),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        hierarchyTree,
                        AppGap.h16,
                        binDetailsCard,
                      ],
                    );
                  },
                ),
              ] else ...[
                // Warehouses Table View (Screen 3)
                _buildWarehousesTableView(locationState.warehouses, archetype.brandColor, isDark, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHierarchyTree(
    BuildContext context,
    WarehouseNode warehouse,
    LocationState state,
    LocationNotifier notifier,
    Color brandColor,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_tree_outlined, size: 20, color: AppColors.primary),
                  AppGap.w8,
                  Text('Location Hierarchy', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _showAddBinModal(context, warehouse),
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add_box_outlined, size: 16),
                label: const Text('Add Bin'),
              ),
            ],
          ),
          AppGap.h4,
          Text(
            'Warehouse: ${warehouse.name} (${warehouse.address})',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 24),

          if (warehouse.zones.isEmpty)
            Padding(
              padding: AppPadding.p16,
              child: Center(
                child: Text('No storage zones defined in this warehouse.', style: AppTypography.bodySmall),
              ),
            )
          else
            ...warehouse.zones.map((zone) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: const Icon(Icons.layers_outlined, size: 20, color: AppColors.primary),
                    title: Text(zone.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('${zone.racks.length} Racks • ${zone.description}', style: const TextStyle(fontSize: 11)),
                    children: zone.racks.map((rack) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: AppPadding.p8,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.view_week_outlined, size: 16, color: AppColors.info),
                                AppGap.w8,
                                Text(rack.rackId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                AppGap.w8,
                                Text('(${rack.totalShelves} Shelves)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                              ],
                            ),
                            AppGap.h8,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: rack.bins.map((bin) {
                                final isSelected = bin.binId == state.selectedBinId;
                                final isOccupied = bin.currentOccupancyPercent >= 70;

                                return InkWell(
                                  onTap: () => notifier.selectBin(bin.binId),
                                  borderRadius: BorderRadius.circular(AppRadii.r6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? brandColor.withValues(alpha: 0.15)
                                          : (isOccupied ? AppColors.warning.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1)),
                                      borderRadius: BorderRadius.circular(AppRadii.r6),
                                      border: Border.all(
                                        color: isSelected
                                            ? brandColor
                                            : (isOccupied ? AppColors.warning : AppColors.success),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inbox_rounded,
                                          size: 14,
                                          color: isSelected ? brandColor : (isOccupied ? AppColors.warning : AppColors.success),
                                        ),
                                        AppGap.w6,
                                        Text(
                                          'Bin ${bin.binId}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? brandColor : null,
                                          ),
                                        ),
                                        AppGap.w4,
                                        Text(
                                          '(${bin.currentOccupancyPercent.toInt()}%)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isOccupied ? AppColors.warning : AppColors.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBinDetailsCard(
    BuildContext context,
    WarehouseBin? bin,
    Color brandColor,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (bin == null) {
      return Container(
        padding: AppPadding.p24,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: const Center(
          child: Text('Select a bin in the hierarchy tree to inspect details.'),
        ),
      );
    }

    final isAvailable = bin.currentOccupancyPercent < 80;

    return Container(
      padding: AppPadding.p20,
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
              Text('Bin Details', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isAvailable ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.r4),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Occupied',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Bin Code Banner
          Container(
            padding: AppPadding.p12,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: brandColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_2_rounded, size: 36, color: brandColor),
                AppGap.w12,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bin Code: ${bin.binId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Barcode: ${bin.barcode}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ],
            ),
          ),
          AppGap.h16,

          // Occupancy Progress
          Text('Capacity Utilization', style: AppTypography.labelSmall),
          AppGap.h4,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: bin.currentOccupancyPercent / 100.0,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              color: bin.currentOccupancyPercent > 80 ? AppColors.error : brandColor,
            ),
          ),
          AppGap.h4,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${bin.currentOccupancyPercent.toInt()}% Used', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Text('Max Capacity: ${bin.maxWeightKg.toInt()} kg', style: const TextStyle(fontSize: 11)),
            ],
          ),
          AppGap.h16,

          _buildDetailRow('Rack ID', bin.rackId),
          _buildDetailRow('Zone ID', bin.zoneId),
          _buildDetailRow('Climate Controlled', bin.isColdZone ? 'Yes (Cold Vault)' : 'No (Ambient)'),
          _buildDetailRow('HAZMAT Approved', bin.isHazmatZone ? 'Yes' : 'No'),
          AppGap.h20,

          // Printable Barcode Tag action
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Printed Barcode Label for Bin ${bin.binId} (ZPL / Zebra Format)'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Print Bin QR / Barcode Tag'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildWarehousesTableView(
    List<WarehouseNode> warehouses,
    Color brandColor,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registered Warehouse Facilities', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          AppGap.h12,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('WH ID')),
                DataColumn(label: Text('Code / Name')),
                DataColumn(label: Text('Location City')),
                DataColumn(label: Text('Total Zones')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Status')),
              ],
              rows: warehouses.map((wh) {
                return DataRow(
                  cells: [
                    DataCell(Text(wh.warehouseId, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('${wh.code} - ${wh.name}')),
                    DataCell(Text(wh.city)),
                    DataCell(Text('${wh.zones.length} Zones')),
                    DataCell(Text(wh.isCentralHub ? 'Central Hub' : 'Regional Depot')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWarehouseModal(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Warehouse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Warehouse Code (e.g. WH-005)')),
            AppGap.h8,
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Warehouse Facility Name')),
            AppGap.h8,
            TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City / Region')),
            AppGap.h8,
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Street Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (codeCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                ref.read(locationNotifierProvider.notifier).addWarehouse(
                      code: codeCtrl.text.trim(),
                      name: nameCtrl.text.trim(),
                      address: addressCtrl.text.trim(),
                      city: cityCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Facility'),
          ),
        ],
      ),
    );
  }

  void _showAddBinModal(BuildContext context, WarehouseNode warehouse) {
    final binCodeCtrl = TextEditingController();
    final zone = warehouse.zones.isNotEmpty ? warehouse.zones.first : null;
    final rack = (zone != null && zone.racks.isNotEmpty) ? zone.racks.first : null;

    if (zone == null || rack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please define at least one zone and rack first.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Storage Bin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: binCodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Bin Code',
                hintText: 'e.g. A01-02-03',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (binCodeCtrl.text.isNotEmpty) {
                ref.read(locationNotifierProvider.notifier).addBin(
                      warehouseId: warehouse.warehouseId,
                      zoneId: zone.zoneId,
                      rackId: rack.rackId,
                      binCode: binCodeCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create Bin'),
          ),
        ],
      ),
    );
  }
}
