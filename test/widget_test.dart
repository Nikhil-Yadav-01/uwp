import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/app.dart';

void main() {
  testWidgets('Universal WMS app smoke test & archetype render test', (WidgetTester tester) async {
    // Set desktop window size
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: WarehouseApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Brand Logo and Core App Elements render
    expect(find.text('RUDRAKSHA'), findsWidgets);
    expect(find.text('PROTOTYPE SHOWCASE'), findsOneWidget);
    expect(find.text('Live Operational Metrics'), findsOneWidget);
  });
}
