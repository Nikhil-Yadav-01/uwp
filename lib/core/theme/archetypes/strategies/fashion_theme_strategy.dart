import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';
import '../contracts/archetype_theme_strategy.dart';

/// Theme Strategy for Fashion, Apparel & Footwear
class FashionThemeStrategy implements IArchetypeThemeStrategy {
  const FashionThemeStrategy();

  @override
  BusinessArchetypeType get archetypeType => BusinessArchetypeType.fashionAndApparel;

  @override
  ArchetypeThemeProfile get profile => const ArchetypeThemeProfile(
        primary: Color(0xFFE11D48), // Editorial Rose
        primaryLight: Color(0xFFF43F5E),
        primaryDark: Color(0xFFBE123C),
        accent: Color(0xFF8B5CF6), // Vibrant Violet
        darkBackground: Color(0xFF140F13), // Haute-couture noir
        darkCard: Color(0xFF241822),
        darkSurface: Color(0xFF382334),
        darkBorder: Color(0xFF4A2F46),
        lightBackground: Color(0xFFFFF1F2),
        lightCard: Color(0xFFFFFFFF),
        lightSurface: Color(0xFFFFE4E6),
        lightBorder: Color(0xFFFECDD3),
        environmentName: 'Showroom & Garment Depot',
        environmentDescription: 'Editorial chic noir & rose • Rapid matrix variant sorting',
        environmentIcon: Icons.checkroom_outlined,
        primaryGradient: LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        headerGradient: LinearGradient(
          colors: [Color(0xFFBE123C), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  @override
  ThemeData buildTheme(Brightness brightness) => profile.toThemeData(brightness);
}
