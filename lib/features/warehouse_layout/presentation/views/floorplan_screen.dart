import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class FloorplanScreen extends ConsumerWidget {
  const FloorplanScreen({super.key});

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
                  Text('2D/3D Digital Twin Floorplan', style: AppTypography.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Visual spatial grid, live stock density heatmaps & routing for ${archetype.name}',
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.local_fire_department_outlined, size: 18),
                    label: const Text('Toggle Heatmap'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: archetype.brandColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit Layout'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2D Floor Visual Canvas Mockup
          Container(
            height: 460,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF090E17) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: archetype.brandColor.withValues(alpha: 0.3)),
            ),
            child: Stack(
              children: [
                // Grid Pattern Background
                Positioned.fill(
                  child: CustomPaint(
                    painter: FloorGridPainter(isDark: isDark),
                  ),
                ),

                // Staging Docks
                Positioned(
                  top: 20,
                  left: 30,
                  child: zoneBox('Dock A: Inbound Receiving', 180, 70, AppColors.info, isDark),
                ),
                Positioned(
                  top: 20,
                  right: 30,
                  child: zoneBox('Dock B: Outbound Packing', 180, 70, AppColors.success, isDark),
                ),

                // Warehouse Aisles
                Positioned(
                  top: 130,
                  left: 60,
                  child: aisleBlock('Aisle 01 (Fast Velocity)', 120, 260, archetype.brandColor, isDark, 0.9),
                ),
                Positioned(
                  top: 130,
                  left: 230,
                  child: aisleBlock('Aisle 02 (Medium Velocity)', 120, 260, archetype.brandColor, isDark, 0.6),
                ),
                Positioned(
                  top: 130,
                  left: 400,
                  child: aisleBlock('Aisle 03 (Reserve Storage)', 120, 260, archetype.brandColor, isDark, 0.3),
                ),

                // Live Legend Overlay
                Positioned(
                  bottom: 20,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text('Interactive Digital Twin • Drag to pan / Pinch to zoom', style: AppTypography.caption),
                      ],
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

  Widget zoneBox(String title, double w, double h, Color color, bool isDark) {
    return Container(
      width: w,
      height: h,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Text(
          title,
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget aisleBlock(String title, double w, double h, Color color, bool isDark, double intensity) {
    return Container(
      width: w,
      height: h,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: intensity * 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: intensity), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(intensity * 100).toInt()}% Capacity',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class FloorGridPainter extends CustomPainter {
  final bool isDark;
  FloorGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF1E293B).withValues(alpha: 0.4) : const Color(0xFFCBD5E1).withValues(alpha: 0.6)
      ..strokeWidth = 1;

    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
