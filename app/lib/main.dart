import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/shoku_theme.dart';
import 'data/services/prefs.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/state/shoku_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read the persisted flag before the first frame so onboarding never flashes.
  final seen = await Prefs.onboardingDone();
  runApp(
    ProviderScope(
      overrides: [
        onboardingDoneProvider.overrideWith((ref) => seen),
      ],
      child: const ShokuApp(),
    ),
  );
}

class ShokuApp extends ConsumerWidget {
  const ShokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingDoneProvider);

    final app = onboardingDone
        ? MaterialApp.router(
            title: 'Shoku',
            debugShowCheckedModeBanner: false,
            theme: ShokuTheme.light(),
            darkTheme: ShokuTheme.dark(),
            themeMode: mode,
            routerConfig: appRouter,
          )
        : MaterialApp(
            title: 'Shoku',
            debugShowCheckedModeBanner: false,
            theme: ShokuTheme.light(),
            darkTheme: ShokuTheme.dark(),
            themeMode: mode,
            home: const OnboardingScreen(),
          );

    return app;
  }
}
