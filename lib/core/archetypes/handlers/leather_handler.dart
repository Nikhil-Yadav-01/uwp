import 'package:flutter/material.dart';
import '../../data/datasources/sample_data_source.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class LeatherArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.leatherAndTextiles;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'total_area',
        label: 'Total Usable Area',
        value: '42,850 sq ft',
        subtitle: 'Across 1,240 hides',
        trend: '+8.4%',
        isPositiveTrend: true,
        icon: Icons.layers_outlined,
        color: AppColors.leatherBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'grade_a_ratio',
        label: 'Full Grain (Grade A)',
        value: '68.2%',
        subtitle: '846 prime hides',
        trend: '+3.1%',
        isPositiveTrend: true,
        icon: Icons.verified_outlined,
        color: AppColors.success,
      ),
      const ArchetypeKPIMetric(
        id: 'scrap_rate',
        label: 'Scrap & Off-cut Remnants',
        value: '4.8% (2,120 sq ft)',
        subtitle: 'Off-cut bin salvageable',
        trend: '-1.2%',
        isPositiveTrend: true,
        icon: Icons.content_cut_outlined,
        color: AppColors.warning,
      ),
      const ArchetypeKPIMetric(
        id: 'dye_lots',
        label: 'Active Tannery Dye Lots',
        value: '34 Lots',
        subtitle: 'Vintage Cognac & Nero',
        trend: 'Normal',
        isPositiveTrend: true,
        icon: Icons.palette_outlined,
        color: AppColors.secondary,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'sq ft';
    final thickness = customAttributes?['thickness_oz'] != null
        ? ' (${customAttributes!['thickness_oz']} oz)'
        : '';
    return '${quantity.toStringAsFixed(1)} $unit$thickness';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['area_sq_ft'] != null && (attributes['area_sq_ft'] as num) <= 0) {
      errors['area_sq_ft'] = 'Surface area must be greater than 0 sq ft';
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
      'Leather Area & Quality Inspection at Receiving',
      'Color Batch & Dye-Lot Matching',
      'Scrap & Leftover Leather Tracking for Re-use',
      'Leather Roll Splitting & Thickness Marking',
    ];
  }
}
