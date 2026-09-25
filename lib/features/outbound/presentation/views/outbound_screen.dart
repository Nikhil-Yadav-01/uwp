import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class OutboundScreen extends ConsumerWidget {
  const OutboundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: context.isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outbound Fulfillment & Wave Picking', style: AppTypography.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Wave dispatch, packing station verification & shipping for ${archetype.name}',
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: archetype.brandColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                ),
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Dispatch Wave Picklist'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Picking Waves Summary
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Wave #W-104 (Optimal Shortest Path)', style: AppTypography.h3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: archetype.brandColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('8 Orders Aggregated', style: AppTypography.caption.copyWith(color: archetype.brandColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: const Icon(Icons.navigation_outlined, color: AppColors.primary, size: 20),
                  ),
                  title: Text('Zone A \u2192 Aisle 04 \u2192 Bin 12', style: AppTypography.bodyBold),
                  subtitle: Text('Voice-Guided Picking Active • Bluetooth Headset Connected', style: AppTypography.caption),
                  trailing: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.mic_outlined, size: 16),
                    label: const Text('Hands-Free Pick'),
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
