import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltheguide/safety_page.dart';

void main() {
  testWidgets('shows Malaysia emergency numbers and at least one safety tip', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SafetyPage()));
    await tester.pump();

    expect(find.text('999'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.textContaining('licensed taxis'), findsOneWidget);
  });
}
