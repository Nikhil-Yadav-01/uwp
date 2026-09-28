import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/hardware_hub_controller.dart';

/// Responsive View for Zebra DataWedge & Honeywell Laser PDA Integration Setup.
class PdaConfigView extends ConsumerWidget {
  const PdaConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hwState = ref.watch(hardwareHubProvider);

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
          // Header & Laser Switch
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zebra DataWedge & Honeywell Laser PDA Integration',
                      style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    AppGap.h4,
                    Text(
                      'Native Android Broadcast Receiver intents and hardware scanner profiles',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.w12,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hwState.isLaserActive ? 'Laser Active' : 'Standby',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hwState.isLaserActive ? AppColors.success : colorScheme.outline,
                    ),
                  ),
                  AppGap.w8,
                  Switch(
                    value: hwState.isLaserActive,
                    onChanged: (_) => ref.read(hardwareHubProvider.notifier).toggleLaserTrigger(),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),

          // Config Properties
          _buildConfigTile(
            icon: Icons.settings_suggest_outlined,
            title: 'DataWedge Profile Name',
            subtitle: hwState.activeDataWedgeProfile,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.r4),
              ),
              child: Text(
                'ACTIVE',
                style: AppTypography.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ),
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          AppGap.h8,
          _buildConfigTile(
            icon: Icons.broadcast_on_personal_rounded,
            title: 'Broadcast Intent Action',
            subtitle: 'com.rudraksha.warehouse.SCAN_EVENT',
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          AppGap.h8,
          _buildConfigTile(
            icon: Icons.data_array_rounded,
            title: 'String Data Extra Key',
            subtitle: 'com.symbol.datawedge.data_string',
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          AppGap.h8,
          _buildConfigTile(
            icon: Icons.category_outlined,
            title: 'Label Type Extra Key',
            subtitle: 'com.symbol.datawedge.label_type',
            isDark: isDark,
            colorScheme: colorScheme,
          ),
          AppGap.h16,

          // Active Symbologies Section
          Text(
            'Active Barcode Symbologies',
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
          ),
          AppGap.h8,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: const [
              _SymbologyChip(label: 'Code 128'),
              _SymbologyChip(label: 'QR Code'),
              _SymbologyChip(label: 'EAN-13'),
              _SymbologyChip(label: 'Data Matrix'),
              _SymbologyChip(label: 'Code 39'),
              _SymbologyChip(label: 'PDF417'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: AppPadding.p12,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm + 2, color: colorScheme.primary),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                ),
                AppGap.h4,
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    fontFamily: 'monospace',
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

class _SymbologyChip extends StatelessWidget {
  final String label;

  const _SymbologyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.check, size: 14, color: AppColors.success),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }
}
