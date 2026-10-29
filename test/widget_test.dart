import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_finder/main.dart';

void main() {
  testWidgets('Shoku boots into onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShokuApp()));
    // Let the staged entrance animations finish so no timers are left pending.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(find.text('Your cooking,\nkept.'), findsOneWidget);
  });
}
