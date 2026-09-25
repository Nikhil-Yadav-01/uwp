import 'package:flutter/material.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/app_sizes.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/responsive/responsive.dart';

class NavDestinationItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const NavDestinationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

class AdaptiveNavigationShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestinationItem> destinations;
  final Widget body;
  final Widget? drawerHeader;

  const AdaptiveNavigationShell({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.drawerHeader,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, windowSize) {
        switch (windowSize) {
          case ScreenWindowSize.large:
          case ScreenWindowSize.expanded:
            return _buildDesktopLayout(context);
          case ScreenWindowSize.medium:
            return _buildTabletLayout(context);
          case ScreenWindowSize.compact:
            return _buildMobileLayout(context);
        }
      },
    );
  }

  // Mobile / Compact: Bottom Navigation Bar
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        indicatorColor: AppColors.primaryContainer,
        destinations: destinations
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon ?? item.icon, color: AppColors.primary),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }

  // Tablet / Medium: Left Navigation Rail
  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: drawerHeader,
            indicatorColor: AppColors.primaryContainer,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            destinations: destinations
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon ?? item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppColors.borderLight),
          Expanded(child: body),
        ],
      ),
    );
  }

  // Desktop / Expanded & Ultra-Wide TV: Fixed Left Sidebar + Constrained Content Alignment
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: AppSizes.sidebarWidth,
            child: Material(
              color: AppColors.surfaceLight,
              child: Column(
                children: [
                  ?drawerHeader,
                  Expanded(
                    child: ListView.builder(
                      itemCount: destinations.length,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      itemBuilder: (context, index) {
                        final item = destinations[index];
                        final isSelected = index == currentIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                              ),
                            ),
                            onTap: () => onDestinationSelected(index),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: AppColors.borderLight),
          Expanded(
            child: Responsive.constrainedContent(child: body),
          ),
        ],
      ),
    );
  }
}
