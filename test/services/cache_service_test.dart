import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/services/cache_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CacheService.isServingCachedContent.value = false;
  });

  String encode(String v) => v;
  String decode(String raw) => raw;

  test('successful fetch returns the value, resets the flag, and persists it', () async {
    final result = await CacheService.cached<String>(
      key: 'greeting',
      fetch: () async => 'hello',
      encode: encode,
      decode: decode,
    );

    expect(result, 'hello');
    expect(CacheService.isServingCachedContent.value, isFalse);

    // The write is fire-and-forget; give it a turn of the event loop.
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('cache_greeting'), 'hello');
  });

  test('failing fetch falls back to a previously cached value and flips the flag', () async {
    // Warm the cache with a successful call first.
    await CacheService.cached<String>(
      key: 'greeting',
      fetch: () async => 'hello',
      encode: encode,
      decode: decode,
    );
    await Future<void>.delayed(Duration.zero);
    CacheService.isServingCachedContent.value = false;

    final result = await CacheService.cached<String>(
      key: 'greeting',
      fetch: () async => throw Exception('network down'),
      encode: encode,
      decode: decode,
    );

    expect(result, 'hello');
    expect(CacheService.isServingCachedContent.value, isTrue);
  });

  test('failing fetch with nothing cached rethrows the original error', () async {
    expect(
      () => CacheService.cached<String>(
        key: 'never_fetched',
        fetch: () async => throw Exception('network down'),
        encode: encode,
        decode: decode,
      ),
      throwsA(isA<Exception>()),
    );
  });
}
