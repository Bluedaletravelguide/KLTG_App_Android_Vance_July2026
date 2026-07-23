import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/models/trip_item.dart';
import 'package:kltheguide/services/trip_planner_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TripPlannerService.resetForTesting();
  });

  TripItem place(String title, {String category = 'Shop'}) =>
      TripItem(title: title, imageUrl: 'https://example.com/$title.jpg', category: category);

  test('addDay labels sequentially', () async {
    final day1 = await TripPlannerService.addDay();
    final day2 = await TripPlannerService.addDay();

    expect(day1.label, 'Day 1');
    expect(day2.label, 'Day 2');
    expect(TripPlannerService.days.value.map((d) => d.label), ['Day 1', 'Day 2']);
  });

  test('addItem adds a place and dedupes by title+category', () async {
    await TripPlannerService.addDay();

    final added = await TripPlannerService.addItem(0, place('Central Market'));
    final addedAgain = await TripPlannerService.addItem(0, place('Central Market'));

    expect(added, isTrue);
    expect(addedAgain, isFalse);
    expect(TripPlannerService.days.value[0].items, hasLength(1));
  });

  test('addItem allows the same title under a different category', () async {
    await TripPlannerService.addDay();

    await TripPlannerService.addItem(0, place('The Bee', category: 'Shop'));
    await TripPlannerService.addItem(0, place('The Bee', category: 'Stay'));

    expect(TripPlannerService.days.value[0].items, hasLength(2));
  });

  test('removeItem removes only the matching place', () async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(0, place('Central Market'));
    await TripPlannerService.addItem(0, place('Petaling Street'));

    await TripPlannerService.removeItem(0, place('Central Market'));

    expect(TripPlannerService.days.value[0].items.map((i) => i.title), ['Petaling Street']);
  });

  test('removeDay renumbers survivors contiguously', () async {
    await TripPlannerService.addDay(); // Day 1
    await TripPlannerService.addDay(); // Day 2
    await TripPlannerService.addDay(); // Day 3
    await TripPlannerService.addItem(2, place('Day 3 place'));

    await TripPlannerService.removeDay(0); // remove Day 1

    final days = TripPlannerService.days.value;
    expect(days.map((d) => d.label), ['Day 1', 'Day 2']);
    // The old Day 3's item followed it to the new Day 2 slot.
    expect(days[1].items.single.title, 'Day 3 place');

    // A later addDay() must not collide with the survivor's relabeled "Day 2".
    final newDay = await TripPlannerService.addDay();
    expect(newDay.label, 'Day 3');
  });

  test('setItemTime sets, updates, and clears a place\'s scheduled time', () async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(0, place('Central Market'));
    final item = TripPlannerService.days.value[0].items.single;
    expect(item.scheduledMinutes, isNull);

    await TripPlannerService.setItemTime(0, item, 9 * 60);
    expect(TripPlannerService.days.value[0].items.single.scheduledMinutes, 540);

    await TripPlannerService.setItemTime(0, item, 14 * 60 + 30);
    expect(TripPlannerService.days.value[0].items.single.scheduledMinutes, 870);

    await TripPlannerService.setItemTime(0, item, null);
    expect(TripPlannerService.days.value[0].items.single.scheduledMinutes, isNull);
  });

  test('itemsInScheduleOrder sorts scheduled items first, unscheduled after', () async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(0, place('Late Lunch'));
    await TripPlannerService.addItem(0, place('Morning Market'));
    await TripPlannerService.addItem(0, place('No Time Yet'));

    final day = TripPlannerService.days.value[0];
    await TripPlannerService.setItemTime(0, day.items[0], 13 * 60);
    await TripPlannerService.setItemTime(0, day.items[1], 9 * 60);

    final ordered = TripPlannerService.days.value[0].itemsInScheduleOrder;
    expect(ordered.map((i) => i.title), ['Morning Market', 'Late Lunch', 'No Time Yet']);
  });

  test('setItemCost sets, updates, and clears a place\'s estimated cost', () async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(0, place('Central Market'));
    final item = TripPlannerService.days.value[0].items.single;
    expect(item.estimatedCost, isNull);

    await TripPlannerService.setItemCost(0, item, 25.5);
    expect(TripPlannerService.days.value[0].items.single.estimatedCost, 25.5);

    await TripPlannerService.setItemCost(0, item, 40);
    expect(TripPlannerService.days.value[0].items.single.estimatedCost, 40);

    await TripPlannerService.setItemCost(0, item, null);
    expect(TripPlannerService.days.value[0].items.single.estimatedCost, isNull);
  });

  test('setItemCost does not disturb an already-set scheduled time, and vice versa', () async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(0, place('Central Market'));
    final item = TripPlannerService.days.value[0].items.single;

    await TripPlannerService.setItemTime(0, item, 9 * 60);
    await TripPlannerService.setItemCost(0, TripPlannerService.days.value[0].items.single, 25);
    var updated = TripPlannerService.days.value[0].items.single;
    expect(updated.scheduledMinutes, 540);
    expect(updated.estimatedCost, 25);

    await TripPlannerService.setItemTime(0, updated, 14 * 60);
    updated = TripPlannerService.days.value[0].items.single;
    expect(updated.scheduledMinutes, 840);
    expect(updated.estimatedCost, 25);
  });

  test('TripDay.totalCost sums only items with a cost entered', () async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(0, place('Central Market'));
    await TripPlannerService.addItem(0, place('Petaling Street'));
    final items = TripPlannerService.days.value[0].items;
    await TripPlannerService.setItemCost(0, items[0], 25);
    await TripPlannerService.setItemCost(0, items[1], 14.5);

    expect(TripPlannerService.days.value[0].totalCost, 39.5);
  });

  test('state round-trips through persistence', () async {
    await TripPlannerService.addDay();
    await TripPlannerService.addItem(0, place('Central Market'));

    TripPlannerService.resetForTesting();
    await TripPlannerService.ensureLoaded();

    final days = TripPlannerService.days.value;
    expect(days, hasLength(1));
    expect(days[0].label, 'Day 1');
    expect(days[0].items.single.title, 'Central Market');
  });
}
