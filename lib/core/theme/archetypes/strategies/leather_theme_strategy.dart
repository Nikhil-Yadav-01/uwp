import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';
import '../contracts/archetype_theme_strategy.dart';

/// Theme Strategy for Leather & Tannery / Raw Materials
class LeatherThemeStrategy implements IArchetypeThemeStrategy {
  const LeatherThemeStrategy();

  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.leatherAndTextiles;

  @override
  ArchetypeThemeProfile get profile => const ArchetypeThemeProfile(
        primary: Color(0xFFD97706), // Warm Amber / Cognac
        primaryLight: Color(0xFFF59E0B),
        primaryDark: Color(0xFFB45309),
        accent: Color(0xFF92400E), // Saddle Russet
        darkBackground: Color(0xFF171210), // Workshop dark carbon
        darkCard: Color(0xFF261D1A),
        darkSurface: Color(0xFF382B27),
        darkBorder: Color(0xFF45342F),
        lightBackground: Color(0xFFFAF7F2), // Kraft paper warm light
        lightCard: Color(0xFFFFFFFF),
        lightSurface: Color(0xFFF3ECE1),
        lightBorder: Color(0xFFE6D9C8),
        environmentName: 'Tannery Floor & Workshop',
        environmentDescription: 'Warm craft ambient tones • Natural hide grading & roll storage',
        environmentIcon: Icons.layers_outlined,
        primaryGradient: LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFF92400E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        headerGradient: LinearGradient(
          colors: [Color(0xFFB45309), Color(0xFF78350F)],
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
