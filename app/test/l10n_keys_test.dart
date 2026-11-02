import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/l10n/languages.dart';

void main() {
  final arbDir = Directory('lib/l10n');

  Set<String> stringKeys(File file) {
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return json.keys.where((key) => !key.startsWith('@')).toSet();
  }

  test('every ARB has exactly the keys of app_en.arb', () {
    final template = stringKeys(File('${arbDir.path}/app_en.arb'));
    expect(template, isNotEmpty);

    final others = arbDir
        .listSync()
        .whereType<File>()
        .where((file) =>
            file.path.endsWith('.arb') &&
            !file.path.endsWith('app_en.arb'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    // Nine translations today; the count is the point of the check, not an
    // accident, so a dropped ARB fails loudly instead of shrinking the app.
    expect(others, hasLength(9));

    for (final file in others) {
      expect(
        stringKeys(file),
        template,
        reason: '${file.path} is missing or has extra keys vs app_en.arb',
      );
    }
  });

  test('languages.dart and the ARB files name the same locales', () {
    final codes = arbDir
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .where((name) => name.startsWith('app_') && name.endsWith('.arb'))
        .map((name) => name.substring(4, name.length - 4))
        .toSet();
    final supported =
        shokuSupportedLocales.map((locale) => locale.languageCode).toSet();
    expect(codes, supported);
    expect(shokuLanguages.map((l) => l.locale.languageCode), supported);
  });
}
