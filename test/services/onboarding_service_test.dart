import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kltheguide/services/onboarding_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('hasSeenOnboarding defaults to false on a fresh install', () async {
    expect(await OnboardingService.hasSeenOnboarding(), isFalse);
  });

  test('markSeen persists so hasSeenOnboarding returns true afterwards', () async {
    await OnboardingService.markSeen();
    expect(await OnboardingService.hasSeenOnboarding(), isTrue);
  });
}
