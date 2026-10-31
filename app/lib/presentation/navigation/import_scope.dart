import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/import_tracker.dart';

/// Keeps the import poller alive for the whole app, not just for the tab that
/// draws the card.
///
/// The card belongs to the Journal; the work does not. A job that finishes while
/// the cook is reading the Cookbook must still write its dish, so the lifetime
/// is owned here, in the shell, and the card is only a view of it.
class ImportTrackerScope extends ConsumerWidget {
  const ImportTrackerScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A listener, not a watch: the shell must not rebuild on every poll.
    ref.listen<ImportTrackerState>(importTrackerProvider, (previous, next) {});
    return child;
  }
}
