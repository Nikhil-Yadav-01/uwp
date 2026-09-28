import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/archetypes/archetype_registry.dart';
import '../../core/archetypes/models/archetype_definition.dart';
import '../../core/design/app_sizes.dart';
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

    return PopupMenuButton<BusinessArchetypeType>(
      tooltip: 'Switch Business Vertical & Environmental Theme',
      initialValue: activeArchetype.type,
      offset: const Offset(0, 36),
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
      child: Container(
        padding: context.isMobile
            ? const EdgeInsets.all(AppSpacing.xs)
            : const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: AppSpacing.md,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live Pulsing Indicator with Archetype Environmental Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activeArchetype.icon,
                size: AppSizes.iconSm,
                color: colorScheme.primary,
              ),
            ),
            if (!context.isMobile) ...[
              const SizedBox(width: AppSpacing.sm),
              // Label & Dropdown
              Flexible(
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
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(Icons.keyboard_arrow_down_rounded, size: AppSizes.iconSm),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
