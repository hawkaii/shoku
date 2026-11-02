import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Skip lands on a Journal that shows the sample', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const ShokuApp(),
    ));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('pinned-card')), findsOneWidget,
        reason: 'the sample has to reach the Journal the cook is looking at');
    expect(find.text('Paneer Tikka'), findsWidgets);
  });
}
