import '../../archetypes/models/archetype_definition.dart';
import 'contracts/archetype_theme_strategy.dart';
import 'strategies/electronics_theme_strategy.dart';
import 'strategies/fashion_theme_strategy.dart';
import 'strategies/grocery_theme_strategy.dart';
import 'strategies/hardware_theme_strategy.dart';
import 'strategies/healthcare_theme_strategy.dart';
import 'strategies/hospitality_theme_strategy.dart';
import 'strategies/leather_theme_strategy.dart';

/// Registry mapping business archetypes to their dedicated modular theme strategies.
class ArchetypeThemeRegistry {
  ArchetypeThemeRegistry._();

  static const Map<BusinessArchetypeType, IArchetypeThemeStrategy> _strategies = {
    BusinessArchetypeType.leatherAndTextiles: LeatherThemeStrategy(),
    BusinessArchetypeType.groceryAndPerishables: GroceryThemeStrategy(),
    BusinessArchetypeType.electronicsAndTech: ElectronicsThemeStrategy(),
    BusinessArchetypeType.barsAndHospitality: HospitalityThemeStrategy(),
    BusinessArchetypeType.fashionAndApparel: FashionThemeStrategy(),
    BusinessArchetypeType.hardwareAndParts: HardwareThemeStrategy(),
    BusinessArchetypeType.healthcareAndPharma: HealthcareThemeStrategy(),
  };

  /// Resolves the dedicated modular theme strategy for an archetype type
  static IArchetypeThemeStrategy getStrategy(BusinessArchetypeType type) {
    return _strategies[type] ?? const LeatherThemeStrategy();
  }
}
