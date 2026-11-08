import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../data/services/pending_share.dart';
import '../../data/services/share_intake.dart';
import '../../l10n/app_localizations.dart';
import '../screens/add/import_sheet.dart';
import '../state/journal_store.dart';
import '../state/sync_providers.dart';
import '../widgets/kit/bot_orb.dart';
import '../widgets/kit/nav.dart';
import 'import_scope.dart';
import 'sync_underline.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  /// Built in `build`, not const: the five words are copy, and copy is the one
  /// thing that changes with the language.
  List<ShokuTabItem> _tabs(AppLocalizations l10n) => [
        ShokuTabItem(
            Icons.menu_book_outlined, Icons.menu_book, l10n.tabJournal),
        ShokuTabItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu,
            l10n.tabCookbook),
        ShokuTabItem(Icons.kitchen_outlined, Icons.kitchen, l10n.tabFridge),
        ShokuTabItem(Icons.grid_view_outlined, Icons.grid_view, l10n.tabWall),
        ShokuTabItem(Icons.person_outline, Icons.person, l10n.tabYou),
      ];

  /// The fridge sits in the middle of the bar as a raised door, but it is a
  /// branch like any other — see [ShokuTabBar.centerIndex].
  static const _fridgeBranch = 2;

  /// True while the share is being taken, so the post-frame call and the
  /// listener cannot both open the sheet for one share.
  bool _takingShare = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Intake itself runs at app scope (see `shareIntakeProvider`); this is only
    // the hand-over, and it has two sources. The persisted note is the
    // cold-start path — a share that arrived while onboarding or the splash was
    // up, or before the process died — so it is read first. The live listener in
    // `build` covers a share that arrives while the shell is already up.
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingShare());
    // Pull whatever changed while the app was closed. Quiet by design: a
    // failed sync is a state, not an error the user has to dismiss. The auth
    // stream owns every attempt after this one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // A local re-read, not a sync: if the store finished its first boot
      // before this branch mounted, the Journal still starts from the rows the
      // database actually holds.
      ref.read(journalStoreProvider.notifier).reload();
      ref.read(syncControllerProvider).syncNow();
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
    super.dispose();
  }

  /// Hands one pending share to the import sheet, once.
  ///
  /// The store is read first: it is the copy that outlived onboarding, the
  /// splash and a killed process. The in-memory provider covers a share the live
  /// listener delivered a moment ago, and wins when both name one, because
  /// intake writes the note before it publishes. Both are cleared before the
  /// sheet opens, so nothing can open it twice for the same share.
  Future<void> _consumePendingShare() async {
    if (!mounted || _takingShare) return;
    _takingShare = true;
    try {
      final stored = await ref.read(pendingShareStoreProvider).take();
      // The live value is at least as new as the note (intake writes the note
      // first), so it wins when both name a share.
      final pending = ref.read(pendingShareProvider) ?? stored;
      if (pending == null || !mounted) return;
      ref.read(pendingShareProvider.notifier).state = null;
      unawaited(HapticFeedback.mediumImpact());
      unawaited(showImportSheet(
        context,
        prefill: pending.url,
        // A share with no link is not silence: the sheet says why it is empty.
        notice: pending.hasUrl ? null : context.l10n.importShareNoLink,
      ));
    } finally {
      _takingShare = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PendingShare?>(pendingShareProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _consumePendingShare());
      }
    });

    return ImportTrackerScope(
      // The import poller's lifetime is the app's, not the Journal's: a job
      // that settles while another tab is open still lands.
      child: Scaffold(
        body: Stack(
          children: [
            widget.shell,
            // The one assistant, on every page the shell owns. Sheets open
            // above the Scaffold, so it is hidden while one is up without any
            // bookkeeping here.
            const Positioned(
              right: 16,
              bottom: 12,
              child: BotOrb(),
            ),
          ],
        ),
        bottomNavigationBar: ShokuTabBar(
          items: _tabs(context.l10n),
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
