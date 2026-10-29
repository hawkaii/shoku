import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_finder/main.dart';

void main() {
  testWidgets('Shoku boots into onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShokuApp()));
    await tester.pump(const Duration(milliseconds: 400));

    // The primary CTA is the stable signal that onboarding rendered.
    expect(find.text('Start cooking'), findsOneWidget);
  });
}
