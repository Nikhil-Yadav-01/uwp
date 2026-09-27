import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/archetypes/archetype_registry.dart';
import '../../core/archetypes/models/archetype_definition.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/archetypes/presentation/controllers/archetype_controller.dart';

/// Top-bar interactive dropdown enabling instant 1-click vertical switching during client pitches
class DemoArchetypeSwitcherBar extends ConsumerWidget {
  const DemoArchetypeSwitcherBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentArchetypeState = ref.watch(archetypeProvider);
    final activeArchetype = currentArchetypeState.archetype;
    final allArchetypes = ArchetypeRegistry.getAllArchetypes();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live Pulsing Indicator with Archetype Environmental Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activeArchetype.icon,
              size: 14,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),

          // Label & Dropdown
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /* Temporarily commented out:
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PROTOTYPE SHOWCASE',
                      style: AppTypography.caption.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LIVE MORPH',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                */
                PopupMenuButton<BusinessArchetypeType>(
                  tooltip: 'Switch Business Vertical & Environmental Theme',
                  initialValue: activeArchetype.type,
                  offset: const Offset(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  color: colorScheme.surface,
                  onSelected: (type) {
                    ref.read(archetypeProvider.notifier).switchArchetype(type);
                  },
                  itemBuilder: (context) {
                    return allArchetypes.map((archetype) {
                      final isSelected = archetype.type == activeArchetype.type;
                      final archColor = archetype.themeProfile.primary;

                      return PopupMenuItem<BusinessArchetypeType>(
                        value: archetype.type,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: archColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                archetype.icon,
                                size: 16,
                                color: archColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        archetype.name,
                                        style: AppTypography.bodyBold.copyWith(
                                          color: isSelected
                                              ? archColor
                                              : (isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimaryLight),
                                        ),
                                      ),
                                      /* Temporarily commented out:
                                      const SizedBox(width: 6),
                                      Text(
                                        '• ${archetype.themeProfile.environmentName}',
                                        style: AppTypography.caption.copyWith(
                                          color: archColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      */
                                    ],
                                  ),
                                  Text(
                                    archetype.themeProfile.environmentDescription,
                                    style: AppTypography.caption.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: archColor,
                              ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          activeArchetype.name,
                          style: AppTypography.bodyBold.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
