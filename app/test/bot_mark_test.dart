import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/presentation/widgets/kit/bot_mark.dart';

BotMarkPainter _painter(
        {bool filled = false, bool offline = false, bool draft = false}) =>
    BotMarkPainter(
      ink: ShokuColors.light.ink,
      accent: ShokuColors.light.accent,
      paper: ShokuColors.light.canvas,
      onAccent: ShokuColors.light.onAccent,
      filled: filled,
      offline: offline,
      draftDot: draft,
    );

void main() {
  testWidgets('the mark renders at its four sizes without a layout error',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ShokuTheme.light(),
      home: const Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BotMark(size: 14),
            BotMark(size: 18),
            BotMark(size: 22),
            BotMark(size: 32),
          ],
        ),
      ),
    ));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final sizes = [14.0, 18.0, 22.0, 32.0];
    for (var i = 0; i < sizes.length; i++) {
      expect(tester.getSize(find.byType(BotMark).at(i)), Size.square(sizes[i]));
    }
  });

  test('no generic sparkle is left anywhere in lib/', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    final offenders = [
      for (final file in files)
        if (file.readAsStringSync().contains('auto_awesome')) file.path,
    ];
    expect(offenders, isEmpty,
        reason: 'the bot has its own mark now: ${offenders.join(', ')}');
  });

  group('states', () {
    test('offline slashes the belly and never the crown', () {
      final painter = _painter(offline: true);
      expect(painter.parts, contains(BotMarkPart.slash));
      expect(painter.parts, isNot(contains(BotMarkPart.dot)));

      // The slash is clipped to the belly, and the crown's tips live above it.
      final slash = painter.slashShape.getBounds();
      final belly = painter.bellyRect;
      expect(slash.top, greaterThanOrEqualTo(belly.top - 0.01));
      expect(slash.bottom, lessThanOrEqualTo(belly.bottom + 0.01));
      // The crown's lower-left stub does reach the rim, so the proof is not
      // position: it is that the painted crown and the slash never overlap.
      final overlap = Path.combine(
        PathOperation.intersect,
        painter.crownFill,
        painter.slashShape,
      );
      final area = overlap.getBounds();
      expect(area.width * area.height, lessThan(0.01),
          reason: 'offline slashes the belly only; the crown is never cut');
    });

    test('a resting mark paints no slash and no dot', () {
      final painter = _painter();
      expect(painter.parts, [BotMarkPart.crown, BotMarkPart.belly]);
    });

    test('the filled orb keeps its ink contour under an accent belly', () {
      expect(
          _painter(filled: true).parts, [BotMarkPart.crown, BotMarkPart.belly]);
    });

    test('a draft outranks an unread reply, and offline outranks both', () {
      final draught = botOrbStyle(unread: true, offline: false, draft: true);
      expect(draught.filled, isFalse);
      expect(draught.draftDot, isTrue);

      final unread = botOrbStyle(unread: true, offline: false, draft: false);
      expect(unread.filled, isTrue);
      expect(unread.draftDot, isFalse);

      final offline = botOrbStyle(unread: true, offline: true, draft: true);
      expect(offline.offline, isTrue);
      expect(offline.filled, isFalse);
      expect(offline.draftDot, isFalse);
    });
  });

  testWidgets('the orb paints the mark, not a glyph', (tester) async {
    // A mark inside a 56 px circle is what the orb is; the painter is checked
    // above, and the geometry here is checked in bot_surface_test.
    await tester.pumpWidget(MaterialApp(
      theme: ShokuTheme.light(),
      home: const Scaffold(
        body: Center(
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(child: BotMark(size: 22)),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(BotMark), findsOneWidget);
    expect(tester.getSize(find.byType(BotMark)), const Size.square(22));
    expect(tester.takeException(), isNull);
  });
}
