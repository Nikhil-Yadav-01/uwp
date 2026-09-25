import 'package:flutter/material.dart';
import 'contracts/archetype_feature_handler.dart';
import 'handlers/leather_handler.dart';
import 'handlers/grocery_handler.dart';
import 'handlers/electronics_handler.dart';
import 'handlers/hospitality_handler.dart';
import 'handlers/fashion_handler.dart';
import 'handlers/hardware_handler.dart';
import 'handlers/healthcare_handler.dart';
import 'models/archetype_definition.dart';
import '../theme/app_colors.dart';

/// Central registry managing all registered archetypes and their feature handlers.
class ArchetypeRegistry {
  ArchetypeRegistry._();

  static final Map<BusinessArchetypeType, IArchetypeFeatureHandler> _handlers = {
    BusinessArchetypeType.leatherAndTextiles: LeatherArchetypeHandler(),
    BusinessArchetypeType.groceryAndPerishables: GroceryArchetypeHandler(),
    BusinessArchetypeType.electronicsAndTech: ElectronicsArchetypeHandler(),
    BusinessArchetypeType.barsAndHospitality: HospitalityArchetypeHandler(),
    BusinessArchetypeType.fashionAndApparel: FashionArchetypeHandler(),
    BusinessArchetypeType.hardwareAndParts: HardwareArchetypeHandler(),
    BusinessArchetypeType.healthcareAndPharma: HealthcareArchetypeHandler(),
  };

