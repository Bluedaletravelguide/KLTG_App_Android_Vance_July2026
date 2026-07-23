// The original file here was the unmodified `flutter create` template
// (a counter smoke test), which doesn't match this app at all and was
// already failing. Pumping the real MyApp() isn't safe in a plain
// `flutter test` run either: main.dart's _checkVersionAndShowDialog()
// calls PackageInfo.fromPlatform() outside its surrounding try/catch,
// which throws MissingPluginException with no platform channel mocks
// registered. So this checks the app's real theme/localization wiring
// instead, without touching MyApp/MyHomePage.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kltheguide/generated/l10n.dart';
import 'package:kltheguide/theme/app_theme.dart';

void main() {
  testWidgets('App theme and localization delegates build without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(body: Text('smoke')),
    ));

    expect(find.text('smoke'), findsOneWidget);
  });
}
