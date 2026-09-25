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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: activeArchetype.brandColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeArchetype.brandColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live Pulsing Indicator
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: activeArchetype.brandColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activeArchetype.icon,
              size: 14,
              color: activeArchetype.brandColor,
            ),
          ),
          const SizedBox(width: 8),

          // Label & Dropdown
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PROTOTYPE SHOWCASE',
                      style: AppTypography.caption.copyWith(
                        color: activeArchetype.brandColor,
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
                PopupMenuButton<BusinessArchetypeType>(
                  tooltip: 'Switch Business Vertical',
                  initialValue: activeArchetype.type,
                  offset: const Offset(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  onSelected: (type) {
                    ref.read(archetypeProvider.notifier).switchArchetype(type);
                  },
                  itemBuilder: (context) {
                    return allArchetypes.map((archetype) {
                      final isSelected = archetype.type == activeArchetype.type;
                      return PopupMenuItem<BusinessArchetypeType>(
                        value: archetype.type,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: archetype.brandColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                archetype.icon,
                                size: 16,
                                color: archetype.brandColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    archetype.name,
                                    style: AppTypography.bodyBold.copyWith(
                                      color: isSelected
                                          ? archetype.brandColor
                                          : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                  Text(
                                    archetype.tagLine,
                                    style: AppTypography.caption.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
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
                                color: archetype.brandColor,
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
