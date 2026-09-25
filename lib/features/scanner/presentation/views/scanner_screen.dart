import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

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
                  Text('AI Multi-Barcode & AR Scanner', style: AppTypography.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Simultaneous batch scanning & Zebra/Honeywell Laser PDA bridge for ${archetype.name}',
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sensors_rounded, size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text('Hardware Laser: Ready', style: AppTypography.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // AR Viewfinder Mockup
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: archetype.brandColor, width: 2),
            ),
            child: Stack(
              children: [
                // Simulated Camera Feed & AR Bounding Boxes
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: Colors.white.withValues(alpha: 0.6)),
                      const SizedBox(height: 12),
                      Text('Aim camera at shelf or items', style: AppTypography.body.copyWith(color: Colors.white70)),
                      Text('AI Batch Recognition scans up to 10 barcodes concurrently', style: AppTypography.caption.copyWith(color: Colors.white38)),
                    ],
                  ),
                ),

                // Simulated Bounding Box 1 (Green / Match)
                Positioned(
                  top: 80,
                  left: 60,
                  child: arBoundingBox('890123450001 (Match)', AppColors.success),
                ),

                // Simulated Bounding Box 2 (Blue / Valid)
                Positioned(
                  bottom: 90,
                  right: 80,
                  child: arBoundingBox('890123450002 (Counted)', AppColors.accent),
                ),

                // Viewfinder HUD Reticle
                Center(
                  child: Container(
                    width: 240,
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget arBoundingBox(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
