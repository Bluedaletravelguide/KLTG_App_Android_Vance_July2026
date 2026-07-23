import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltheguide/travel_tools_page.dart';

void main() {
  testWidgets('lists the three travel tools', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TravelToolsPage()));
    await tester.pump();

    expect(find.text('Currency Converter'), findsOneWidget);
    expect(find.text('Phrasebook'), findsOneWidget);
    expect(find.text('Safety & Emergency'), findsOneWidget);
  });

  testWidgets('tapping Phrasebook navigates to the phrasebook page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TravelToolsPage()));
    await tester.pump();

    await tester.tap(find.text('Phrasebook'));
    await tester.pumpAndSettle();

    expect(find.text('Terima kasih'), findsOneWidget);
  });
}
