import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/hardware/scanner/models/scanned_barcode.dart';
import '../../../../core/hardware/scanner/services/multi_barcode_batch_engine.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/hardware_hub_controller.dart';

/// Responsive View for AI Multi-Barcode AR Camera & Laser Scanner Intake.
class BarcodeScannerView extends ConsumerStatefulWidget {
  final Color brandColor;

  const BarcodeScannerView({
    super.key,
    required this.brandColor,
  });

  @override
  ConsumerState<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends ConsumerState<BarcodeScannerView> {
  final _manualCodeController = TextEditingController();

  @override
  void dispose() {
    _manualCodeController.dispose();
    super.dispose();
  }

  void _submitManualCode() {
    final code = _manualCodeController.text.trim();
    if (code.isNotEmpty) {
      ref.read(hardwareHubProvider.notifier).triggerSimulatedLaserScan(code);
      _manualCodeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hwState = ref.watch(hardwareHubProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

        final viewfinder = _buildViewfinder(context, hwState, isDark, colorScheme);
        final intakeFeed = _buildIntakeFeed(context, hwState, isDark, colorScheme);

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              viewfinder,
              AppGap.h16,
              intakeFeed,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: viewfinder),
            AppGap.w16,
            Expanded(flex: 2, child: intakeFeed),
          ],
        );
      },
    );
  }

  Widget _buildViewfinder(
    BuildContext context,
    HardwareHubState hwState,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 380,
      padding: AppPadding.p16,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: widget.brandColor, width: 2),
      ),
      child: Stack(
        children: [
          // Center Reticle Prompt
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 44, color: Colors.white.withValues(alpha: 0.6)),
                AppGap.h12,
                Text(
                  'Aim Camera / Laser at Product Barcodes',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                AppGap.h4,
                Text(
                  'AI Batch Recognition captures multiple barcodes concurrently',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Simulated AR Bounding Boxes
          Positioned(
            top: 24,
            left: 16,
            child: _buildArBoundingBox('TECH-APEX16P-256-BLK (Matched)', AppColors.success),
          ),
          Positioned(
            top: 100,
            right: 16,
            child: _buildArBoundingBox('HC-FNT-50MCG-AMP (Vault)', AppColors.warning),
          ),
          Positioned(
            bottom: 64,
            left: 24,
            child: _buildArBoundingBox('GROC-MILK-1L (Counted)', colorScheme.primary),
          ),

          // Central Target Frame
          Center(
            child: Container(
              width: 240,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                borderRadius: BorderRadius.circular(AppRadii.r8),
              ),
            ),
          ),

          // Bottom Viewfinder Controls Bar
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: Colors.white24),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  IconButton(
                    onPressed: () => ref.read(hardwareHubProvider.notifier).toggleTorch(),
                    icon: Icon(
                      hwState.isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: hwState.isTorchOn ? Colors.yellow : Colors.white70,
                      size: AppSizes.iconSm + 2,
                    ),
                    tooltip: 'Toggle Camera Torch',
                    visualDensity: VisualDensity.compact,
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(hardwareHubProvider.notifier).simulateBatchCameraFrame([
                        const RawDetectedBarcode(rawValue: 'TECH-APEX16P-256-BLK', symbology: BarcodeSymbology.code128),
                        const RawDetectedBarcode(rawValue: 'HC-AMX-500-BX', symbology: BarcodeSymbology.qrCode),
                        const RawDetectedBarcode(rawValue: 'HC-FNT-50MCG-AMP', symbology: BarcodeSymbology.code128),
                        const RawDetectedBarcode(rawValue: 'GROC-MILK-1L', symbology: BarcodeSymbology.ean13),
                      ]);
                    },
                    icon: const Icon(Icons.blur_on_rounded, size: 16),
                    label: const Text('Simulate 4x Batch Capture', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(hardwareHubProvider.notifier).clearScanBatch(),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: AppSizes.iconSm + 2),
                    tooltip: 'Clear Scan Log',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArBoundingBox(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadii.r4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          AppGap.w4,
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIntakeFeed(
    BuildContext context,
    HardwareHubState hwState,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.p16,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laser PDA / Barcode Intake Feed',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          AppGap.h12,

          // Manual / USB Scanner Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Keystroke / Laser Scan Input',
                    prefixIcon: Icon(Icons.keyboard_outlined, size: 18),
                    hintText: 'Scan or type SKU...',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _submitManualCode(),
                ),
              ),
              AppGap.w8,
              IconButton.filled(
                onPressed: _submitManualCode,
                icon: const Icon(Icons.input_rounded, size: 18),
                tooltip: 'Simulate Keystroke Submit',
              ),
            ],
          ),
          AppGap.h16,

          // Feed Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Session Scans (${hwState.scannedBatch.length})',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Debounce Active (1.2s)',
                style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: AppSpacing.md),

          // Scanned Batch List
          if (hwState.scannedBatch.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  'No barcodes scanned yet.\nTrigger laser or camera batch.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hwState.scannedBatch.length,
              separatorBuilder: (context, index) => AppGap.h8,
              itemBuilder: (context, index) {
                final item = hwState.scannedBatch[index];
                final isMatch = item.matchStatus == BarcodeMatchStatus.matched;

                return Container(
                  padding: AppPadding.p12,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                    border: Border.all(
                      color: isMatch ? AppColors.success.withValues(alpha: 0.4) : colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMatch ? Icons.check_circle_rounded : Icons.qr_code_2_rounded,
                        size: AppSizes.iconSm,
                        color: isMatch ? AppColors.success : colorScheme.outline,
                      ),
                      AppGap.w8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.rawCode,
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppGap.h4,
                            Text(
                              '${item.symbology.name.toUpperCase()} • ${item.timestamp.toLocal().toString().substring(11, 19)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppGap.w8,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isMatch ? AppColors.success.withValues(alpha: 0.15) : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                        ),
                        child: Text(
                          item.matchStatus.name.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: isMatch ? AppColors.success : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
