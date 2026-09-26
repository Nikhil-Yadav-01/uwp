import '../models/recipe_component.dart';

/// Calculation engine for Bill of Materials (BOM), recipe stock deductions, and unit cost roll-ups.
class BomComposerEngine {
  const BomComposerEngine();

  /// Calculates the maximum number of parent units that can be assembled based on available component stock.
  /// Identifies the bottleneck ingredient limit.
  double calculateProducibleQuantity({
    required List<RecipeComponent> components,
    required Map<String, double> componentStockMap, // childProductId -> currentStock
  }) {
    if (components.isEmpty) return 0.0;

    double minProducible = double.infinity;

    for (final comp in components) {
      final availableStock = componentStockMap[comp.childProductId] ?? 0.0;
      final neededPerUnit = comp.effectiveQuantity;

      if (neededPerUnit <= 0) continue;

      final producible = availableStock / neededPerUnit;
      if (producible < minProducible) {
        minProducible = producible;
      }
    }

    return minProducible == double.infinity ? 0.0 : minProducible;
  }

  /// Calculates total rolled-up cost of the assembled parent item based on component unit costs and waste factors.
  double calculateRolledUpCost({
    required List<RecipeComponent> components,
    required Map<String, double> componentCostMap, // childProductId -> unitCost
  }) {
    double totalCost = 0.0;

    for (final comp in components) {
      final unitCost = componentCostMap[comp.childProductId] ?? 0.0;
      totalCost += unitCost * comp.effectiveQuantity;
    }

    return totalCost;
  }

  /// Calculates the exact stock deduction required for each child component when parent units are sold/assembled.
  Map<String, double> calculateComponentDeductions({
    required List<RecipeComponent> components,
    required double parentUnitsToAssemble,
  }) {
    final Map<String, double> deductions = {};

    for (final comp in components) {
      final deduction = comp.effectiveQuantity * parentUnitsToAssemble;
      deductions[comp.childProductId] = deduction;
    }

    return deductions;
  }
}
