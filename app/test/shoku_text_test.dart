import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/utils/shoku_text.dart';

void main() {
  group('count', () {
    test('one takes the singular', () {
      expect(count(1, 'dish', 'dishes'), '1 dish');
      expect(count(1, 'entry', 'entries'), '1 entry');
    });

    test('everything else takes the plural', () {
      expect(count(2, 'dish', 'dishes'), '2 dishes');
      expect(count(0, 'entry', 'entries'), '0 entries');
      expect(count(1, 'cook'), '1 cook');
      expect(count(3, 'cook'), '3 cooks');
    });
  });

  group('minutesLabel', () {
    test('reads plainly when the duration is known', () {
      expect(minutesLabel(30), '30 min');
    });

    test('disappears when nobody recorded it', () {
      expect(minutesLabel(0), '');
      expect(minutesLabel(-5), '');
    });

    test('never turns a missing duration into a dash', () {
      expect(minutesLabel(0), isNot(contains('-')));
      expect(minutesLabel(0), isNot(contains('—')));
    });
  });

  group('metaLine', () {
    test('joins what it knows', () {
      expect(metaLine(['30 min', 'never cooked']), '30 min · never cooked');
    });

    test('drops empty parts instead of leaving separators', () {
      expect(metaLine(['', '30 min', '   ']), '30 min');
      expect(metaLine(['']), '');
      expect(metaLine(['', '']), '');
    });
  });
}
