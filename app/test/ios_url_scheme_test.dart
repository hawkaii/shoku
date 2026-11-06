import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The email-confirmation link can only reopen the app if the OS knows the
/// scheme. Android declares it in the manifest (see android_manifest_test.dart);
/// iOS declares it in the plist, which no other test reads.
void main() {
  final File file = File('ios/Runner/Info.plist');
  final String plist = file.readAsStringSync();

  group('auth return path', () {
    test('the redirect scheme is registered with iOS', () {
      expect(plist, contains('CFBundleURLTypes'));
      expect(plist, contains('CFBundleURLSchemes'));
      expect(
        plist,
        contains('<string>com.shoku.app</string>'),
        reason: 'without it the confirmation link opens a browser, not Shoku',
      );
    });

    test('the plist is still well-formed XML', () {
      expect(RegExp(r'<plist[^>]*>').allMatches(plist), hasLength(1));
      expect('</plist>'.allMatches(plist), hasLength(1));
      expect(
        '<dict>'.allMatches(plist).length,
        '</dict>'.allMatches(plist).length,
        reason: 'unbalanced keys make the iOS build fail, not this test',
      );
      expect(
        '<array>'.allMatches(plist).length,
        '</array>'.allMatches(plist).length,
      );
    });
  });
}
