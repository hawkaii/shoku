// Integration tests run on a real device or emulator, not on the host.
//
// `flutter test integration_test/` requires a connected device. On CI that
// means an emulator job (see .github/workflows/integration.yml, added when
// these tests are stable enough to gate a PR).
//
// What is here today is the one check that needs no hardware: the app boots and
// paints its first screen. The rest of the critical paths (timer ring, cold-start
// share, sync restore, import) are manual until an emulator job exists — see
// integration_test/README.md.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/main.dart' show ShokuApp;

void main() {
  testWidgets('the app boots to its first screen', (tester) async {
    await tester.pumpWidget(const ShokuApp());
    await tester.pump(const Duration(seconds: 1));

    // Onboarding paints something; the exact copy is covered by widget tests.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
