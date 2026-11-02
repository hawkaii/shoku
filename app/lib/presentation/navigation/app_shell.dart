import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/sample_recipe.dart';
import '../../data/services/share_intake.dart';
import '../screens/add/import_sheet.dart';
import '../state/journal_store.dart';
import '../state/sync_providers.dart';
import '../widgets/kit/nav.dart';
import 'import_scope.dart';
import 'sync_underline.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  static const _tabs = [
    ShokuTabItem(Icons.menu_book_outlined, Icons.menu_book, 'Journal'),
    ShokuTabItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Cookbook'),
    ShokuTabItem(Icons.kitchen_outlined, Icons.kitchen, 'Fridge'),
    ShokuTabItem(Icons.grid_view_outlined, Icons.grid_view, 'Wall'),
    ShokuTabItem(Icons.person_outline, Icons.person, 'You'),
  ];

  /// The fridge sits in the middle of the bar as a raised door, but it is a
  /// branch like any other — see [ShokuTabBar.centerIndex].
  static const _fridgeBranch = 2;

  final _intake = ShareIntake();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _intake.start(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingShare());
    // Pull whatever changed while the app was closed. Quiet by design: a
    // failed sync is a state, not an error the user has to dismiss. The auth
    // stream owns every attempt after this one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(syncControllerProvider).syncNow();
    });
    // A kitchen with no account gets one labelled sample so the loop can be
    // felt; a signed-in one has it taken away.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        ref.read(journalStoreProvider.notifier).ensureSample(
              signedIn: ref.read(authServiceProvider).isSignedIn,
              sample: SampleRecipe.dish(),
            );
      } catch (_) {
        // The sample is optional; the shell is not.
      }
    });
    // On web the session is restored from storage *after* the first frame, so
    // the first pass can reach the API with no token. One more look a few
    // seconds later is what turns a signed-in reload into a filled journal.
    Timer(const Duration(seconds: 3), () {
      if (mounted) ref.read(syncControllerProvider).syncNow();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncControllerProvider).onResume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intake.dispose();
    super.dispose();
  }

  void _consumePendingShare() {
    final url = ref.read(pendingShareProvider);
    if (url == null || !mounted) return;
    ref.read(pendingShareProvider.notifier).state = null;
    HapticFeedback.mediumImpact();
    showImportSheet(context, prefill: url);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(pendingShareProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _consumePendingShare());
      }
    });

    return ImportTrackerScope(
      // The import poller's lifetime is the app's, not the Journal's: a job
      // that settles while another tab is open still lands.
      child: Scaffold(
        body: widget.shell,
        bottomNavigationBar: ShokuTabBar(
          items: _tabs,
          index: widget.shell.currentIndex,
          centerIndex: _fridgeBranch,
          activeUnderline: const SyncUnderline(),
          onChanged: (i) => widget.shell.goBranch(
            i,
            initialLocation: i == widget.shell.currentIndex,
          ),
        ),
      ),
    );
  }
}
