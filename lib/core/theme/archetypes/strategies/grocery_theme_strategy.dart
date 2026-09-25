import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';
import '../contracts/archetype_theme_strategy.dart';

/// Theme Strategy for Grocery, Cold-Chain & Perishables
class GroceryThemeStrategy implements IArchetypeThemeStrategy {
  const GroceryThemeStrategy();

  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.groceryAndPerishables;

  @override
  ArchetypeThemeProfile get profile => const ArchetypeThemeProfile(
        primary: Color(0xFF059669), // Fresh Emerald
        primaryLight: Color(0xFF10B981),
        primaryDark: Color(0xFF047857),
        accent: Color(0xFF06B6D4), // Glacier Cyan
        darkBackground: Color(0xFF091712), // Deep arctic dark
        darkCard: Color(0xFF11261E),
        darkSurface: Color(0xFF1B392E),
        darkBorder: Color(0xFF254B3D),
        lightBackground: Color(0xFFF0FDF7),
        lightCard: Color(0xFFFFFFFF),
        lightSurface: Color(0xFFE1F8ED),
        lightBorder: Color(0xFFC3EDD9),
        environmentName: 'Cold Storage & Freezers',
        environmentDescription: 'Crisp arctic emerald & glacier cyan • High-visibility chilled telemetry',
        environmentIcon: Icons.ac_unit_outlined,
        primaryGradient: LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        headerGradient: LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  @override
  ThemeData buildTheme(Brightness brightness) => profile.toThemeData(brightness);
}
