import 'package:flutter/material.dart';
import '../../data/datasources/sample_data_source.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class HospitalityArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.barsAndHospitality;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'spirit_volume',
        label: 'Liquor Stock On Hand',
        value: '385.4 Liters',
        subtitle: '514 Premium Bottles',
        trend: '+4.2%',
        isPositiveTrend: true,
        icon: Icons.wine_bar_outlined,
        color: AppColors.hospitalityBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'keg_taps',
        label: 'Live Draught Beer Taps',
        value: '12 / 12 Active',
        subtitle: 'Average 48% remaining',
        trend: 'Normal Flow',
        isPositiveTrend: true,
        icon: Icons.sports_bar_outlined,
        color: AppColors.warning,
      ),
      const ArchetypeKPIMetric(
        id: 'recipe_margin',
        label: 'Cocktail BOM Margin',
        value: '78.5%',
        subtitle: 'Average cost ₹2.40 / sale ₹16',
        trend: '+1.5%',
        isPositiveTrend: true,
        icon: Icons.calculate_outlined,
        color: AppColors.success,
      ),
      const ArchetypeKPIMetric(
        id: 'spillage_loss',
        label: 'Daily Spillage & Tasting',
        value: '1.2% (1.8L)',
        subtitle: 'Within 2.0% bar tolerance',
        trend: 'Logged',
        isPositiveTrend: true,
        icon: Icons.water_drop_outlined,
        color: AppColors.secondary,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'ml';
    final abv = customAttributes?['abv_percent'] != null
        ? ' (${customAttributes!['abv_percent']}% ABV)'
        : '';
    return '${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 1)} $unit$abv';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['abv_percent'] != null) {
      final abv = attributes['abv_percent'] as num;
      if (abv < 0 || abv > 100) {
        errors['abv_percent'] = 'ABV must be between 0 and 100%';
      }
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
      'Automatic Cocktail Recipe Deductions on Counter Sale',
      'Liquor Bottle Pour & Scale Check',
      'Live Beer Keg & Tap Level Monitoring',
      'Spillage, Foam Loss & Drink Waste Tracking',
    ];
  }
}
