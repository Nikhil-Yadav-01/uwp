import 'package:flutter/material.dart';

/// Supported industry archetypes.
enum BusinessArchetypeType {
  leatherAndTextiles,
  groceryAndPerishables,
  electronicsAndTech,
  barsAndHospitality,
  fashionAndApparel,
  hardwareAndParts,
  healthcareAndPharma,
}

/// Data types supported for dynamic custom fields.
enum FieldDataType {
  text,
  number,
  decimal,
  date,
  dropdown,
  boolean,
  currency,
}

/// Dynamic custom attribute schema definition for an archetype.
class CustomFieldDefinition {
  final String key;
  final String label;
  final FieldDataType dataType;
  final bool isRequired;
  final String? unit; // e.g., 'sq ft', 'ml', 'kg', 'mm', 'mg'
  final List<String>? options; // For dropdown
  final String? helperText;

  const CustomFieldDefinition({
    required this.key,
    required this.label,
    required this.dataType,
    this.isRequired = false,
    this.unit,
    this.options,
    this.helperText,
  });
}

/// Capability flags declaring what features an archetype uses.
class ArchetypeCapabilities {
  final bool supportsAreaDimensions;
  final bool supportsBatchExpiry;
  final bool supportsColdChain;
  final bool supportsSerialTracking;
  final bool supportsRecipeBOM;
  final bool supportsMatrixVariants;
  final bool supportsWeightScale;
  final bool supportsScrapTracking;
  final bool supportsControlledVault;
  final bool supportsWardAllocation;

  const ArchetypeCapabilities({
    this.supportsAreaDimensions = false,
    this.supportsBatchExpiry = false,
    this.supportsColdChain = false,
    this.supportsSerialTracking = false,
    this.supportsRecipeBOM = false,
    this.supportsMatrixVariants = false,
    this.supportsWeightScale = false,
    this.supportsScrapTracking = false,
    this.supportsControlledVault = false,
    this.supportsWardAllocation = false,
  });
}

/// KPI Metric card model for dynamic dashboards.
class ArchetypeKPIMetric {
  final String id;
  final String label;
  final String value;
  final String? subtitle;
  final String? trend; // e.g. '+12%'
  final bool isPositiveTrend;
  final IconData icon;
  final Color color;

  const ArchetypeKPIMetric({
    required this.id,
    required this.label,
    required this.value,
    this.subtitle,
    this.trend,
    this.isPositiveTrend = true,
    required this.icon,
    required this.color,
  });
}

/// Full business archetype definition profile.
class BusinessArchetype {
  final BusinessArchetypeType type;
  final String id;
  final String name;
  final String tagLine;
  final String description;
  final IconData icon;
  final Color brandColor;
  final String primaryUom; // e.g., 'sq ft', 'kg', 'unit', 'ml', 'vials'
  final List<String> supportedUoms;
  final ArchetypeCapabilities capabilities;
  final List<CustomFieldDefinition> customFields;

  const BusinessArchetype({
    required this.type,
    required this.id,
    required this.name,
    required this.tagLine,
    required this.description,
    required this.icon,
    required this.brandColor,
    required this.primaryUom,
    required this.supportedUoms,
    required this.capabilities,
    required this.customFields,
  });
}
