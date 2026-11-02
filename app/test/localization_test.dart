import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/l10n/app_localizations.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';
import 'package:food_finder/presentation/state/locale_provider.dart';
import 'package:food_finder/presentation/widgets/kit/status_badge.dart';
import 'package:food_finder/presentation/widgets/language_picker.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('switching locale changes a known label', (tester) async {
    final container = ProviderContainer(overrides: [
      authReadyProvider.overrideWith((ref) async {}),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const ShokuApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    await container.read(localeProvider.notifier).setLocale(const Locale('hi'));
    await tester.pumpAndSettle();

    expect(find.text('भाषा'), findsOneWidget);
    expect(find.text('Language'), findsNothing);
  });

  testWidgets('the onboarding picker persists the choice and continues',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authReadyProvider.overrideWith((ref) async {})],
      child: const ShokuApp(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'hi');

    // Selecting is the continue gesture: the picker is gone and the intro is
    // on screen.
    expect(find.byType(LanguagePicker), findsNothing);
    expect(find.byKey(const ValueKey('onboarding-primary')), findsOneWidget);
    // Hindi is applied immediately: the intro CTA is already in Hindi.
    expect(find.text('खाना बनाना शुरू करें'), findsOneWidget);
  });

  testWidgets('the You language sheet persists the choice', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ShokuTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: shokuSupportedLocalesForTest,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showLanguagePickerSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguagePicker), findsOneWidget);

    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'fr');
    expect(find.byType(LanguagePicker), findsNothing);
  });

  testWidgets('a cookbook badge reads in Spanish', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ShokuTheme.light(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: shokuSupportedLocalesForTest,
        home: const Scaffold(
          body: Center(
            child: StatusBadge(status: DishStatus.cooked, cookCount: 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('COCINADO 2×'), findsOneWidget);
  });
}

/// The generated list is what the app uses through `shokuSupportedLocales`;
/// tests can read it directly to avoid depending on main()'s wiring.
const shokuSupportedLocalesForTest = AppLocalizations.supportedLocales;
