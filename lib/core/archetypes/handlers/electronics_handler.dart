import 'package:flutter/material.dart';
import '../../data/datasources/sample_data_source.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class ElectronicsArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.electronicsAndTech;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'serialized_units',
        label: 'Tracked Serialized Units',
        value: '3,842 Devices',
        subtitle: '100% Dual IMEI & S/N logged',
        trend: '+15.2%',
        isPositiveTrend: true,
        icon: Icons.phone_android_outlined,
        color: AppColors.electronicsBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'warranty_active',
        label: 'Active Under Warranty',
        value: '94.6% (3,634)',
        subtitle: 'Direct OEM RMA link',
        trend: 'Healthy',
        isPositiveTrend: true,
        icon: Icons.verified_user_outlined,
        color: AppColors.success,
      ),
      const ArchetypeKPIMetric(
        id: 'rma_staging',
        label: 'RMA / Repair Staging',
        value: '28 Devices',
        subtitle: '12 Refurb A, 16 Vendor Return',
        trend: '-4 items',
        isPositiveTrend: true,
        icon: Icons.sync_problem_outlined,
        color: AppColors.warning,
      ),
      const ArchetypeKPIMetric(
        id: 'high_value_cage',
        label: 'High-Value Vault Stock',
        value: '₹248,500',
        subtitle: 'Dual-auth access required',
        trend: 'Secured',
        isPositiveTrend: true,
        icon: Icons.lock_outline_rounded,
        color: AppColors.secondary,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'units';
    final serial = customAttributes?['serial_no'] != null
        ? ' (S/N: ${customAttributes!['serial_no']})'
        : '';
    return '${quantity.toInt()} $unit$serial';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['imei_1'] != null) {
      final imei = attributes['imei_1'] as String;
      if (imei.isNotEmpty && imei.length != 15) {
        errors['imei_1'] = 'IMEI must be exactly 15 digits';
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
      'Scan Serial Number & Phone ID (IMEI) at Receiving',
      'Manufacturer Warranty Registration & Returns',
      'Device Condition Grading (Like-New, Good, Defective)',
      'High-Value Locked Vault Double-Approval Access',
    ];
  }
}
