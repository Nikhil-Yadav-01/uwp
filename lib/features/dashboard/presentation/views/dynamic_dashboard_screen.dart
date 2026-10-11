import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/executive_command_bar.dart';
import '../widgets/dashboard_vital_signs_ribbon.dart';
import '../widgets/urgent_exceptions_panel.dart';
import '../widgets/operational_pipeline_flow.dart';
import '../widgets/industry_intelligence_card.dart';
import '../widgets/velocity_and_capacity_grid.dart';
import '../widgets/live_floor_activity_feed.dart';

/// Enterprise WMS Executive Operations Cockpit
/// Combines Universal Warehouse Flow Governance with Deep Industry Archetype Intelligence
class DynamicDashboardScreen extends ConsumerWidget {
  const DynamicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: context.screenWidth <= 360
            ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0)
            : (context.isMobile
                ? AppSpacing.pagePaddingMobile
                : AppSpacing.pagePadding),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Layer 1: Executive Command Bar & Quick Actions
            ExecutiveCommandBar(),
            SizedBox(height: AppSpacing.lg),

            // Layer 2: Core Vital Signs KPI Ribbon
            DashboardVitalSignsRibbon(),
            SizedBox(height: AppSpacing.lg),

            // Layer 3: Urgent Action & Exception Center
            UrgentExceptionsPanel(),
            SizedBox(height: AppSpacing.lg),

            // Layer 4: Dock-to-Door Operational Pipeline Flow
            OperationalPipelineFlow(),
            SizedBox(height: AppSpacing.lg),

            // Layer 5: Specialized Industry Archetype Intelligence Panel
            IndustryIntelligenceCard(),
            SizedBox(height: AppSpacing.lg),

            // Layer 6: Visual Analytics (Velocity Curve & Storage Density)
            VelocityAndCapacityGrid(),
            SizedBox(height: AppSpacing.lg),

            // Layer 7: Real-Time Floor Activity Ledger & Audit Trail
            LiveFloorActivityFeed(),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
