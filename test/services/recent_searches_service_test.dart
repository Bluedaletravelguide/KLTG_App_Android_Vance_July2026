import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/services/recent_searches_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getRecent is empty on a fresh install', () async {
    expect(await RecentSearchesService.getRecent(), isEmpty);
  });

  test('add puts the newest query first and dedupes case-insensitively', () async {
    await RecentSearchesService.add('spa');
    await RecentSearchesService.add('shop');
    await RecentSearchesService.add('SPA');

    expect(await RecentSearchesService.getRecent(), ['SPA', 'shop']);
  });

  test('add caps the list at 8 entries', () async {
    for (var i = 0; i < 10; i++) {
      await RecentSearchesService.add('query $i');
    }
    final recent = await RecentSearchesService.getRecent();
    expect(recent, hasLength(8));
    expect(recent.first, 'query 9');
  });

  test('clear empties the list', () async {
    await RecentSearchesService.add('spa');
    await RecentSearchesService.clear();
    expect(await RecentSearchesService.getRecent(), isEmpty);
  });
}
