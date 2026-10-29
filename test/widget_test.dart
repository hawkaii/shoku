import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_finder/main.dart';

void main() {
  testWidgets('Shoku boots into onboarding', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ShokuApp()));
    await tester.pump();

    expect(find.text('Reels in.\nRecipes out.'), findsOneWidget);
  });
}
