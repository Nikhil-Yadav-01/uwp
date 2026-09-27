import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';
import '../contracts/archetype_theme_strategy.dart';

/// Theme Strategy for Healthcare, Clinical Logistics & Vaults
class HealthcareThemeStrategy implements IArchetypeThemeStrategy {
  const HealthcareThemeStrategy();

  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.healthcareAndPharma;

  @override
  ArchetypeThemeProfile get profile => const ArchetypeThemeProfile(
        primary: Color(0xFF0D9488), // Clinical Teal
        primaryLight: Color(0xFF14B8A6),
        primaryDark: Color(0xFF0F766E),
        accent: Color(0xFF0284C7), // Medical Sky
        darkBackground: Color(0xFF0A1518), // Pristine clinical dark
        darkCard: Color(0xFF112328),
        darkSurface: Color(0xFF1A333A),
        darkBorder: Color(0xFF25454E),
        lightBackground: Color(0xFFF0FDFA),
        lightCard: Color(0xFFFFFFFF),
        lightSurface: Color(0xFFCCFBF1),
        lightBorder: Color(0xFF99F6E4),
        environmentName: 'Sterile Ward & Clinical Vault',
        environmentDescription: 'Pristine surgical teal & sky • Maximum legibility & DEA compliance',
        environmentIcon: Icons.local_hospital_outlined,
        primaryGradient: LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        headerGradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0369A1)],
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
