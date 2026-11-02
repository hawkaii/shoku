import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';
import 'package:food_finder/presentation/widgets/kit/plate_mark.dart';

void main() {
  testWidgets('Shoku boots into onboarding', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authReadyProvider.overrideWith((ref) async {})],
      child: const ShokuApp(),
    ));
    await tester.pump(const Duration(milliseconds: 400));

    // The primary CTA is the stable signal that onboarding rendered.
    expect(find.text('Start cooking'), findsOneWidget);

    // The splash paints first, so onboarding mounts on this frame and its
    // entrance timer is still queued: one more pump lets it fire, and tearing
    // the tree down afterwards cancels anything it left.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the first frame is the splash, not a blank window',
      (tester) async {
    final gate = Completer<void>();
    await tester.pumpWidget(ProviderScope(
      overrides: [authReadyProvider.overrideWith((ref) => gate.future)],
      child: const ShokuApp(),
    ));
    await tester.pump();

    expect(find.byType(PlateMark), findsOneWidget,
        reason: 'something is painted while the session opens');
    expect(find.text('Start cooking'), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('Start cooking'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
  });
}
