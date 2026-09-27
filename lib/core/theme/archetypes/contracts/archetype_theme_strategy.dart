import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';

/// Strategy contract for industry vertical dynamic theming and environmental ergonomics.
abstract class IArchetypeThemeStrategy {
  BusinessArchetypeType get archetypeType;
  ArchetypeThemeProfile get profile;

  ThemeData buildLightTheme() => profile.toThemeData(Brightness.light);
  ThemeData buildDarkTheme() => profile.toThemeData(Brightness.dark);
  ThemeData buildTheme(Brightness brightness) => profile.toThemeData(brightness);
}
