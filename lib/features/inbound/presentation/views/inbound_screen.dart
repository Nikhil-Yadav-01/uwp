import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class InboundScreen extends ConsumerWidget {
  const InboundScreen({super.key});

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
                  Text('Inbound Receiving & Purchase Orders', style: AppTypography.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Dock receiving, QC inspection gate & directed putaway for ${archetype.name}',
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
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Purchase Order'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Inbound Pipeline Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final steps = [
                {'title': '1. PO Pending', 'count': '4 Orders', 'icon': Icons.description_outlined, 'color': AppColors.info},
                {'title': '2. Arrived at Dock', 'count': '2 Shipments', 'icon': Icons.local_shipping_outlined, 'color': AppColors.warning},
                {'title': '3. QC Inspection', 'count': '1 Batch', 'icon': Icons.fact_check_outlined, 'color': archetype.brandColor},
                {'title': '4. Putaway Ready', 'count': '6 Pallets', 'icon': Icons.move_to_inbox_outlined, 'color': AppColors.success},
              ];

              return Row(
                children: steps.map((s) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(s['icon'] as IconData, size: 20, color: s['color'] as Color),
                          const SizedBox(height: 10),
                          Text(s['count'] as String, style: AppTypography.h2),
                          Text(s['title'] as String, style: AppTypography.caption.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Active Shipments Table Card
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
                    Text('Active Inbound Shipments', style: AppTypography.h3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Live Dock Telemetry', style: AppTypography.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: archetype.brandColor.withValues(alpha: 0.15),
                    child: Icon(Icons.inventory_2_outlined, color: archetype.brandColor, size: 20),
                  ),
                  title: Text('PO-2026-089 • Global Suppliers Corp', style: AppTypography.bodyBold),
                  subtitle: Text('Expected: 240 units • QC Checklist: Verified Grade & Barcode Scan', style: AppTypography.caption),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: archetype.brandColor, foregroundColor: Colors.white),
                    child: const Text('Start Putaway'),
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
