import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/packing_session.dart';

class ShippingLabelModal extends StatelessWidget {
  final PackingSession session;

  const ShippingLabelModal({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracking = session.trackingNumber ?? 'TRK-2026-EXPRESS-001';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.local_shipping_rounded, color: theme.colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shipping Manifest & Label', style: AppTypography.h3),
                        Text('Carrier: ${session.shippingCarrier ?? 'Universal Logistics Freight'}', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(height: 24),

            // Simulated 4x6 Thermal Label Container
            Center(
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
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
                    Text(session.customerName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(session.destination, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ORDER: ${session.soNumber}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                        Text('BOXES: ${session.boxCount} | WT: ${session.totalWeightKg.toStringAsFixed(1)} KG', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                    const Divider(color: Colors.black, thickness: 1, height: 16),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 48,
                            width: 260,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.grey.shade100,
                            ),
                            child: const Center(
                              child: Text('||| | ||||| || |||| ||| ||||| |||| ||', style: TextStyle(color: Colors.black, fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(tracking, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // B2B Magic Tracking Link Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('B2B Client Magic Tracking Link', style: AppTypography.captionBold),
                        Text(
                          session.magicTrackingUrl ?? 'https://wms.universal.io/track/$tracking',
                          style: AppTypography.caption.copyWith(color: theme.colorScheme.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Close'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Simulated printing ZPL label to Thermal Printer (ESC/POS / Zebra Direct)'),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.print_rounded, size: 18),
                  label: const Text('Print 4x6 Label (ZPL)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
