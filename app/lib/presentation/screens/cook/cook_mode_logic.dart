import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/data/services/timer_alerts.dart';
import 'package:food_finder/l10n/app_localizations.dart';

/// Pure decisions that [CookModeScreen] makes while cooking.
///
/// These used to be methods on `_CookModeScreenState` that interleaved a decision
/// with `setState`, `addPostFrameCallback` and `ref.read`. Pulling the decision
/// out means it can be tested without pumping a screen, and the screen keeps
/// only the side effects.
abstract final class CookModeLogic {
  /// The words the timer's mirror notification says, in the cook's language.
  ///
  /// Resolved here because the store has no `BuildContext`, and the app ships
  /// ten locales. `stepIndex` is zero-based; the copy counts from one.
  static TimerAlertCopy alertCopyFor(int stepIndex, AppLocalizations l10n) =>
      TimerAlertCopy(
        title: l10n.timerNotificationTitle,
        body: l10n.timerNotificationBody(stepIndex + 1),
      );

  /// Whether a timer that survived a kill should move the page to its step.
  ///
  /// Returns the step to jump to, or `null` when nothing should move. The
  /// screen is responsible for the actual `jumpToPage` and `setState`.
  static int? restoredPage({
    required CookTimer? timer,
    required int currentStep,
    required int stepCount,
    required bool alreadyAdopted,
    required bool isRestored,
  }) {
    if (alreadyAdopted || !isRestored) return null;
    if (timer == null) return null;
    if (timer.stepIndex == currentStep) return null;
    if (timer.stepIndex >= stepCount) return null;
    return timer.stepIndex;
  }

  /// Whether a timer whose version changed should be dropped.
  ///
  /// A fork changes what the steps mean, so an old step index would point at
  /// somebody else's instruction. The screen schedules the drop once.
  static bool shouldDropStaleTimer({
    required CookTimer? timer,
    required String versionId,
    required bool alreadyScheduled,
  }) {
    if (timer == null) return false;
    if (timer.versionId == versionId) return false;
    if (alreadyScheduled) return false;
    return true;
  }
}
