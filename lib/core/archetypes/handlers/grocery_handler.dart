import 'package:flutter/material.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class GroceryArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.groceryAndPerishables;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'critical_expiry',
        label: 'Expiring in ≤ 3 Days',
        value: '18 Batches',
        subtitle: 'FEFO dynamic discount applied',
        trend: 'Urgent Action',
        isPositiveTrend: false,
        icon: Icons.warning_amber_rounded,
        color: AppColors.error,
      ),
      const ArchetypeKPIMetric(
        id: 'cold_chain_status',
        label: 'Cold-Chain Telemetry',
        value: '-18.4°C / +3.8°C',
        subtitle: 'All 6 freezers in spec',
        trend: 'Optimal',
        isPositiveTrend: true,
        icon: Icons.ac_unit_rounded,
        color: AppColors.groceryBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'fefo_compliance',
        label: 'FEFO Picking Accuracy',
        value: '99.4%',
        subtitle: 'Oldest batch picked first',
        trend: '+0.8%',
        isPositiveTrend: true,
        icon: Icons.access_time_rounded,
        color: AppColors.accent,
      ),
      const ArchetypeKPIMetric(
        id: 'spoilage_loss',
        label: 'Spoilage & Waste Rate',
        value: '0.42%',
        subtitle: 'Below 1.5% target',
        trend: '-0.15%',
        isPositiveTrend: true,
        icon: Icons.trending_down_rounded,
        color: AppColors.success,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'kg';
    final expiry = customAttributes?['expiry_date'] != null
        ? ' (Exp: ${customAttributes!['expiry_date']})'
        : '';
    return '${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 2)} $unit$expiry';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['batch_no'] == null || (attributes['batch_no'] as String).isEmpty) {
      errors['batch_no'] = 'Batch number is mandatory for perishables';
    }
    if (attributes['expiry_date'] == null) {
      errors['expiry_date'] = 'Expiration date is mandatory';
    }
    return errors.isEmpty ? null : errors;
  }

  @override
  List<Map<String, dynamic>> getDemoProducts() {
    return [
      {
        'id': 'GRO-001',
        'name': 'Organic Hass Avocados (Grade 1)',
        'sku': 'GRO-AVO-HASS-40',
        'barcode': '890200001001',
        'category': 'Fresh Produce',
        'stock': 120.0,
        'uom': 'Carton (40ct)',
        'unitPrice': 38.00,
        'customAttributes': {
          'batch_no': 'BATCH-AVO-20260920',
          'harvest_date': '2026-09-18',
          'expiry_date': '2026-09-29 (4 Days)',
          'storage_zone': 'Chilled (+4°C)',
          'origin': 'Michoacán, Mexico',
        },
      },
      {
        'id': 'GRO-002',
        'name': 'Pasteurized Whole Milk 3.8% (1L)',
        'sku': 'GRO-DAIRY-MLK-1L',
        'barcode': '890200001002',
        'category': 'Dairy & Eggs',
        'stock': 850.0,
        'uom': 'Bottle (1L)',
        'unitPrice': 1.85,
        'customAttributes': {
          'batch_no': 'MLK-LOT-984',
          'expiry_date': '2026-09-28 (3 Days)',
          'storage_zone': 'Cold Walk-in (+2°C)',
          'origin': 'Local Farm Collective',
        },
      },
      {
        'id': 'GRO-003',
        'name': 'Wild Caught Atlantic Salmon Fillet',
        'sku': 'GRO-SEA-SLM-KG',
        'barcode': '890200001003',
        'category': 'Seafood & Meat',
        'stock': 45.5,
        'uom': 'kg',
        'unitPrice': 24.50,
        'customAttributes': {
          'batch_no': 'SEA-SLM-NOR-441',
          'expiry_date': '2026-09-27 (2 Days)',
          'storage_zone': 'Deep Freeze (-20°C)',
          'origin': 'Norway',
        },
      },
      {
        'id': 'GRO-004',
        'name': 'Artisan Sourdough Loaf (750g)',
        'sku': 'GRO-BAK-SRD-750',
        'barcode': '890200001004',
        'category': 'Bakery',
        'stock': 65.0,
        'uom': 'Loaf',
        'unitPrice': 4.20,
        'customAttributes': {
          'batch_no': 'BAK-SRD-DAILY-01',
          'expiry_date': '2026-09-26 (Tomorrow)',
          'storage_zone': 'Ambient Shelf',
          'origin': 'In-house Bakery',
        },
      },
    ];
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'Strict FEFO (First-Expired, First-Out) Pick Allocation',
      'Cold-Chain BLE Sensor Temperature Logging',
      'Dynamic Shelf-Life Markdown Pricing Engine',
      'Zero-Waste Spoilage & Donation Staging',
    ];
  }
}
