import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/notification_inbox_page.dart';
import 'package:kltheguide/services/notification_inbox_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NotificationInboxService.resetForTesting();
  });

  testWidgets('shows the empty state when there are no notifications yet', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationInboxPage()));
    await tester.pump();

    expect(find.textContaining("You're all caught up"), findsOneWidget);
  });

  testWidgets('renders a seeded notification and Clear all empties it', (tester) async {
    await NotificationInboxService.add('New Voucher', 'Check out our latest deal');

    await tester.pumpWidget(const MaterialApp(home: NotificationInboxPage()));
    await tester.pump();

    expect(find.text('New Voucher'), findsOneWidget);
    expect(find.text('Check out our latest deal'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear all'));
    await tester.pump();

    expect(find.text('New Voucher'), findsNothing);
    expect(find.textContaining("You're all caught up"), findsOneWidget);
  });
}
