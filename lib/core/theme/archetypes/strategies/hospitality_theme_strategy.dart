import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';
import '../contracts/archetype_theme_strategy.dart';

/// Theme Strategy for Bars, Nightlife, Lounges & Restaurants
class HospitalityThemeStrategy implements IArchetypeThemeStrategy {
  const HospitalityThemeStrategy();

  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.barsAndHospitality;

  @override
  ArchetypeThemeProfile get profile => const ArchetypeThemeProfile(
        primary: Color(0xFF9333EA), // Cabernet Wine
        primaryLight: Color(0xFFA855F7),
        primaryDark: Color(0xFF7E22CE),
        accent: Color(0xFFF59E0B), // Champagne Gold
        darkBackground: Color(0xFF120B17), // Speakeasy dark obsidian
        darkCard: Color(0xFF22132C),
        darkSurface: Color(0xFF331D42),
        darkBorder: Color(0xFF46275A),
        lightBackground: Color(0xFFFAF5FF),
        lightCard: Color(0xFFFFFFFF),
        lightSurface: Color(0xFFF3E8FF),
        lightBorder: Color(0xFFE9D5FF),
        environmentName: 'Lounge, Bar & Cellar',
        environmentDescription: 'Low-light ambient cabernet & champagne gold • Nightlife stockroom optics',
        environmentIcon: Icons.wine_bar_outlined,
        primaryGradient: LinearGradient(
          colors: [Color(0xFF9333EA), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        headerGradient: LinearGradient(
          colors: [Color(0xFF7E22CE), Color(0xFFD97706)],
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
