import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/archetypes/models/archetype_definition.dart';
import '../../../archetypes/presentation/controllers/archetype_controller.dart';

class IndustryIntelligenceCard extends ConsumerWidget {
  const IndustryIntelligenceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(archetypeProvider);
    final archetype = state.archetype;
    final handler = state.handler;
    final kpis = handler.getDashboardKPIs();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: archetype.brandColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: archetype.brandColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final infoWidget = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: archetype.brandColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      boxShadow: [
                        BoxShadow(
                          color: archetype.brandColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(archetype.icon, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Vertical Intelligence: ${archetype.name}',
                              style: AppTypography.h3,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: archetype.brandColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'UOM: ${archetype.primaryUom.toUpperCase()}',
                                style: AppTypography.caption.copyWith(
                                  color: archetype.brandColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          archetype.tagLine,
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final badgeWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  'SPECIALIZED LOGIC ACTIVE',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: archetype.brandColor,
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    infoWidget,
                    const SizedBox(height: 8),
                    badgeWidget,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: infoWidget),
                  const SizedBox(width: 12),
                  badgeWidget,
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Dynamic Domain KPI Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000
                  ? 4
                  : (constraints.maxWidth > 550 ? 2 : 1);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kpis.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: crossAxisCount == 1 ? (constraints.maxWidth < 400 ? 2.0 : 2.4) : 1.7,
                ),
                itemBuilder: (context, index) {
                  final kpi = kpis[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: kpi.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                kpi.label,
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(kpi.icon, size: 16, color: kpi.color),
                          ],
                        ),
                        Text(
                          kpi.value,
                          style: AppTypography.h2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            if (kpi.trend != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: kpi.isPositiveTrend
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  kpi.trend!,
                                  style: AppTypography.caption.copyWith(
                                    color: kpi.isPositiveTrend ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (kpi.subtitle != null)
                              Expanded(
                                child: Text(
                                  kpi.subtitle!,
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Deep Vertical Interactive Feature Widget
          _buildSpecializedFeatureSection(archetype.type, archetype.brandColor, isDark),
        ],
      ),
    );
  }

  Widget _buildSpecializedFeatureSection(
    BusinessArchetypeType type,
    Color brandColor,
    bool isDark,
  ) {
    switch (type) {
      case BusinessArchetypeType.electronicsAndTech:
        return _buildElectronicsFeature(brandColor, isDark);
      case BusinessArchetypeType.groceryAndPerishables:
        return _buildGroceryFeature(brandColor, isDark);
      case BusinessArchetypeType.fashionAndApparel:
        return _buildFashionFeature(brandColor, isDark);
      case BusinessArchetypeType.healthcareAndPharma:
        return _buildHealthcareFeature(brandColor, isDark);
      default:
        return _buildDefaultWorkflowFeature(type, brandColor, isDark);
    }
  }

  Widget _buildFeatureHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String statusText,
    required Color statusColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 550;
        final titleRow = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: AppTypography.bodyBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

        final statusWidget = Text(
          statusText,
          style: AppTypography.caption.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              const SizedBox(height: 4),
              statusWidget,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: titleRow),
            const SizedBox(width: 8),
            statusWidget,
          ],
        );
      },
    );
  }

  Widget _buildElectronicsFeature(Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: brandColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureHeader(
            icon: Icons.qr_code_2_rounded,
            iconColor: brandColor,
            title: 'Active Serialized Devices in Staging',
            statusText: '100% Dual IMEI Verification Scan Active',
            statusColor: AppColors.success,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip('iPhone 15 Pro Max', 'IMEI: 358921094827104', 'Brand New Sealed', AppColors.success, isDark),
              _chip('Sony WH-1000XM5', 'S/N: SONY-9921-X', 'QC Passed', AppColors.info, isDark),
              _chip('Samsung S24 Ultra', 'IMEI: 359012384719283', 'Warranty Active', AppColors.primary, isDark),
              _chip('MacBook Pro M3', 'S/N: C02G9012MD6', 'RMA Repair Staged', AppColors.warning, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryFeature(Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: brandColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureHeader(
            icon: Icons.ac_unit_rounded,
            iconColor: AppColors.info,
            title: 'Cold-Chain Telemetry & FEFO Shelf-Life Alerts',
            statusText: 'Freezer -18.4°C • Chiller +3.8°C (Optimal)',
            statusColor: AppColors.success,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip('Whole Organic Milk (1L)', 'Exp: 3 Days (FEFO #1)', '15% Markdown Active', AppColors.error, isDark),
              _chip('Fresh Atlantic Salmon', 'Chilled +2.1°C', 'Passed Temp QC', AppColors.success, isDark),
              _chip('Greek Yogurt Batches', 'Exp: 8 Days (FEFO #2)', 'Allocated to Outbound', AppColors.warning, isDark),
              _chip('Cold Storage Zone B', 'Defrost Cycle Completed', 'Stable', AppColors.info, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFashionFeature(Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: brandColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureHeader(
            icon: Icons.grid_view_rounded,
            iconColor: brandColor,
            title: 'Garment Matrix Availability (Size × Color Depth)',
            statusText: 'Season FW26 • 91.8% Matrix Completeness',
            statusColor: brandColor,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip('Slim Oxford Shirt', 'Sizes: S / M / L / XL', 'Navy • 180 Units', AppColors.primary, isDark),
              _chip('Merino Wool Crewneck', 'Sizes: M / L / XXL', 'Charcoal • 94 Units', AppColors.secondary, isDark),
              _chip('Denim Tapered Fit', 'Size 32/32 Stock Low', 'Reorder Triggered', AppColors.error, isDark),
              _chip('Fitting Room Returns', '14 Garments', 'Steam & Tag Staging', AppColors.warning, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthcareFeature(Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: brandColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureHeader(
            icon: Icons.health_and_safety_rounded,
            iconColor: AppColors.error,
            title: 'Controlled Substances Vault & Compliance Witness Log',
            statusText: 'Schedule II Dual-Auth Signed Today',
            statusColor: AppColors.success,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip('Morphine Sulfate 10mg', 'Vault A-01 Sealed', 'Dual Signed by Dr. Rao', AppColors.error, isDark),
              _chip('Emergency Crash Carts', '8 of 8 Stationed', 'ICU / ER / OR Ready', AppColors.success, isDark),
              _chip('Insulin Glargine', '+4.2°C Continuous', 'CDC Cold Band Verified', AppColors.info, isDark),
              _chip('Amoxicillin 500mg Batch', 'Lot #AMX-2026', 'Expiring in 28 Days', AppColors.warning, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultWorkflowFeature(BusinessArchetypeType type, Color brandColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: brandColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.precision_manufacturing_rounded, size: 18, color: brandColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Domain Logic: Auto-grading intake, scrap deduction, and unit conversions active for this facility.',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String title, String subtitle, String tag, Color tagColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  subtitle,
                  style: AppTypography.monospace.copyWith(
                    fontSize: 10,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              tag,
              style: AppTypography.caption.copyWith(
                color: tagColor,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
