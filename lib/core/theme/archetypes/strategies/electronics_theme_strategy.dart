import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';
import '../contracts/archetype_theme_strategy.dart';

/// Theme Strategy for Electronics, High-Tech & RMA Diagnostics
class ElectronicsThemeStrategy implements IArchetypeThemeStrategy {
  const ElectronicsThemeStrategy();

  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.electronicsAndTech;

  @override
  ArchetypeThemeProfile get profile => const ArchetypeThemeProfile(
        primary: Color(0xFF4F46E5), // Cyber Indigo
        primaryLight: Color(0xFF6366F1),
        primaryDark: Color(0xFF4338CA),
        accent: Color(0xFF0EA5E9), // Neon Sky
        darkBackground: Color(0xFF0B1120), // Deep space slate
        darkCard: Color(0xFF152238),
        darkSurface: Color(0xFF1E3250),
        darkBorder: Color(0xFF2B4468),
        lightBackground: Color(0xFFF1F5F9),
        lightCard: Color(0xFFFFFFFF),
        lightSurface: Color(0xFFE2E8F0),
        lightBorder: Color(0xFFCBD5E1),
        environmentName: 'Tech Cleanroom & Test Bench',
        environmentDescription: 'Cyber indigo & high-contrast sky • Precision scanning & diagnostics',
        environmentIcon: Icons.memory_outlined,
        primaryGradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        headerGradient: LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF0284C7)],
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
