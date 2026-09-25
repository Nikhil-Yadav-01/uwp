import 'package:flutter/material.dart';
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
        subtitle: 'Average cost \$2.40 / sale \$16',
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
    return [
      {
        'id': 'BAR-001',
        'name': 'Macallan 18 Year Double Cask Single Malt',
        'sku': 'BAR-WHS-MAC-18Y',
        'barcode': '501031401234',
        'category': 'Scotch & Whiskey',
        'stock': 12.0,
        'uom': 'Bottle (750ml)',
        'unitPrice': 380.00,
        'customAttributes': {
          'abv_percent': 43.0,
          'volume_per_bottle_ml': 750,
          'standard_pour_ml': 45, // 1.5 oz
          'vintage': '2024 Release',
          'origin': 'Speyside, Scotland',
        },
      },
      {
        'id': 'BAR-002',
        'name': 'Hendrick\'s Scottish Gin',
        'sku': 'BAR-GIN-HEN-1L',
        'barcode': '501031409876',
        'category': 'Gin & Botanical',
        'stock': 24.0,
        'uom': 'Bottle (1L)',
        'unitPrice': 42.00,
        'customAttributes': {
          'abv_percent': 41.4,
          'volume_per_bottle_ml': 1000,
          'standard_pour_ml': 60,
          'origin': 'Girvan, Scotland',
        },
      },
      {
        'id': 'BAR-003',
        'name': 'Guinness Extra Stout Draught Keg (50L)',
        'sku': 'BAR-KEG-GN-50L',
        'barcode': '501031488888',
        'category': 'Draught Beer Kegs',
        'stock': 4.0,
        'uom': 'Keg (50L)',
        'unitPrice': 185.00,
        'customAttributes': {
          'abv_percent': 4.2,
          'tap_line_id': 'Tap #4 - Main Bar',
          'keg_volume_liters': 50,
          'pints_remaining': 88,
          'tapped_date': '2026-09-22',
        },
      },
      {
        'id': 'BAR-004',
        'name': 'Signature Old Fashioned Cocktail (BOM)',
        'sku': 'BOM-CKT-OLD-FSH',
        'barcode': 'BOM0000000001',
        'category': 'Cocktail Recipe BOM',
        'stock': 999.0, // Virtual composite
        'uom': 'Serving',
        'unitPrice': 18.00,
        'customAttributes': {
          'is_recipe_bom': true,
          'recipe_ingredients': '60ml Bourbon, 10ml Demerara Syrup, 3 Dashes Bitters',
          'cost_per_serving': 2.85,
          'margin_percent': 84.2,
        },
      },
    ];
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'Recipe Bill of Materials (BOM) Auto-Deduction on POS Sale',
      'Liquor Bottle Pour & Scale Calibration',
      'Live Draught Keg Flowmeter & Tap Level Tracking',
      'Shift Spillage, Foam Loss & Comp Bar Log with Manager Signature',
    ];
  }
}
