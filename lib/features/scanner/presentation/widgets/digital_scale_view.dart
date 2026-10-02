import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/hardware_hub_controller.dart';

/// Responsive View for Digital Scale, Platter Simulator & Piece Counting Engine.
class DigitalScaleView extends ConsumerStatefulWidget {
  const DigitalScaleView({super.key});

  @override
  ConsumerState<DigitalScaleView> createState() => _DigitalScaleViewState();
}

class _DigitalScaleViewState extends ConsumerState<DigitalScaleView> {
  final _unitWeightController = TextEditingController(text: '0.005');

  @override
  void dispose() {
    _unitWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hwState = ref.watch(hardwareHubProvider);
    final weight = hwState.currentWeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

        final scaleIndicator = _buildScaleIndicator(context, hwState, weight, isDark, colorScheme);
        final pieceCounter = _buildPieceCounter(context, hwState, weight, isDark, colorScheme);

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              scaleIndicator,
              AppGap.h16,
              pieceCounter,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: scaleIndicator),
            AppGap.w16,
            Expanded(flex: 2, child: pieceCounter),
          ],
        );
      },
    );
  }

  Widget _buildScaleIndicator(
    BuildContext context,
    HardwareHubState hwState,
    dynamic weight,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Industrial Scale Indicator',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.r4),
                ),
                child: Text(
                  'BLE SCALE ONLINE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h16,

          // Giant LED Weight Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppRadii.r12),
              border: Border.all(color: Colors.greenAccent, width: 2),
            ),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${weight.netWeight.toStringAsFixed(3)} KG',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                AppGap.h8,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'GROSS: ${weight.grossWeight.toStringAsFixed(3)} KG   |   TARE: ${weight.tareWeight.toStringAsFixed(3)} KG',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Colors.greenAccent.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.h16,

          // Weight Simulation Slider
          Text(
            'Simulate Scale Weight on Platter',
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
          ),
          AppGap.h4,
          Slider(
            value: weight.grossWeight.clamp(0.0, 50.0),
            min: 0.0,
            max: 50.0,
            divisions: 100,
            label: '${weight.grossWeight.toStringAsFixed(2)} kg',
            onChanged: (val) {
              ref.read(hardwareHubProvider.notifier).updateGrossWeight(val);
            },
          ),
          AppGap.h4,

          // Quick Presets
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _buildQuickWeightButton('0.5 kg', 0.5),
              _buildQuickWeightButton('2.45 kg', 2.45),
              _buildQuickWeightButton('5.0 kg', 5.0),
              _buildQuickWeightButton('12.5 kg', 12.5),
              _buildQuickWeightButton('25.0 kg', 25.0),
            ],
          ),
          AppGap.h20,

          // Tare & Zero Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(hardwareHubProvider.notifier).tareScale(),
                  icon: const Icon(Icons.fitness_center_rounded, size: 18),
                  label: const Text('TARE SCALE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              AppGap.w12,
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => ref.read(hardwareHubProvider.notifier).zeroScale(),
                  icon: const Icon(Icons.exposure_zero_rounded, size: 18),
                  label: const Text('ZERO SCALE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieceCounter(
    BuildContext context,
    HardwareHubState hwState,
    dynamic weight,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: AppPadding.p20,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hardware Piece Counter Engine',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          AppGap.h4,
          Text(
            'Calculates unit count from bulk weight',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const Divider(height: AppSpacing.lg),

          TextFormField(
            controller: _unitWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Single Piece Unit Weight (KG)',
              prefixIcon: Icon(Icons.calculate_outlined, size: 18),
              helperText: 'e.g. 0.005 kg for an M8 bolt (5 grams)',
            ),
            onChanged: (val) {
              final w = double.tryParse(val) ?? 0.005;
              ref.read(hardwareHubProvider.notifier).setUnitPieceWeight(w);
            },
          ),
          AppGap.h16,

          // Calculated Quantity Card
          Container(
            width: double.infinity,
            padding: AppPadding.p16,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  'CALCULATED QUANTITY',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppGap.h8,
                Text(
                  '${hwState.calculatedPieceCount} PCS',
                  style: AppTypography.headlineLarge.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppGap.h4,
                Text(
                  'Based on ${weight.netWeight.toStringAsFixed(3)} kg net',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          AppGap.h16,

          // Leather / Produce Derivation Tag
          Container(
            padding: AppPadding.p12,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leather Remnant Surface Area:',
                  style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                ),
                AppGap.h4,
                Text(
                  '~${(weight.netWeight / 0.12).toStringAsFixed(1)} sq. ft. (Bovine Grade A factor)',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickWeightButton(String label, double kg) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      onPressed: () => ref.read(hardwareHubProvider.notifier).updateGrossWeight(kg),
    );
  }
}
