import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/archetypes/presentation/controllers/archetype_controller.dart';
import '../widgets/demo_archetype_switcher_bar.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const List<NavigationItem> kNavigationItems = [
  NavigationItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/'),
  NavigationItem(label: 'Inventory Catalog', icon: Icons.inventory_2_outlined, route: '/products'),
  NavigationItem(label: 'Inbound / PO', icon: Icons.local_shipping_outlined, route: '/inbound'),
  NavigationItem(label: 'Outbound / Waves', icon: Icons.outbox_outlined, route: '/outbound'),
  NavigationItem(label: 'Floorplan 2D', icon: Icons.map_outlined, route: '/floorplan'),
  NavigationItem(label: 'Barcode & AR', icon: Icons.qr_code_scanner_outlined, route: '/scanner'),
  NavigationItem(label: 'POS / Counter', icon: Icons.point_of_sale_outlined, route: '/pos'),
];

/// Multi-Platform Responsive Shell with desktop sidebar, header, and mobile navigation
class ResponsiveShell extends ConsumerWidget {
  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(archetypeProvider);
    final activeArchetype = state.archetype;
    final themeMode = ref.watch(appThemeModeProvider);
    final isDesktop = context.isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRoute = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Row(
              children: [
                if (!isDesktop)
                  Builder(
                    builder: (innerContext) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(innerContext).openDrawer(),
                    ),
                  ),

                // Brand Logo
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(Icons.warehouse_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                if (!context.isMobile) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text('RUDRAKSHA', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.primary)),
                          const SizedBox(width: 4),
                          Text('WMS', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                        ],
                      ),
                      Text('Universal Warehouse Suite', style: AppTypography.bodyBold),
                    ],
                  ),
                ] else ...[
                  Text('RUDRAKSHA', style: AppTypography.bodyBold.copyWith(color: AppColors.primary)),
                ],

                const Spacer(),

                // 1-Click Interactive Demo Archetype Switcher in Top Bar!
                const Flexible(
                  child: DemoArchetypeSwitcherBar(),
                ),
                const SizedBox(width: 8),

                // Theme Mode Toggle (System / Light / Dark)
                IconButton(
                  tooltip: 'Theme: ${themeMode == ThemeMode.system ? "System (Device)" : (themeMode == ThemeMode.dark ? "Dark" : "Light")}',
                  icon: Icon(
                    themeMode == ThemeMode.system
                        ? Icons.brightness_auto_outlined
                        : (themeMode == ThemeMode.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                    size: 20,
                  ),
                  onPressed: () {
                    final nextMode = themeMode == ThemeMode.system
                        ? ThemeMode.light
                        : (themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.system);
                    ref.read(appThemeModeProvider.notifier).state = nextMode;
                  },
                ),
                const SizedBox(width: 8),

                // Quick User Profile Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: activeArchetype.brandColor,
                        child: const Text('SA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      if (context.isDesktop) ...[
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Super Admin', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                            Text('All Permissions', style: AppTypography.caption.copyWith(fontSize: 9, color: AppColors.success)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: isDesktop ? null : Drawer(child: buildSidebarContent(context, currentRoute, activeArchetype, isDark)),
      body: Row(
        children: [
          // Collapsible Desktop Sidebar
          if (isDesktop)
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: buildSidebarContent(context, currentRoute, activeArchetype, isDark),
            ),

          // Main View Content
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget buildSidebarContent(
    BuildContext context,
    String currentRoute,
    dynamic activeArchetype,
    bool isDark,
  ) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'OPERATIONAL MODULES',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: kNavigationItems.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final item = kNavigationItems[index];
              final isSelected = currentRoute == item.route;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    selected: isSelected,
                    selectedTileColor: activeArchetype.brandColor.withValues(alpha: 0.12),
                    leading: Icon(
                      item.icon,
                      size: 18,
                      color: isSelected
                          ? activeArchetype.brandColor
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    title: Text(
                      item.label,
                      style: AppTypography.bodyBold.copyWith(
                        color: isSelected
                            ? activeArchetype.brandColor
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      ),
                    ),
                    onTap: () {
                      context.go(item.route);
                      if (!context.isDesktop) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Organization Status Indicator
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface.withValues(alpha: 0.4) : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Warehouse #01 (Central)', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                    Text('Offline-First Sync: Active', style: AppTypography.caption.copyWith(fontSize: 9, color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
