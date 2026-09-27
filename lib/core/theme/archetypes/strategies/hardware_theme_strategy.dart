import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';
import '../contracts/archetype_theme_strategy.dart';

/// Theme Strategy for Industrial Hardware, Yards & HAZMAT
class HardwareThemeStrategy implements IArchetypeThemeStrategy {
  const HardwareThemeStrategy();

  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.hardwareAndParts;

  @override
  ArchetypeThemeProfile get profile => const ArchetypeThemeProfile(
        primary: Color(0xFFEAB308), // Caution Amber / Hazard Gold
        primaryLight: Color(0xFFFACC15),
        primaryDark: Color(0xFFCA8A04),
        accent: Color(0xFF64748B), // Industrial Slate
        darkBackground: Color(0xFF101418), // Heavy carbon dark
        darkCard: Color(0xFF1C2229),
        darkSurface: Color(0xFF28313B),
        darkBorder: Color(0xFF394654),
        lightBackground: Color(0xFFF8FAFC),
        lightCard: Color(0xFFFFFFFF),
        lightSurface: Color(0xFFF1F5F9),
        lightBorder: Color(0xFFE2E8F0),
        environmentName: 'Yard, Steel Depot & HAZMAT',
        environmentDescription: 'Heavy industrial carbon & hazard caution • High outdoor sunlight contrast',
        environmentIcon: Icons.construction_outlined,
        primaryGradient: LinearGradient(
          colors: [Color(0xFFEAB308), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        headerGradient: LinearGradient(
          colors: [Color(0xFFCA8A04), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  @override
  ThemeData buildLightTheme() => profile.toThemeData(Brightness.light);

  @override
  ThemeData buildDarkTheme() => profile.toThemeData(Brightness.dark);

  @override
  ThemeData buildTheme(Brightness brightness) => profile.toThemeData(brightness);
}
