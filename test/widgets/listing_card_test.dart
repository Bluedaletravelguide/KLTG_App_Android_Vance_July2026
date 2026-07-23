import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/generated/l10n.dart';
import 'package:kltheguide/services/trip_planner_service.dart';
import 'package:kltheguide/widgets/listing_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    supportedLocales: S.delegate.supportedLocales,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TripPlannerService.resetForTesting();
  });

  testWidgets('no Add to Trip button when category is omitted', (tester) async {
    await tester.pumpWidget(_wrap(const ListingCard(
      title: 'Central Market',
      imageUrl: 'https://example.com/image.jpg',
    )));
    await tester.pump();

    expect(find.text('Add to Trip'), findsNothing);
  });

  testWidgets('tapping Add to Trip with no existing days creates Day 1 and confirms',
      (tester) async {
    await tester.pumpWidget(_wrap(const ListingCard(
      title: 'Central Market',
      imageUrl: 'https://example.com/image.jpg',
      category: 'Shop',
    )));
    await tester.pump();

    expect(find.text('Add to Trip'), findsOneWidget);

    await tester.tap(find.text('Add to Trip'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Added to Day 1'), findsOneWidget);
    expect(TripPlannerService.days.value, hasLength(1));
    expect(TripPlannerService.days.value.single.items.single.title, 'Central Market');
  });

  testWidgets('tapping Add to Trip with an existing day opens the day picker',
      (tester) async {
    await TripPlannerService.addDay();

    await tester.pumpWidget(_wrap(const ListingCard(
      title: 'Petaling Street',
      imageUrl: 'https://example.com/image.jpg',
      category: 'Shop',
    )));
    await tester.pump();

    await tester.tap(find.text('Add to Trip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Add to which day?'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('New Day'), findsOneWidget);
  });

  testWidgets('always shows a Share button, even with no category set', (tester) async {
    await tester.pumpWidget(_wrap(const ListingCard(
      title: 'Central Market',
      imageUrl: 'https://example.com/image.jpg',
    )));
    await tester.pump();

    expect(find.byTooltip('Share this place'), findsOneWidget);
  });
}
