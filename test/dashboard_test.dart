import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cpsumotorpooldriverapp/pages/dashboard.dart';

void main() {
  testWidgets('dashboard shows trip buttons without the active trips tile', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DriverDashboard()));

    expect(find.text('My Trips'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Scheduled Trips'), findsOneWidget);
    expect(find.text('Active Trips'), findsNothing);
  });
}
