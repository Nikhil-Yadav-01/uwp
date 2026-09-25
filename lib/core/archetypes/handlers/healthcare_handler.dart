import 'package:flutter/material.dart';
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
    return [
      {
        'id': 'MED-001',
        'name': 'Morphine Sulfate Injection 10mg/mL (1mL Ampoule)',
        'sku': 'MED-RX-MPH-10MG',
        'barcode': '030074123456',
        'category': 'Controlled Substances (Rx)',
        'stock': 150.0,
        'uom': 'Ampoules',
        'unitPrice': 18.50,
        'customAttributes': {
          'is_controlled': true,
          'schedule_class': 'Schedule II (High Control)',
          'lot_no': 'LOT-MPH-202608',
          'expiry_date': '2027-08-31',
          'storage_location': 'Narcotics Safe (Vault A-01)',
          'dual_signoff_required': true,
        },
      },
      {
        'id': 'MED-002',
        'name': 'mRNA Quadrivalent Vaccine Vials (6 Doses/Vial)',
        'sku': 'MED-VAC-MRNA-QUAD',
        'barcode': '030074987654',
        'category': 'Vaccines & Biologics',
        'stock': 60.0,
        'uom': 'Vials (360 Doses)',
        'unitPrice': 115.00,
        'customAttributes': {
          'is_controlled': false,
          'lot_no': 'VAC-LOT-9921B',
          'expiry_date': '2026-12-15',
          'storage_temperature': 'Ultra-Cold Freezer (-80°C to -60°C)',
          'allocated_ward': 'Immunization Clinic',
        },
      },
      {
        'id': 'MED-003',
        'name': 'Sterile Surgical Suture Kit 3-0 Silk (Box of 36)',
        'sku': 'MED-SUR-SUT-30',
        'barcode': '030074888888',
        'category': 'Surgical & Wound Care',
        'stock': 40.0,
        'uom': 'Boxes',
        'unitPrice': 48.00,
        'customAttributes': {
          'is_controlled': false,
          'lot_no': 'SUT-SILK-882',
          'sterilization_method': 'Ethylene Oxide (EO Gas)',
          'sterile_expiry_date': '2028-05-01',
          'storage_location': 'OR Supply Room 2B',
        },
      },
      {
        'id': 'MED-004',
        'name': 'Emergency Crash Cart Ampoule Kit (Code Blue Ready)',
        'sku': 'MED-EMG-CRASH-KIT',
        'barcode': '030074777777',
        'category': 'Emergency Par Kits',
        'stock': 8.0,
        'uom': 'Sealed Kits',
        'unitPrice': 320.00,
        'customAttributes': {
          'is_controlled': true,
          'tamper_seal_id': 'SEAL-RED-90812',
          'par_level_compliance': '100% Complete',
          'next_mandatory_audit': '2026-10-01 (7 Days)',
          'allocated_ward': 'ICU / Emergency Trauma Bay',
        },
      },
    ];
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'Dual-Nurse Badge Scan for Schedule II Controlled Drug Dispensing',
      'Crash Cart Par-Level Replenishment & Tamper Seal Logging',
      'Patient MRN & Hospital Ward Direct Issuance Billing',
      'Vaccine Ultra-Cold Chain Excursion Compliance Audit',
      'Autoclave Sterile Batch & Surgical Instrument Expiry Tracking',
    ];
  }
}
