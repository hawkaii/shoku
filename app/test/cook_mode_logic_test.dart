import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/l10n/app_localizations_en.dart';
import 'package:food_finder/presentation/screens/cook/cook_mode_logic.dart';

CookTimer _timer(
        {int stepIndex = 2, String versionId = 'v1', String dishId = 'd1'}) =>
    CookTimer(
      dishId: dishId,
      versionId: versionId,
      stepIndex: stepIndex,
      startedAt: DateTime(2026, 1, 1),
      duration: const Duration(minutes: 5),
    );

void main() {
  final l10n = AppLocalizationsEn();

  group('alertCopyFor', () {
    test('counts steps from one and uses the localized title', () {
      final copy = CookModeLogic.alertCopyFor(0, l10n);
      expect(copy.title, l10n.timerNotificationTitle);
      expect(copy.body, l10n.timerNotificationBody(1));
    });

    test('step index 2 becomes step 3 in the body', () {
      final copy = CookModeLogic.alertCopyFor(2, l10n);
      expect(copy.body, l10n.timerNotificationBody(3));
    });
  });

  group('restoredPage', () {
    test('returns null before restore', () {
      expect(
        CookModeLogic.restoredPage(
          timer: _timer(),
          currentStep: 0,
          stepCount: 5,
          alreadyAdopted: false,
          isRestored: false,
        ),
        isNull,
      );
    });

    test('returns null when already adopted', () {
      expect(
        CookModeLogic.restoredPage(
          timer: _timer(),
          currentStep: 0,
          stepCount: 5,
          alreadyAdopted: true,
          isRestored: true,
        ),
        isNull,
      );
    });

    test('returns null when there is no timer', () {
      expect(
        CookModeLogic.restoredPage(
          timer: null,
          currentStep: 0,
          stepCount: 5,
          alreadyAdopted: false,
          isRestored: true,
        ),
        isNull,
      );
    });

    test('returns null when the timer is already on the current step', () {
      expect(
        CookModeLogic.restoredPage(
          timer: _timer(stepIndex: 2),
          currentStep: 2,
          stepCount: 5,
          alreadyAdopted: false,
          isRestored: true,
        ),
        isNull,
      );
    });

    test('returns null when the step index is out of range', () {
      expect(
        CookModeLogic.restoredPage(
          timer: _timer(stepIndex: 9),
          currentStep: 0,
          stepCount: 5,
          alreadyAdopted: false,
          isRestored: true,
        ),
        isNull,
      );
    });

    test('returns the timer step when it differs and is in range', () {
      expect(
        CookModeLogic.restoredPage(
          timer: _timer(stepIndex: 3),
          currentStep: 0,
          stepCount: 5,
          alreadyAdopted: false,
          isRestored: true,
        ),
        3,
      );
    });
  });

  group('shouldDropStaleTimer', () {
    test('false when there is no timer', () {
      expect(
        CookModeLogic.shouldDropStaleTimer(
          timer: null,
          versionId: 'v2',
          alreadyScheduled: false,
        ),
        isFalse,
      );
    });

    test('false when the version matches', () {
      expect(
        CookModeLogic.shouldDropStaleTimer(
          timer: _timer(versionId: 'v2'),
          versionId: 'v2',
          alreadyScheduled: false,
        ),
        isFalse,
      );
    });

    test('false when already scheduled', () {
      expect(
        CookModeLogic.shouldDropStaleTimer(
          timer: _timer(versionId: 'v1'),
          versionId: 'v2',
          alreadyScheduled: true,
        ),
        isFalse,
      );
    });

    test('true only when the version changed on the same dish', () {
      expect(
        CookModeLogic.shouldDropStaleTimer(
          timer: _timer(versionId: 'v1'),
          versionId: 'v2',
          alreadyScheduled: false,
        ),
        isTrue,
      );
    });
  });
}
