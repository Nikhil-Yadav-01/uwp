import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';
import '../controllers/hardware_hub_controller.dart';
import '../widgets/barcode_scanner_view.dart';
import '../widgets/digital_scale_view.dart';
import '../widgets/pda_config_view.dart';
import '../widgets/thermal_printer_view.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final archetype = ref.watch(archetypeProvider).archetype;
    final hwState = ref.watch(hardwareHubProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 640;

          return SingleChildScrollView(
            padding: isMobile ? AppSpacing.pagePaddingMobile : AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Responsive Screen Header
                _buildHeader(context, archetype, hwState, isDark, isMobile, colorScheme),
                AppGap.h20,

                // 2. Interactive Category Selector Bar
                _buildCategorySelector(hwState, archetype.brandColor, colorScheme, isDark, isMobile),
                AppGap.h20,

                // 3. Fluid Hardware Studio Workspace
                _buildSelectedStudioView(archetype.brandColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    dynamic archetype,
    HardwareHubState hwState,
    bool isDark,
    bool isMobile,
    ColorScheme colorScheme,
  ) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Text('Hardware Bridge & Studio', style: AppTypography.headlineLarge),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: archetype.brandColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.r4),
                border: Border.all(color: archetype.brandColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                archetype.name,
                style: AppTypography.labelSmall.copyWith(
                  color: archetype.brandColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        AppGap.h4,
        Text(
          'Multi-Barcode AR Camera, Zebra/Honeywell Laser PDA, Thermal Printing & Digital Scale',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );

    final statusPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hwState.isLaserActive
            ? AppColors.success.withValues(alpha: 0.15)
            : colorScheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(
          color: hwState.isLaserActive ? AppColors.success : colorScheme.error,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sensors_rounded,
            size: AppSizes.iconSm,
            color: hwState.isLaserActive ? AppColors.success : colorScheme.error,
          ),
          AppGap.w8,
          Text(
            hwState.isLaserActive ? 'Laser PDA: Ready' : 'Laser: Standby',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: hwState.isLaserActive ? AppColors.success : colorScheme.error,
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleSection,
          AppGap.h12,
          statusPill,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleSection),
        AppGap.w16,
        statusPill,
      ],
    );
  }

  Widget _buildCategorySelector(
    HardwareHubState hwState,
    Color brandColor,
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
  ) {
    final categories = [
      _HardwareCategory(
        title: 'AI Multi-Barcode AR & Laser',
        badge: '${hwState.scannedBatch.length} scans',
        icon: Icons.qr_code_scanner_rounded,
        subtitle: 'Camera vision & USB/Laser intake',
      ),
      _HardwareCategory(
        title: 'Thermal Label & Receipt Lab',
        badge: 'ZPL / ESC-POS',
        icon: Icons.print_rounded,
        subtitle: 'Industrial templates & drivers',
      ),
      _HardwareCategory(
        title: 'Digital Scale & Piece Counter',
        badge: '${hwState.currentWeight.netWeight.toStringAsFixed(2)} kg',
        icon: Icons.scale_rounded,
        subtitle: 'BLE platter & piece counting',
      ),
      _HardwareCategory(
        title: 'Zebra / PDA Config',
        badge: hwState.isLaserActive ? 'Active' : 'Standby',
        icon: Icons.settings_input_antenna_rounded,
        subtitle: 'Broadcast intents & symbologies',
      ),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (index) {
            final cat = categories[index];
            final isSelected = _selectedCategoryIndex == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                borderRadius: BorderRadius.circular(AppRadii.r8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? brandColor.withValues(alpha: 0.15) : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                    border: Border.all(
                      color: isSelected ? brandColor : colorScheme.outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 16, color: isSelected ? brandColor : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      AppGap.w8,
                      Text(
                        cat.title,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? brandColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                      AppGap.w8,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? brandColor : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cat.badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 950;

        return Row(
          children: List.generate(categories.length, (index) {
            final cat = categories[index];
            final isSelected = _selectedCategoryIndex == index;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < categories.length - 1 ? 12.0 : 0),
                child: Material(
                  color: isSelected ? brandColor.withValues(alpha: 0.08) : colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                    child: Container(
                      padding: AppPadding.p16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.r12),
                        border: Border.all(
                          color: isSelected ? brandColor : colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isSelected ? brandColor : colorScheme.primary).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadii.r8),
                                ),
                                child: Icon(cat.icon, size: 18, color: isSelected ? brandColor : colorScheme.primary),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected ? brandColor : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  cat.badge,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppGap.h12,
                          Text(
                            cat.title,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? brandColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isNarrow) ...[
                            AppGap.h4,
                            Text(
                              cat.subtitle,
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSelectedStudioView(Color brandColor) {
    switch (_selectedCategoryIndex) {
      case 0:
        return BarcodeScannerView(brandColor: brandColor);
      case 1:
        return const ThermalPrinterView();
      case 2:
        return const DigitalScaleView();
      case 3:
        return const PdaConfigView();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HardwareCategory {
  final String title;
  final String badge;
  final IconData icon;
  final String subtitle;

  _HardwareCategory({
    required this.title,
    required this.badge,
    required this.icon,
    required this.subtitle,
  });
}
