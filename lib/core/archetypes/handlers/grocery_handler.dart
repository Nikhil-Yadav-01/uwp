import 'package:flutter/material.dart';
import '../../data/datasources/sample_data_source.dart';
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
    return SampleDataSource.getDemoProductMaps(archetypeType);
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'Sell Oldest Expiry First (FEFO) to Prevent Waste',
      'Cold-Storage Temperature & Freshness Sensor Tracking',
      'Automatic Discounts for Approaching Expiry Dates',
      'Zero-Waste Food Donation & Safe Disposal Tracking',
    ];
  }
}
