import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/shoku_theme.dart';
import 'data/services/prefs.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/navigation/back_guard.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/state/journal_store.dart';
import 'presentation/state/shoku_providers.dart';
import 'presentation/state/sync_providers.dart';
import 'presentation/widgets/kit/plate_mark.dart';

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
        // The journal calls this after every local change. Bound here so the
        // store stays ignorant of HTTP and the sync layer owns the policy.
        syncHookProvider.overrideWith(
          (ref) => ref.watch(syncControllerProvider).syncNow,
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

    // The session opens behind a splash, not in front of the first frame:
    // Supabase can spend a network round trip restoring and refreshing a token,
    // and a blank window is a worse answer than the mark on paper.
    final auth = ref.watch(authReadyProvider);
    if (auth.isLoading) {
      return MaterialApp(
        title: 'Shoku',
        debugShowCheckedModeBanner: false,
        theme: ShokuTheme.light(),
        darkTheme: ShokuTheme.dark(),
        themeMode: mode,
        home: const _Splash(),
      );
    }

    // Keeps the sync controller alive for the whole app, which is what
    // subscribes it to the auth stream. Without this watch there is no
    // listener, and a pass that ran too early is never retried.
    ref.watch(syncControllerProvider);

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

/// The first frame: the mark, on paper, while the session opens behind it.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.canvas,
      body: const Center(child: PlateMark(size: 64)),
    );
  }
}
