import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/shoku_theme.dart';
import 'data/services/prefs.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/navigation/back_guard.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/state/shoku_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read the persisted flag before the first frame so onboarding never flashes.
  var onboardingDone = false;
  try {
    onboardingDone = await Prefs.onboardingDone();
  } catch (_) {
    // Storage unavailable (e.g. web preview): show onboarding once.
  }

  runApp(
    ProviderScope(
      overrides: [
        onboardingDoneProvider.overrideWith(
          (ref) => onboardingDone || previewScreen != null,
        ),
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

    if (!onboardingDone) {
      return MaterialApp(
        title: 'Shoku',
        debugShowCheckedModeBanner: false,
        theme: ShokuTheme.light(),
        darkTheme: ShokuTheme.dark(),
        themeMode: mode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: previewStatic),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const OnboardingScreen(),
      );
    }

    return ShokuBackGuard(
      child: MaterialApp.router(
      title: 'Shoku',
      debugShowCheckedModeBanner: false,
      theme: ShokuTheme.light(),
      darkTheme: ShokuTheme.dark(),
      themeMode: mode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: previewStatic),
        child: child ?? const SizedBox.shrink(),
      ),
      routerConfig: appRouter,
      ),
    );
  }
}
