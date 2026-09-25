import '../models/archetype_definition.dart';

/// Pluggable Strategy Contract for archetype-specific calculations and workflows.
abstract class IArchetypeFeatureHandler {
  BusinessArchetypeType get archetypeType;

  /// Returns tailored KPI metrics for the dashboard
  List<ArchetypeKPIMetric> getDashboardKPIs();

  /// Formats quantity with the industry-appropriate unit
  String formatQuantity(double quantity, {String? uom, Map<String, dynamic>? customAttributes});

  /// Validates specialized item attributes (e.g. valid IMEI, valid sq ft area, valid batch expiry)
  Map<String, String>? validateAttributes(Map<String, dynamic> attributes);

  /// Generates sample demonstration items for client presentation
  List<Map<String, dynamic>> getDemoProducts();

  /// Specialized workflow action description (e.g., "Grading & Area Stamping", "FEFO Rotation Check", "IMEI Verification")
  List<String> getSpecializedWorkflows();
}
