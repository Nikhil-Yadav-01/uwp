import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/archetypes/presentation/controllers/archetype_controller.dart';
import 'features/dashboard/presentation/views/dynamic_dashboard_screen.dart';
import 'features/inbound/presentation/views/inbound_screen.dart';
import 'features/inventory_ledger/presentation/views/inventory_ledger_screen.dart';
import 'features/outbound/presentation/views/outbound_screen.dart';
import 'features/pos_billing/presentation/views/pos_screen.dart';
import 'features/products/presentation/views/products_catalog_screen.dart';
import 'features/scanner/presentation/views/scanner_screen.dart';
import 'features/warehouse_layout/presentation/views/floorplan_screen.dart';
import 'shared/layouts/responsive_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ResponsiveShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DynamicDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductsCatalogScreen(),
            ),
          ),
          GoRoute(
            path: '/inbound',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InboundScreen(),
            ),
          ),
          GoRoute(
            path: '/outbound',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OutboundScreen(),
            ),
          ),
          GoRoute(
            path: '/ledger',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InventoryLedgerScreen(),
            ),
          ),
          GoRoute(
            path: '/floorplan',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FloorplanScreen(),
            ),
          ),
          GoRoute(
            path: '/scanner',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScannerScreen(),
            ),
          ),
          GoRoute(
            path: '/pos',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PosScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

class WarehouseApp extends ConsumerWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeProfile = ref.watch(currentArchetypeThemeProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'Universal WMS',
      debugShowCheckedModeBanner: false,
      theme: themeProfile.toThemeData(Brightness.light),
      darkTheme: themeProfile.toThemeData(Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
