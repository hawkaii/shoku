import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/config/shoku_config.dart';

/// The Android manifest is code: a missing receiver or intent filter is a
/// feature that silently does nothing. These assertions are deliberately
/// textual — there is no manifest parser worth adding — and they name the
/// consequence, so a failure says what the user loses.
void main() {
  final File file = File('android/app/src/main/AndroidManifest.xml');
  final String manifest = file.readAsStringSync();

  group('scheduled timers', () {
    test('the alarm receiver is registered', () {
      // Without it, zonedSchedule succeeds and the broadcast is dropped.
      expect(
        manifest,
        contains(
          'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
        ),
        reason: 'a scheduled cook timer would never ring',
      );
    });

    test('the boot receiver replays alarms after a restart', () {
      expect(
        manifest,
        contains(
          'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
        ),
        reason: 'a timer scheduled before a reboot would be lost',
      );
      expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
      expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    });

    test('notification and exact-alarm permissions are declared', () {
      expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
      expect(manifest, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    });

    test('the timer icon exists for the status bar', () {
      expect(
        File('android/app/src/main/res/drawable/ic_stat_timer.xml').existsSync(),
        isTrue,
        reason: 'initialize() falls back to a missing icon otherwise',
      );
    });
  });

  group('sharing into the app', () {
    test('text, image and video shares are accepted', () {
      expect(manifest, contains('android:mimeType="text/*"'));
      expect(manifest, contains('android:mimeType="image/*"'));
      expect(manifest, contains('android:mimeType="video/*"'));
    });

    test('multi-select shares are accepted', () {
      expect(manifest, contains('android.intent.action.SEND_MULTIPLE'));
    });

    test('the activity stays in one task', () {
      // singleTask is what turns a warm share into onNewIntent instead of a
      // second engine. An empty affinity breaks that guarantee.
      expect(manifest, contains('android:launchMode="singleTask"'));
      expect(manifest, isNot(contains('android:taskAffinity=""')));
    });
  });

  group('auth return path', () {
    test('the configured redirect scheme is declared', () {
      // Read from the one config the app hands to Supabase: the manifest and
      // the redirect cannot drift apart without this failing.
      final redirect = Uri.parse(ShokuConfig.authRedirect);
      expect(manifest, contains('android:scheme="${redirect.scheme}"'));
      expect(manifest, contains('android:host="${redirect.host}"'));
      expect(manifest, contains('android.intent.category.BROWSABLE'));
    });
  });
}
