import 'package:flutter/material.dart';
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
    return [
      {
        'id': 'ELE-001',
        'name': 'Apple iPhone 15 Pro Max 256GB',
        'sku': 'ELE-IP15PM-256-NT',
        'barcode': '195949012345',
        'category': 'Smartphones',
        'stock': 42.0,
        'uom': 'Units',
        'unitPrice': 1199.00,
        'customAttributes': {
          'serial_no': 'G6TX9012KLP',
          'imei_1': '358921094827104',
          'imei_2': '358921094827112',
          'condition': 'Brand New (Sealed)',
          'warranty_months': '12 Months AppleCare',
          'firmware': 'iOS 17.5',
        },
      },
      {
        'id': 'ELE-002',
        'name': 'Sony WH-1000XM5 Noise Canceling',
        'sku': 'ELE-SNY-XM5-SLV',
        'barcode': '027242921002',
        'category': 'Audio & Headphones',
        'stock': 88.0,
        'uom': 'Units',
        'unitPrice': 348.00,
        'customAttributes': {
          'serial_no': 'SNY-XM5-89421',
          'condition': 'Brand New',
          'warranty_months': '24 Months Sony',
          'color': 'Silver Platinum',
        },
      },
      {
        'id': 'ELE-003',
        'name': 'MacBook Pro 16" M3 Max 36GB/1TB',
        'sku': 'ELE-MBP16-M3M-1T',
        'barcode': '195949098765',
        'category': 'Laptops & Computers',
        'stock': 18.0,
        'uom': 'Units',
        'unitPrice': 3499.00,
        'customAttributes': {
          'serial_no': 'C02GK999LPM3',
          'condition': 'Refurbished Grade A+',
          'warranty_months': '12 Months Certified',
          'battery_health': '100% (4 Cycles)',
        },
      },
    ];
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'Inbound Scan: Dual IMEI 1 & 2 + Serial Verification',
      'OEM Direct Warranty Registration & RMA Processing',
      'Refurbishment Condition Grading (Grade A/B/C/Defective)',
      'High-Value Vault Two-Person Audit Authorization',
    ];
  }
}
