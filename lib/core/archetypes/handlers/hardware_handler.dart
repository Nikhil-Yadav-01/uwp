import 'package:flutter/material.dart';
import '../../data/datasources/sample_data_source.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class HardwareArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.hardwareAndParts;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'oem_parts_count',
        label: 'Cataloged OEM SKUs',
        value: '28,450 Parts',
        subtitle: '100% Cross-referenced',
        trend: '+4.8%',
        isPositiveTrend: true,
        icon: Icons.build_outlined,
        color: AppColors.hardwareBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'bin_utilization',
        label: 'High-Density Bin Capacity',
        value: '84.2%',
        subtitle: '1,420 of 1,686 bins filled',
        trend: 'Optimized',
        isPositiveTrend: true,
        icon: Icons.inventory_2_outlined,
        color: AppColors.accent,
      ),
      const ArchetypeKPIMetric(
        id: 'reorder_triggers',
        label: 'Below Safety Stock Threshold',
        value: '14 SKUs',
        subtitle: 'Auto-generated PO pending',
        trend: 'Action Required',
        isPositiveTrend: false,
        icon: Icons.shopping_cart_outlined,
        color: AppColors.warning,
      ),
      const ArchetypeKPIMetric(
        id: 'hazmat_safe',
        label: 'HAZMAT Flammable Storage',
        value: '100% Compliant',
        subtitle: 'Zone H explosion-proof bay',
        trend: 'Audited',
        isPositiveTrend: true,
        icon: Icons.local_fire_department_outlined,
        color: AppColors.success,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'pcs';
    final bin = customAttributes?['bin_location'] != null
        ? ' [Bin: ${customAttributes!['bin_location']}]'
        : '';
    return '${quantity.toInt()} $unit$bin';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['oem_part_number'] == null) {
      errors['oem_part_number'] = 'OEM Part Number is required';
    }
    return errors.isEmpty ? null : errors;
  }

  @override
  List<Map<String, dynamic>> getDemoProducts() {
    return SampleDataSource.getDemoProductMaps(archetypeType);
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'Exact Shelf Location Guidance (Aisle, Rack, Shelf, Bin)',
      'Manufacturer Part Number & Compatible Car Lookup',
      'Hazardous & Chemical Storage Safety Checklist',
      'Weight Scale Check for Bulk Screws, Bolts & Hardware',
    ];
  }
}
