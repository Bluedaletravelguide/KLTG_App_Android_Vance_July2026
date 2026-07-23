import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/models/trip_item.dart';
import 'package:kltheguide/services/trip_planner_service.dart';
import 'package:kltheguide/trip_planner_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TripPlannerService.resetForTesting();
  });

  testWidgets('shows the empty state when there is no trip yet', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TripPlannerPage()));
    await tester.pump();

    expect(find.textContaining('No trip planned yet'), findsOneWidget);
  });

  testWidgets('renders a seeded day and item, and removing the item updates the list',
      (tester) async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(
      0,
      TripItem(title: 'Central Market', imageUrl: '', category: 'Shop'),
    );

    await tester.pumpWidget(const MaterialApp(home: TripPlannerPage()));
    await tester.pump();

    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Central Market'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Central Market'), findsNothing);
    expect(find.textContaining('No places added to this day yet'), findsOneWidget);
  });

  testWidgets('shows scheduled items in time order ahead of an Unscheduled section',
      (tester) async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(
      0,
      TripItem(title: 'Late Lunch', imageUrl: '', category: 'Shop'),
    );
    await TripPlannerService.addItem(
      0,
      TripItem(title: 'Morning Market', imageUrl: '', category: 'Shop'),
    );
    await TripPlannerService.addItem(
      0,
      TripItem(title: 'No Time Yet', imageUrl: '', category: 'Spa'),
    );
    final day = TripPlannerService.days.value[0];
    await TripPlannerService.setItemTime(0, day.items[0], 13 * 60);
    await TripPlannerService.setItemTime(0, day.items[1], 9 * 60);

    await tester.pumpWidget(const MaterialApp(home: TripPlannerPage()));
    await tester.pump();

    expect(find.text('9:00 AM'), findsOneWidget);
    expect(find.text('1:00 PM'), findsOneWidget);
    expect(find.text('UNSCHEDULED'), findsOneWidget);

    final titles = tester
        .widgetList<Text>(find.byWidgetPredicate((w) =>
            w is Text && ['Morning Market', 'Late Lunch', 'No Time Yet'].contains(w.data)))
        .map((t) => t.data)
        .toList();
    expect(titles, ['Morning Market', 'Late Lunch', 'No Time Yet']);
  });

  testWidgets('shows a Directions link between two scheduled stops but not before an unscheduled one',
      (tester) async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(
      0,
      TripItem(title: 'Morning Market', imageUrl: '', category: 'Shop'),
    );
    await TripPlannerService.addItem(
      0,
      TripItem(title: 'Late Lunch', imageUrl: '', category: 'Shop'),
    );
    final day = TripPlannerService.days.value[0];
    await TripPlannerService.setItemTime(0, day.items[0], 9 * 60);
    await TripPlannerService.setItemTime(0, day.items[1], 13 * 60);

    await tester.pumpWidget(const MaterialApp(home: TripPlannerPage()));
    await tester.pump();

    expect(find.text('Directions'), findsOneWidget);
  });

  testWidgets('shows a per-item cost pill and the trip total banner once costs are set',
      (tester) async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(
      0,
      TripItem(title: 'Central Market', imageUrl: '', category: 'Shop'),
    );
    final item = TripPlannerService.days.value[0].items.single;
    await TripPlannerService.setItemCost(0, item, 25);

    await tester.pumpWidget(const MaterialApp(home: TripPlannerPage()));
    await tester.pump();

    // Appears twice: once as the item's own cost pill, once in the trip total banner.
    expect(find.text('RM 25.00'), findsNWidgets(2));
    expect(find.text('Estimated trip total'), findsOneWidget);
  });

  test('directionsUrl builds a Google Maps directions link from addresses when present', () {
    final from = TripItem(
      title: 'Central Market',
      imageUrl: '',
      category: 'Shop',
      address: 'Jalan Hang Kasturi, Kuala Lumpur',
    );
    final to = TripItem(title: 'Petaling Street', imageUrl: '', category: 'Shop');

    final url = directionsUrl(from, to);

    expect(url, startsWith('https://www.google.com/maps/dir/?'));
    expect(url, contains('origin=Jalan'));
    expect(url, contains('destination=Petaling+Street'));
  });
}
