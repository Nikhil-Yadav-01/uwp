import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/hardware_hub_controller.dart';

/// Responsive View for Thermal Label & ESC/POS Receipt Studio.
class ThermalPrinterView extends ConsumerStatefulWidget {
  const ThermalPrinterView({super.key});

  @override
  ConsumerState<ThermalPrinterView> createState() => _ThermalPrinterViewState();
}

class _ThermalPrinterViewState extends ConsumerState<ThermalPrinterView> {
  String _selectedTemplate = 'shipping_4x6';

  final List<Map<String, dynamic>> _templates = const [
    {'id': 'shipping_4x6', 'label': '4x6 Outbound Shipping Label (ZPL)', 'icon': Icons.local_shipping_outlined},
    {'id': 'bin_tag', 'label': '3x1 Warehouse Shelf / Bin Tag (ZPL)', 'icon': Icons.qr_code_2_rounded},
    {'id': 'narcotics_tag', 'label': 'Schedule II Narcotic Vault Tag (ZPL)', 'icon': Icons.security_rounded},
    {'id': 'leather_tag', 'label': 'Leather Tannery Lot Certificate (ZPL)', 'icon': Icons.layers_outlined},
    {'id': 'pos_voucher', 'label': '80mm POS Picklist Voucher (ESC/POS)', 'icon': Icons.receipt_long_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hwState = ref.watch(hardwareHubProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 800;

        final templatePicker = _buildTemplatePicker(context, hwState, isDark, colorScheme);
        final rawPreview = _buildRawPreview(context, hwState, isDark, colorScheme);

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              templatePicker,
              AppGap.h16,
              rawPreview,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: templatePicker),
            AppGap.w16,
            Expanded(flex: 3, child: rawPreview),
          ],
        );
      },
    );
  }

  Widget _buildTemplatePicker(
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
            'Thermal Label & Slip Presets',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          AppGap.h12,

          ..._templates.map((tpl) {
            final isSelected = _selectedTemplate == tpl['id'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.35) : colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedTemplate = tpl['id'] as String);
                    ref.read(hardwareHubProvider.notifier).setZplTemplate(tpl['id'] as String);
                  },
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : colorScheme.outline,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tpl['icon'] as IconData,
                          size: AppSizes.iconSm,
                          color: isSelected ? colorScheme.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        AppGap.w12,
                        Expanded(
                          child: Text(
                            tpl['label'] as String,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? colorScheme.primary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          AppGap.h16,

          FilledButton.icon(
            onPressed: () async {
              await ref.read(hardwareHubProvider.notifier).sendPrintJob();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transmitted raw print job to ${hwState.connectedPrinter?.name ?? 'Thermal Printer'}'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 44),
            ),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text('Send Print Job to Thermal Driver', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRawPreview(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Raw Output Stream Preview',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.r4),
                ),
                child: Text(
                  'Zebra ZT411 • 203 DPI',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.md),

          // Monospace ZPL Container
          Container(
            width: double.infinity,
            height: 240,
            padding: AppPadding.p12,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                hwState.activeZplPreview,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isDark ? const Color(0xFF4EC9B0) : const Color(0xFF006699),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ),
          AppGap.h16,

          // Transmission Log
          Text(
            'Recent Print Transmission Log',
            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
          ),
          AppGap.h8,
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: hwState.printLog.isEmpty
                ? Center(
                    child: Text(
                      'No print jobs sent in this session.',
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: hwState.printLog.length,
                    itemBuilder: (context, idx) {
                      return Text(
                        hwState.printLog[idx],
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
