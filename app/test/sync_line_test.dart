import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/presentation/navigation/sync_underline.dart';
import 'package:food_finder/presentation/state/sync_providers.dart';
import 'package:food_finder/presentation/widgets/kit/nav.dart';

Widget _harness(SyncStatus status, {Widget child = const SyncUnderline()}) {
  return ProviderScope(
    overrides: [syncStatusProvider.overrideWith((ref) => status)],
    child: MaterialApp(
      theme: ShokuTheme.light(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('a running sync travels', (tester) async {
    await tester.pumpWidget(_harness(SyncStatus.syncing));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const ValueKey('sync-line-travelling')), findsOneWidget);
  });

  testWidgets('a failed or offline pass is a still hairline', (tester) async {
    for (final status in [SyncStatus.failed, SyncStatus.offline]) {
      await tester.pumpWidget(_harness(status));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('sync-line-unsynced')),
        findsOneWidget,
        reason: '$status must be visible without being an alarm',
      );
      expect(find.byKey(const ValueKey('sync-line-travelling')), findsNothing);
    }
  });

  testWidgets('signed out says nothing about sync', (tester) async {
    await tester.pumpWidget(_harness(SyncStatus.signedOut));
    await tester.pump();

    expect(find.byKey(const ValueKey('tab-marker')), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-line-unsynced')), findsNothing);
    expect(find.byKey(const ValueKey('sync-line-travelling')), findsNothing);
  });

  testWidgets('only the active tab carries the line', (tester) async {
    await tester.pumpWidget(_harness(
      SyncStatus.syncing,
      child: ShokuTabBar(
        items: const [
          ShokuTabItem(Icons.menu_book_outlined, Icons.menu_book, 'Journal'),
          ShokuTabItem(Icons.person_outline, Icons.person, 'You'),
        ],
        index: 0,
        activeUnderline: const SyncUnderline(),
        onChanged: (_) {},
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const ValueKey('sync-line-travelling')), findsOneWidget);
  });
}