  static final Map<BusinessArchetypeType, BusinessArchetype> _archetypes = {
    BusinessArchetypeType.leatherAndTextiles: const BusinessArchetype(
      type: BusinessArchetypeType.leatherAndTextiles,
      id: 'archetype_leather',
      name: 'Leather & Textiles',
      tagLine: 'Area-based tracking, hide grading & scrap management',
      description: 'Optimized for tanneries, upholstery, leathercraft, and fabric roll depots.',
      icon: Icons.layers_outlined,
      brandColor: AppColors.leatherBadge,
      primaryUom: 'sq ft',
      supportedUoms: ['sq ft', 'sq m', 'hides', 'rolls', 'kg'],
      capabilities: ArchetypeCapabilities(
        supportsAreaDimensions: true,
        supportsScrapTracking: true,
        supportsWeightScale: true,
      ),
      customFields: [
        CustomFieldDefinition(key: 'tannery_origin', label: 'Tannery / Origin', dataType: FieldDataType.text),
        CustomFieldDefinition(key: 'dye_lot', label: 'Dye Lot Number', dataType: FieldDataType.text, isRequired: true),
        CustomFieldDefinition(key: 'grade', label: 'Quality Grade', dataType: FieldDataType.dropdown, options: ['Grade A (Prime)', 'Grade B (Standard)', 'Grade C (Utility)', 'Remnant']),
        CustomFieldDefinition(key: 'thickness_oz', label: 'Thickness (oz / mm)', dataType: FieldDataType.text, unit: 'oz'),
      ],
    ),
    BusinessArchetypeType.groceryAndPerishables: const BusinessArchetype(
      type: BusinessArchetypeType.groceryAndPerishables,
      id: 'archetype_grocery',
      name: 'Grocery & Perishables',
      tagLine: 'FEFO picking, cold-chain & dynamic expiry countdown',
      description: 'Designed for supermarkets, produce hubs, frozen cold-storage, and FMCG.',
      icon: Icons.shopping_basket_outlined,
      brandColor: AppColors.groceryBadge,
      primaryUom: 'kg',
      supportedUoms: ['kg', 'g', 'cartons', 'pallets', 'liters', 'bottles'],
      capabilities: ArchetypeCapabilities(
        supportsBatchExpiry: true,
        supportsColdChain: true,
      ),
      customFields: [
        CustomFieldDefinition(key: 'batch_no', label: 'Batch / Lot Number', dataType: FieldDataType.text, isRequired: true),
        CustomFieldDefinition(key: 'expiry_date', label: 'Expiration Date', dataType: FieldDataType.date, isRequired: true),
        CustomFieldDefinition(key: 'storage_zone', label: 'Storage Temperature Zone', dataType: FieldDataType.dropdown, options: ['Ambient (+20°C)', 'Chilled (+4°C)', 'Deep Freeze (-20°C)']),
        CustomFieldDefinition(key: 'origin', label: 'Farm / Harvest Origin', dataType: FieldDataType.text),
      ],
    ),
    BusinessArchetypeType.electronicsAndTech: const BusinessArchetype(
      type: BusinessArchetypeType.electronicsAndTech,
      id: 'archetype_electronics',
      name: 'Electronics & Gadgets',
      tagLine: 'Dual IMEI scanning, serial tracking & warranty RMA',
      description: 'Built for smartphone stores, computing warehouses, and refurbishment hubs.',
      icon: Icons.phone_android_outlined,
      brandColor: AppColors.electronicsBadge,
      primaryUom: 'units',
      supportedUoms: ['units', 'kits', 'master_cartons'],
      capabilities: ArchetypeCapabilities(
        supportsSerialTracking: true,
      ),
      customFields: [
        CustomFieldDefinition(key: 'serial_no', label: 'Serial Number (S/N)', dataType: FieldDataType.text, isRequired: true),
        CustomFieldDefinition(key: 'imei_1', label: 'Primary IMEI', dataType: FieldDataType.text),
        CustomFieldDefinition(key: 'imei_2', label: 'Secondary IMEI', dataType: FieldDataType.text),
        CustomFieldDefinition(key: 'condition', label: 'Condition State', dataType: FieldDataType.dropdown, options: ['Brand New (Sealed)', 'Refurbished Grade A+', 'Refurbished Grade B', 'RMA / Defective']),
        CustomFieldDefinition(key: 'warranty_months', label: 'Warranty Duration', dataType: FieldDataType.text),
      ],
    ),
    BusinessArchetypeType.barsAndHospitality: const BusinessArchetype(
      type: BusinessArchetypeType.barsAndHospitality,
      id: 'archetype_hospitality',
      name: 'Bars & Restaurants',
      tagLine: 'Liquid volume (ml), cocktail Recipe BOM & spillage logs',
      description: 'Engineered for lounges, cocktail bars, craft breweries, and restaurant storerooms.',
      icon: Icons.wine_bar_outlined,
      brandColor: AppColors.hospitalityBadge,
      primaryUom: 'ml',
      supportedUoms: ['ml', 'liters', 'bottles', 'kegs (50L)', 'servings'],
      capabilities: ArchetypeCapabilities(
        supportsRecipeBOM: true,
        supportsWeightScale: true,
        supportsScrapTracking: true,
      ),
      customFields: [
        CustomFieldDefinition(key: 'abv_percent', label: 'Alcohol by Volume (ABV %)', dataType: FieldDataType.number, unit: '%'),
        CustomFieldDefinition(key: 'volume_per_bottle_ml', label: 'Bottle Volume', dataType: FieldDataType.number, unit: 'ml'),
        CustomFieldDefinition(key: 'standard_pour_ml', label: 'Standard Pour Size', dataType: FieldDataType.number, unit: 'ml'),
        CustomFieldDefinition(key: 'vintage', label: 'Vintage / Release Year', dataType: FieldDataType.text),
      ],
    ),
    BusinessArchetypeType.fashionAndApparel: const BusinessArchetype(
      type: BusinessArchetypeType.fashionAndApparel,
      id: 'archetype_fashion',
      name: 'Fashion & Apparel',
      tagLine: 'Matrix variants (Size × Color) & garment hangtags',
      description: 'Crafted for fashion brands, boutique retail, and garment distribution centers.',
      icon: Icons.checkroom_outlined,
      brandColor: AppColors.fashionBadge,
      primaryUom: 'pcs',
      supportedUoms: ['pcs', 'pre-packs', 'pairs', 'sets'],
      capabilities: ArchetypeCapabilities(
        supportsMatrixVariants: true,
      ),
      customFields: [
        CustomFieldDefinition(key: 'season', label: 'Fashion Season', dataType: FieldDataType.dropdown, options: ['SS26', 'FW26', 'Core Permanent']),
        CustomFieldDefinition(key: 'size', label: 'Size', dataType: FieldDataType.dropdown, options: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Custom']),
        CustomFieldDefinition(key: 'color', label: 'Color Variant', dataType: FieldDataType.text),
        CustomFieldDefinition(key: 'fabric_composition', label: 'Fabric / Material Composition', dataType: FieldDataType.text),
      ],
    ),
    BusinessArchetypeType.hardwareAndParts: const BusinessArchetype(
      type: BusinessArchetypeType.hardwareAndParts,
      id: 'archetype_hardware',
      name: 'Hardware & Industrial',
      tagLine: 'High-density bin routing & OEM part cross-referencing',
      description: 'Designed for automotive parts, industrial machinery, and electrical supplies.',
      icon: Icons.build_outlined,
      brandColor: AppColors.hardwareBadge,
      primaryUom: 'pcs',
      supportedUoms: ['pcs', 'sets', 'boxes', 'crates', 'kg'],
      capabilities: ArchetypeCapabilities(
        supportsWeightScale: true,
      ),
      customFields: [
        CustomFieldDefinition(key: 'oem_part_number', label: 'OEM Part Number', dataType: FieldDataType.text, isRequired: true),
        CustomFieldDefinition(key: 'bin_location', label: 'High-Density Bin Location', dataType: FieldDataType.text),
        CustomFieldDefinition(key: 'vehicle_fitment', label: 'Vehicle / Machine Fitment', dataType: FieldDataType.text),
        CustomFieldDefinition(key: 'is_hazardous', label: 'HAZMAT Classified', dataType: FieldDataType.boolean),
      ],
    ),
    BusinessArchetypeType.healthcareAndPharma: const BusinessArchetype(
      type: BusinessArchetypeType.healthcareAndPharma,
      id: 'archetype_healthcare',
      name: 'Healthcare & Hospital Supply',
      tagLine: 'Controlled narcotics vault, crash carts & sterile lots',
      description: 'Engineered for hospitals, nursing homes, surgical centers, and clinical storerooms.',
      icon: Icons.medical_services_outlined,
      brandColor: AppColors.healthcareBadge,
      primaryUom: 'vials',
      supportedUoms: ['vials', 'ampoules', 'boxes', 'kits', 'units'],
      capabilities: ArchetypeCapabilities(
        supportsBatchExpiry: true,
        supportsColdChain: true,
        supportsControlledVault: true,
        supportsWardAllocation: true,
      ),
      customFields: [
        CustomFieldDefinition(key: 'lot_no', label: 'Pharma Lot / Batch No', dataType: FieldDataType.text, isRequired: true),
        CustomFieldDefinition(key: 'expiry_date', label: 'Medical Expiration Date', dataType: FieldDataType.date, isRequired: true),
        CustomFieldDefinition(key: 'schedule_class', label: 'DEA / Drug Schedule', dataType: FieldDataType.dropdown, options: ['Schedule II (Controlled)', 'Schedule IV', 'Non-Controlled Rx', 'OTC / Supply']),
        CustomFieldDefinition(key: 'allocated_ward', label: 'Assigned Ward / Department', dataType: FieldDataType.text),
      ],
    ),
  };

  /// Returns all available archetypes for the demo switcher
  static List<BusinessArchetype> getAllArchetypes() {
    return _archetypes.values.toList();
  }

  /// Get archetype definition by type
  static BusinessArchetype getArchetype(BusinessArchetypeType type) {
    return _archetypes[type] ?? _archetypes[BusinessArchetypeType.leatherAndTextiles]!;
  }

  /// Get strategy feature handler for an archetype
  static IArchetypeFeatureHandler getHandler(BusinessArchetypeType type) {
    return _handlers[type] ?? _handlers[BusinessArchetypeType.leatherAndTextiles]!;
  }
}
