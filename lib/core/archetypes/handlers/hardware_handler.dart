import 'package:flutter/material.dart';
import '../contracts/archetype_feature_handler.dart';
import '../models/archetype_definition.dart';
import '../../theme/app_colors.dart';

class HardwareArchetypeHandler implements IArchetypeFeatureHandler {
  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.hardwareAndParts;

  @override
  List<ArchetypeKPIMetric> getDashboardKPIs() {
    return [
      const ArchetypeKPIMetric(
        id: 'oem_parts_count',
        label: 'Cataloged OEM SKUs',
        value: '28,450 Parts',
        subtitle: '100% Cross-referenced',
        trend: '+4.8%',
        isPositiveTrend: true,
        icon: Icons.build_outlined,
        color: AppColors.hardwareBadge,
      ),
      const ArchetypeKPIMetric(
        id: 'bin_utilization',
        label: 'High-Density Bin Capacity',
        value: '84.2%',
        subtitle: '1,420 of 1,686 bins filled',
        trend: 'Optimized',
        isPositiveTrend: true,
        icon: Icons.inventory_2_outlined,
        color: AppColors.accent,
      ),
      const ArchetypeKPIMetric(
        id: 'reorder_triggers',
        label: 'Below Safety Stock Threshold',
        value: '14 SKUs',
        subtitle: 'Auto-generated PO pending',
        trend: 'Action Required',
        isPositiveTrend: false,
        icon: Icons.shopping_cart_outlined,
        color: AppColors.warning,
      ),
      const ArchetypeKPIMetric(
        id: 'hazmat_safe',
        label: 'HAZMAT Flammable Storage',
        value: '100% Compliant',
        subtitle: 'Zone H explosion-proof bay',
        trend: 'Audited',
        isPositiveTrend: true,
        icon: Icons.local_fire_department_outlined,
        color: AppColors.success,
      ),
    ];
  }

  @override
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes}) {
    final unit = uom ?? 'pcs';
    final bin = customAttributes?['bin_location'] != null
        ? ' [Bin: ${customAttributes!['bin_location']}]'
        : '';
    return '${quantity.toInt()} $unit$bin';
  }

  @override
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes) {
    final errors = <String, String>{};
    if (attributes['oem_part_number'] == null) {
      errors['oem_part_number'] = 'OEM Part Number is required';
    }
    return errors.isEmpty ? null : errors;
  }

  @override
  List<Map<String, dynamic>> getDemoProducts() {
    return [
      {
        'id': 'HDW-001',
        'name': 'Brembo Ceramic Front Brake Pad Set',
        'sku': 'HDW-BRM-P83085N',
        'barcode': '802058401234',
        'category': 'Brake Systems',
        'stock': 64.0,
        'uom': 'Set',
        'unitPrice': 89.50,
        'customAttributes': {
          'oem_part_number': '04465-42190',
          'bin_location': 'Aisle 04-Rack B-Bin 12',
          'weight_kg': 1.85,
          'vehicle_fitment': 'Toyota RAV4 / Camry (2019-2024)',
          'is_hazardous': false,
        },
      },
      {
        'id': 'HDW-002',
        'name': 'Bosch High-Pressure Common Rail Fuel Injector',
        'sku': 'HDW-BSH-0445110',
        'barcode': '404702409876',
        'category': 'Fuel Delivery',
        'stock': 28.0,
        'uom': 'pcs',
        'unitPrice': 245.00,
        'customAttributes': {
          'oem_part_number': '13537805428',
          'bin_location': 'Aisle 02-Rack A-Bin 04',
          'weight_kg': 0.65,
          'vehicle_fitment': 'BMW N47 / N57 Diesel Engines',
          'is_hazardous': false,
        },
      },
      {
        'id': 'HDW-003',
        'name': 'Industrial Lithium Synthetic Grease (400g Tube)',
        'sku': 'HDW-LUB-SYN-400',
        'barcode': '404702488888',
        'category': 'Chemicals & Lubricants',
        'stock': 150.0,
        'uom': 'Tube',
        'unitPrice': 12.00,
        'customAttributes': {
          'oem_part_number': 'NLGI-GC-LB-02',
          'bin_location': 'Zone H-Flammable Bay 3',
          'weight_kg': 0.40,
          'is_hazardous': true,
          'hazmat_class': 'Class 3 Flammable Solid',
        },
      },
    ];
  }

  @override
  List<String> getSpecializedWorkflows() {
    return [
      'High-Density Bin Location Routing (Aisle-Rack-Shelf-Bin)',
      'OEM Part Number & Interchange Cross-Referencing',
      'HAZMAT Chemical Zone Safety Protocol Checklist',
      'Weight Scale Verification for Fastener & Bulk Hardware Kits',
    ];
  }
}
