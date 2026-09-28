import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/app_radii.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/design/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/shells/modal_shell.dart';
import '../../domain/models/packing_session.dart';

/// Thermal 4x6 ZPL Shipping Label & Manifest Dialog.
class ShippingLabelModal extends StatelessWidget {
  final PackingSession session;

  const ShippingLabelModal({super.key, required this.session});

  static Future<void> show(BuildContext context, {required PackingSession session}) {
    return ModalShell.show(
      context: context,
      maxWidth: 580,
      child: ShippingLabelModal(session: session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tracking = session.trackingNumber ?? 'TRK-2026-EXPRESS-001';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.r8),
                  ),
                  child: Icon(Icons.local_shipping_rounded, color: colorScheme.primary, size: AppSizes.iconMd),
                ),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shipping Manifest & Label',
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppGap.h4,
                      Text(
                        'Carrier: ${session.shippingCarrier ?? 'Universal Logistics Freight'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm + 4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            // Simulated 4x6 Thermal Label Container
            Center(
              child: Container(
                width: 380,
                padding: AppPadding.p16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('UNIVERSAL WMS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('PRIORITY EXPRESS', style: TextStyle(color: Colors.black.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const Divider(color: Colors.black, thickness: 1.5, height: 16),
                    const Text('SHIP TO:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                    Text(
                      session.customerName,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      session.destination,
                      style: const TextStyle(color: Colors.black87, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppGap.h8,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'ORDER: ${session.soNumber}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('BOXES: ${session.boxCount} | WT: ${session.totalWeightKg.toStringAsFixed(1)} KG', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const Divider(color: Colors.black, thickness: 1, height: 16),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 44,
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.grey.shade100,
                            ),
                            child: const Center(
                              child: Text(
                                '||| | ||||| || |||| ||| ||||| |||| ||',
                                style: TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 2.5, fontWeight: FontWeight.w900),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ),
                          AppGap.h4,
                          Text(tracking, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppGap.h16,

            // B2B Magic Tracking Link Box
            Container(
              padding: AppPadding.p12,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, color: colorScheme.primary, size: AppSizes.iconSm),
                  AppGap.w8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'B2B Client Magic Tracking Link',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          session.magicTrackingUrl ?? 'https://wms.universal.io/track/$tracking',
                          style: AppTypography.bodySmall.copyWith(color: colorScheme.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final url = session.magicTrackingUrl ?? 'https://wms.universal.io/track/$tracking';
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied tracking link to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            AppGap.h20,

            // Footer
            if (isNarrow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Simulated printing ZPL label to Thermal Printer (ESC/POS / Zebra Direct)'),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: AppSizes.iconSm),
                    label: const Text('Print 4x6 Label (ZPL)'),
                  ),
                  AppGap.h8,
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                    label: const Text('Close'),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: AppSizes.iconSm),
                    label: const Text('Close'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Simulated printing ZPL label to Thermal Printer (ESC/POS / Zebra Direct)'),
                          backgroundColor: colorScheme.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.print_rounded, size: AppSizes.iconSm),
                    label: const Text('Print 4x6 Label (ZPL)'),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
