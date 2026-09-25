import 'package:flutter/material.dart';
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
    return [
      {
        'id': 'LTH-001',
        'name': 'Italian Full Grain Veg-Tan Hide',
        'sku': 'LTH-IT-VGT-01',
        'barcode': '890123450001',
        'category': 'Full Grain Leather',
        'stock': 480.5,
        'uom': 'sq ft',
        'unitPrice': 14.50,
        'customAttributes': {
          'tannery_origin': 'Tuscany, Italy',
          'dye_lot': 'LOT-2026-COGNAC',
          'grade': 'Grade A (Prime)',
          'thickness_oz': '4.5 - 5.0 oz (1.8mm)',
          'temper': 'Medium Firm',
        },
      },
      {
        'id': 'LTH-002',
        'name': 'Horween Chromexcel Cowhide',
        'sku': 'LTH-HW-CXL-BLK',
        'barcode': '890123450002',
        'category': 'Pull-up Leather',
        'stock': 620.0,
        'uom': 'sq ft',
        'unitPrice': 16.80,
        'customAttributes': {
          'tannery_origin': 'Chicago, USA',
          'dye_lot': 'LOT-CXL-NERO-09',
          'grade': 'Grade A',
          'thickness_oz': '5.0 - 5.5 oz (2.0mm)',
          'temper': 'Supple',
        },
      },
      {
        'id': 'LTH-003',
        'name': 'Nubuck Suede Side Roll',
        'sku': 'LTH-NBK-SD-TN',
        'barcode': '890123450003',
        'category': 'Suede & Nubuck',
        'stock': 310.2,
        'uom': 'sq ft',
        'unitPrice': 9.20,
        'customAttributes': {
          'tannery_origin': 'Leon, Mexico',
          'dye_lot': 'LOT-NBK-DESERT-4',
          'grade': 'Grade B',
          'thickness_oz': '3.0 - 3.5 oz (1.3mm)',
          'temper': 'Soft',
        },
      },
      {
        'id': 'LTH-004',
        'name': 'Artisan Scrap & Remnant Off-Cuts',
        'sku': 'LTH-SCRAP-KG-01',
        'barcode': '890123450004',
        'category': 'Scrap & Off-cuts',
        'stock': 145.0,
        'uom': 'kg',
        'unitPrice': 6.00,
        'customAttributes': {
          'tannery_origin': 'Assorted',
          'dye_lot': 'MIXED-SCRAP-BIN',
          'grade': 'Remnant Cuts',
          'thickness_oz': 'Mixed',
          'temper': 'Assorted',
        },
      },
    ];
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'Digital Surface Area & Grading Inspection Gate',
      'Dye-Lot Color Uniformity Matching',
      'Remnant & Scrap Weight Auto-Deduction',
      'Roll Splitting & Thickness Stamping',
    ];
  }
}
