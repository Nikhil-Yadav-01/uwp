import 'package:flutter/material.dart';
import '../../../archetypes/models/archetype_definition.dart';
import '../../models/archetype_theme_profile.dart';

/// Strategy contract for industry vertical dynamic theming and environmental ergonomics.
abstract interface class IArchetypeThemeStrategy {
  BusinessArchetypeType get archetypeType;
  ArchetypeThemeProfile get profile;

  ThemeData buildTheme(Brightness brightness);
}
