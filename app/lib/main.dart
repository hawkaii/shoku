import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/shoku_theme.dart';
import 'data/services/prefs.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/navigation/back_guard.dart';
import 'presentation/state/journal_store.dart';
import 'presentation/state/shoku_providers.dart';
import 'presentation/state/sync_providers.dart';

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

    // One app, one Navigator, from the first frame. The gate decides which
    // route is allowed to build; swapping MaterialApps would dispose the
    // route builders of the app that is still on screen, which is a crash
    // rather than a transition.
    final auth = ref.watch(authReadyProvider);
    final onboarded = ref.watch(onboardingDoneProvider);
    AppGate.authReady = !auth.isLoading;
    AppGate.onboarded = onboarded;
    ref.listen(authReadyProvider, (previous, next) {
      AppGate.authReady = !next.isLoading;
      appRouter.refresh();
    });
    ref.listen(onboardingDoneProvider, (previous, next) {
      AppGate.onboarded = next;
      appRouter.refresh();
    });
    // Keeps the sync controller alive for the whole app, which is what
    // subscribes it to the auth stream. Without this watch there is no
    // listener, and a pass that ran too early is never retried.
    ref.watch(syncControllerProvider);

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
