import 'package:flutter/material.dart';
import '../../data/datasources/sample_data_source.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class HealthcareArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.healthcareAndPharma;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'narcotics_vault',
        label: 'Controlled Substances Vault',
        value: '100% Balanced',
        subtitle: 'Schedule II/IV dual-signature verified',
        trend: 'Audited Today',
        isPositiveTrend: true,
        icon: Icons.health_and_safety_outlined,
        color: AppColors.healthcareBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'crash_carts',
        label: 'Emergency Crash Carts',
        value: '8 / 8 Ready',
        subtitle: '100% Par-level sealed & inspected',
        trend: 'Critical Ready',
        isPositiveTrend: true,
        icon: Icons.emergency_outlined,
        color: AppColors.error,
      ),
      const ArchetypeKPIMetric(
        id: 'med_expiry',
        label: 'Meds Expiring in ≤ 30 Days',
        value: '12 Batches',
        subtitle: 'Ward exchange & return flagged',
        trend: 'Monitor',
        isPositiveTrend: false,
        icon: Icons.calendar_today_outlined,
        color: AppColors.warning,
      ),
      const ArchetypeKPIMetric(
        id: 'vaccine_cold_chain',
        label: 'Vaccine Cold Storage',
        value: '+3.4°C / -78.2°C',
        subtitle: 'CDC compliant continuous logging',
        trend: 'In Range',
        isPositiveTrend: true,
        icon: Icons.medical_information_outlined,
        color: AppColors.success,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'vials';
    final lot = customAttributes?['lot_no'] != null
        ? ' [Lot: ${customAttributes!['lot_no']}]'
        : '';
    final ward = customAttributes?['allocated_ward'] != null
        ? ' (${customAttributes!['allocated_ward']})'
        : '';
    return '${quantity.toInt()} $unit$lot$ward';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['is_controlled'] == true && (attributes['schedule_class'] == null || (attributes['schedule_class'] as String).isEmpty)) {
      errors['schedule_class'] = 'Schedule classification is mandatory for controlled drugs';
    }
    if (attributes['expiry_date'] == null) {
      errors['expiry_date'] = 'Medical expiry date is mandatory';
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
      'Two-Nurse Sign-off for Locked & Controlled Medicines',
      'Emergency Hospital Crash Cart Restocking & Tamper Seal Check',
      'Patient & Hospital Ward Direct Issuance Record',
      'Vaccine Ultra-Cold Storage Temperature Audit',
      'Surgical Instrument Sterilization & Expiry Tracking',
    ];
  }
}
