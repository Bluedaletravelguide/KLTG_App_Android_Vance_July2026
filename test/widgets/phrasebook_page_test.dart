import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltheguide/phrasebook_page.dart';

void main() {
  testWidgets('shows a handful of common English-Malay phrase pairs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PhrasebookPage()));
    await tester.pump();

    expect(find.text('Thank you'), findsOneWidget);
    expect(find.text('Terima kasih'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
}
