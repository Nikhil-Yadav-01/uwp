import 'package:flutter/material.dart';
import '../../data/datasources/sample_data_source.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class FashionArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.fashionAndApparel;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'total_garments',
        label: 'Total Garments in Stock',
        value: '14,290 Units',
        subtitle: '1,840 Active Matrix SKUs',
        trend: '+12.4%',
        isPositiveTrend: true,
        icon: Icons.checkroom_outlined,
        color: AppColors.fashionBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'matrix_coverage',
        label: 'Matrix Size Completeness',
        value: '91.8%',
        subtitle: 'XS to XXL fully stocked',
        trend: 'High Availability',
        isPositiveTrend: true,
        icon: Icons.grid_view_rounded,
        color: AppColors.accent,
      ),
      const ArchetypeKPIMetric(
        id: 'season_turnover',
        label: 'Current Season Sell-Through',
        value: '74.2%',
        subtitle: 'Fall/Winter 2026 Season',
        trend: '+6.5%',
        isPositiveTrend: true,
        icon: Icons.auto_awesome_outlined,
        color: AppColors.success,
      ),
      const ArchetypeKPIMetric(
        id: 'return_rate',
        label: 'Customer Fit Returns',
        value: '3.4%',
        subtitle: 'Size exchange staging',
        trend: '-0.8%',
        isPositiveTrend: true,
        icon: Icons.assignment_return_outlined,
        color: AppColors.warning,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'pcs';
    final color = customAttributes?['color'];
    final size = customAttributes?['size'];
    final sizeColor = (size != null && color != null) ? ' ($color / $size)' : '';
    return '${quantity.toInt()} $unit$sizeColor';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['size'] == null) {
      errors['size'] = 'Size variant is required';
    }
    if (attributes['color'] == null) {
      errors['color'] = 'Color variant is required';
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
      'Quick Matrix Grid for Clothes (Size × Color × Fit)',
      'Clothing Hangtag & Garment Barcode Printing',
      'Seasonal Stock Rebalance Across Stores',
      'Customer Returns Inspection & Re-tagging',
    ];
  }
}
