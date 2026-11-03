import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/presentation/screens/recipes/recipes_screen.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/state/sync_providers.dart';

/// An empty cookbook has to say which kind of empty it is. Before this, a
/// signed-out or unreachable journal looked exactly like a cookbook that had
/// lost every recipe.
Widget _harness(SyncStatus status) => ProviderScope(
      overrides: [
        dishesProvider.overrideWithValue(const []),
        libraryFilterProvider.overrideWith((ref) => LibraryFilter.toCook),
        syncStatusProvider.overrideWith((ref) => status),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: RecipesScreen()),
      ),
    );

void main() {
  testWidgets('signed out offers sign-in instead of "nothing to cook"',
      (tester) async {
    await tester.pumpWidget(_harness(SyncStatus.signedOut));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cookbook-sign-in')), findsOneWidget);
    expect(
      find.text('Sign in to bring your recipes back. They live on the server, '
          'not on this phone.'),
      findsOneWidget,
    );
    expect(find.text('Nothing waiting to be cooked.'), findsNothing);
  });

  testWidgets('a failed sync offers a retry', (tester) async {
    await tester.pumpWidget(_harness(SyncStatus.failed));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('cookbook-retry')), findsOneWidget);
    expect(
      find.text('Your recipes could not load. Check the connection and try '
          'again.'),
      findsOneWidget,
    );
  });

  testWidgets('an genuinely empty cookbook stays quiet', (tester) async {
    await tester.pumpWidget(_harness(SyncStatus.idle));
    await tester.pumpAndSettle();

    expect(find.text('Nothing waiting to be cooked.'), findsOneWidget);
    expect(find.byKey(const ValueKey('cookbook-sign-in')), findsNothing);
    expect(find.byKey(const ValueKey('cookbook-retry')), findsNothing);
  });
}
