import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/models/cook_timer.dart';
import '../../../data/services/speech_service.dart';
import '../../../data/services/timer_alerts.dart';
import '../../state/assistant_providers.dart';
import '../../state/auth_providers.dart';
import '../../state/cook_timer_providers.dart';
import '../../state/hands_free_controller.dart';
import '../../state/hands_free_providers.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/step_ingredients.dart';
import '../../widgets/kit/step_library.dart';
import '../../widgets/kit/bot_orb.dart';
import '../../widgets/kit/step_text.dart';
import '../assistant/recipe_chat_sheet.dart';
import '../log/debrief_sheet.dart';
import 'cook_mode_logic.dart';
import 'timer_card.dart';

/// Step-by-step cook mode: one step, one instructive loop, one floating AI.
/// Swipeable, so it works with a knuckle when your hands are busy.
class CookModeScreen extends ConsumerStatefulWidget {
  final String dishId;
  const CookModeScreen({super.key, required this.dishId});

  @override
  ConsumerState<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends ConsumerState<CookModeScreen>
    with WidgetsBindingObserver {
  final _pages = PageController();
  int _step = 0;
  final _changes = <String>[];

  /// A repaint pulse, not a countdown. The number on screen comes from the wall
  /// clock every time this fires, so a missed or late tick costs a frame, never a
  /// second.
  Timer? _ticker;
  bool _rang = false;
  bool _adoptedTimer = false;
  bool _adoptingPage = false;
  bool _dropScheduled = false;
  bool _timerCleared = false;

  /// One hands-free session per visit to this dish. It is rebuilt only when the
  /// cook turns it on again, so a failure leaves its notice on screen.
  HandsFreeController? _handsFree;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The row is read asynchronously; the screen adopts it once it has been
    // restored, which is how a killed app comes back to the right step.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _handsFree?.dispose();
    _ticker?.cancel();
    _pages.dispose();
    super.dispose();
  }

  /// Coming back from the background: recompute from the clock on the first
  /// visible frame rather than up to a second later. If the timer ran out while
  /// the screen was off, the notification rang and the card catches up here.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    _pulse();
    // A permission granted in Settings while we were away takes effect now: the
    // store re-reads it and re-creates the running timer's alarm to match.
    unawaited(ref.read(cookTimerProvider.notifier).refreshAlertPermission());
  }

  /// Keeps at most one ticker alive, and only while there is something to watch.
  void _ensureTicker(bool running) {
    if (running && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _pulse());
    } else if (!running) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _pulse() {
    if (!mounted) return;
    final timer = ref.read(cookTimerProvider);
    if (timer != null &&
        !_rang &&
        !timer.isPaused &&
        timer.isDoneAt(DateTime.now())) {
      // Haptic only, and only because this screen is awake. The mirror is
      // cancelled as well: it has done its job or it never will.
      _rang = true;
      unawaited(HapticFeedback.mediumImpact());
      unawaited(ref.read(cookTimerProvider.notifier).cancelAlert());
    }
    setState(() {});
  }

  void _startTimer(Dish dish, String versionId, int minutes) {
    _rang = false;
    _timerCleared = false;
    ref.read(cookTimerProvider.notifier).start(
          dishId: dish.id,
          versionId: versionId,
          stepIndex: _step,
          duration: Duration(minutes: minutes),
          copy: _alertCopyFor(_step),
        );
  }

  void _onHandsFreeChanged(HandsFreeState _) {
    if (mounted) setState(() {});
  }

  Future<void> _toggleHandsFree(
    Dish dish,
    List<String> steps,
    String versionId,
  ) async {
    final existing = _handsFree;
    if (existing != null && existing.isRunning) {
      await existing.stop();
      if (mounted) setState(() {});
      return;
    }
    if (existing != null && existing.snapshot.phase == HandsFreePhase.paused) {
      // A failure is not a dead end: the next tap rebuilds with a fresh token
      // and the current step rather than retrying the old session.
      existing.dispose();
      _handsFree = null;
    }

    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final ingredients = dish.versions.isEmpty
        ? const <String>[]
        : dish.versions.last.ingredients;
    final setup = HandsFreeSetup(
      token: ref.read(authServiceProvider).accessToken ?? '',
      locale: locale,
      keywords: [
        for (final line in ingredients)
          if (line.trim().isNotEmpty)
            line.trim().length > 60
                ? line.trim().substring(0, 60)
                : line.trim(),
      ],
      actions: VoiceActions(
        next: () {
          if (_step < steps.length - 1) {
            _pages.nextPage(
              duration: ShokuMotion.push,
              curve: ShokuMotion.pushCurve,
            );
          }
        },
        back: () {
          if (_step > 0) {
            _pages.previousPage(
              duration: ShokuMotion.push,
              curve: ShokuMotion.pushCurve,
            );
          }
        },
        currentStep: () => steps[_step],
        currentStepIndex: () => _step,
        startTimer: (minutes) async => _startTimer(dish, versionId, minutes),
        timerInFinalMinute: () {
          final timer = ref.read(cookTimerProvider);
          if (timer == null || timer.dishId != dish.id) return false;
          final left = timer.remainingMsAt(DateTime.now());
          return left > 0 && left <= 60000;
        },
      ),
      copy: HandsFreeCopy(
        checkIn: l10n.handsFreeCheckIn,
        help: l10n.handsFreeHelp,
        timerStarted: l10n.handsFreeTimerStarted,
        offline: l10n.handsFreeOffline,
        auth: l10n.handsFreeAuth,
        cap: l10n.handsFreeCap,
      ),
      ask: (question, stepIndex) async {
        final reply = await ref.read(assistantServiceProvider).ask(
              scope: 'dish',
              dishId: dish.id,
              versionId: versionId,
              stepIndex: stepIndex,
              question: question,
              requestId: newVoiceRequestId(),
            );
        return reply.answer;
      },
    );

    final controller = _handsFree ?? ref.read(handsFreeFactoryProvider)(setup);
    if (_handsFree == null) {
      controller.addListener(_onHandsFreeChanged);
      setState(() => _handsFree = controller);
    }
    await controller.start();
  }

  /// The notification's words, in the cook's language. Resolved here because the
  /// store has no `BuildContext`, and the app ships ten locales.
  TimerAlertCopy _alertCopyFor(int stepIndex) =>
      CookModeLogic.alertCopyFor(stepIndex, context.l10n);

  void _resumeTimer() {
    // The timer knows which step it belongs to; the page may have moved on.
    final step = ref.read(cookTimerProvider)?.stepIndex ?? _step;
    ref.read(cookTimerProvider.notifier).resume(copy: _alertCopyFor(step));
  }

  /// A timer that survived a kill belongs to a step, so reopening the screen
  /// lands there rather than at step one with a clock running for no visible
  /// reason.
  void _adoptRestoredTimer(
    CookTimerStore store,
    CookTimer? timer,
    int stepCount,
  ) {
    if (_adoptedTimer || !store.isRestored) return;
    _adoptedTimer = true;
    final page = CookModeLogic.restoredPage(
      timer: timer,
      currentStep: _step,
      stepCount: stepCount,
      alreadyAdopted: false,
      isRestored: true,
    );
    if (page == null) return;
    _adoptingPage = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pages.hasClients) {
        _adoptingPage = false;
        return;
      }
      _pages.jumpToPage(page);
      setState(() => _step = page);
      _adoptingPage = false;
    });
  }

  /// A fork replaces the version the timer was started on. Its step index now
  /// points at a different instruction, so the timer is dropped and said out
  /// loud instead of quietly inheriting somebody else's step.
  void _dropStaleTimer(CookTimer? timer, String dishId, String versionId) {
    if (!CookModeLogic.shouldDropStaleTimer(
      timer: timer,
      dishId: dishId,
      versionId: versionId,
      alreadyScheduled: _dropScheduled,
    )) {
      return;
    }
    _dropScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final dropped = await ref
          .read(cookTimerProvider.notifier)
          .dropIfVersionChanged(dishId: dishId, versionId: versionId);
      _dropScheduled = false;
      if (dropped && mounted) setState(() => _timerCleared = true);
    });
  }

  Future<bool> _confirmLeave() async {
    if (_changes.isEmpty && _step == 0) return true;
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = context.colors;
        return Dialog(
          backgroundColor: c.canvas,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            side: BorderSide(color: c.ink, width: ShokuStroke.brutal),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ShokuSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.cookLeaveTitle,
                    style: ShokuType.h1.copyWith(color: c.ink)),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  _changes.isEmpty
                      ? l10n.cookLeaveBody
                      : l10n.cookLeaveChanges(_changes.length),
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ShokuRadius.chip),
                            side: BorderSide(color: c.hairline),
                          ),
                        ),
                        child: Text(l10n.exitKeepCooking,
                            style: ShokuType.title
                                .copyWith(color: c.ink, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          backgroundColor: c.ink,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(ShokuRadius.chip),
                          ),
                        ),
                        child: Text(l10n.chatDiscard,
                            style: ShokuType.title
                                .copyWith(color: c.canvas, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dish = ref.watch(dishProvider(widget.dishId));
    if (dish == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final steps = dish.steps.isEmpty ? [l10n.cookNoSteps] : dish.steps;
    final isLast = _step == steps.length - 1;

    final versionId = dish.versions.isEmpty ? '' : dish.versions.last.id;
    final handsFree = _handsFree?.snapshot;
    final handsFreeLabel = switch (handsFree?.phase) {
      HandsFreePhase.connecting => l10n.handsFreeConnecting,
      HandsFreePhase.listening => l10n.handsFreeListening,
      HandsFreePhase.thinking => l10n.handsFreeThinking,
      HandsFreePhase.speaking => l10n.handsFreeSpeaking,
      HandsFreePhase.paused => l10n.handsFreePaused,
      _ => l10n.handsFree,
    };
    final handsFreeNotice = handsFree?.notice == HandsFreeNotice.offline
        ? l10n.handsFreeOffline
        : handsFree?.notice == HandsFreeNotice.auth
            ? l10n.handsFreeAuth
            : handsFree?.notice == HandsFreeNotice.cap
                ? l10n.handsFreeCap
                : null;
    final timer = ref.watch(cookTimerProvider);
    final store = ref.read(cookTimerProvider.notifier);
    final timerForThisDish =
        timer != null && timer.dishId == dish.id ? timer : null;
    final remainingMs = timerForThisDish?.remainingMsAt(DateTime.now()) ?? 0;

    _adoptRestoredTimer(store, timerForThisDish, steps.length);
    _dropStaleTimer(timerForThisDish, dish.id, versionId);
    _ensureTicker(
      timerForThisDish != null && !timerForThisDish.isPaused && remainingMs > 0,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmLeave()) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: c.canvas,
        body: SafeArea(
          child: Column(
            children: [
              // ---- top bar ------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    ShokuSpace.lg, ShokuSpace.sm, ShokuSpace.lg, 0),
                child: Row(
                  children: [
                    ShokuPressable(
                      onTap: () async {
                        if (await _confirmLeave() && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          border: Border.all(color: c.hairline),
                        ),
                        child: Icon(Icons.close, size: 17, color: c.ink),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.md),
                    Expanded(
                      child: Text(
                        dish.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ShokuType.title
                            .copyWith(color: c.ink, fontSize: 14),
                      ),
                    ),
                    if (_changes.isNotEmpty) ...[
                      ShokuChip(l10n.cookChangedCount(_changes.length),
                          color: c.reward, filled: true),
                      const SizedBox(width: ShokuSpace.sm),
                    ],
                    Semantics(
                      button: true,
                      label: handsFree?.isActive == true
                          ? l10n.handsFreeStop
                          : l10n.handsFreeStart,
                      child: GestureDetector(
                        key: const ValueKey('hands-free-toggle'),
                        onTap: () => _toggleHandsFree(dish, steps, versionId),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: handsFree?.isActive == true
                                ? c.accentSoft
                                : c.surface,
                            borderRadius:
                                BorderRadius.circular(ShokuRadius.chip),
                            border: Border.all(
                              color: handsFree?.isActive == true
                                  ? c.accent
                                  : c.hairline,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (handsFree?.phase == HandsFreePhase.listening)
                                Container(
                                  key: const ValueKey('hands-free-mic-dot'),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: c.accent,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                Icon(
                                  handsFree?.phase == HandsFreePhase.paused
                                      ? Icons.mic_off
                                      : Icons.mic,
                                  size: 12,
                                  color: handsFree?.isActive == true
                                      ? c.accent
                                      : c.inkMuted,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                handsFreeLabel,
                                style: ShokuType.label.copyWith(
                                  fontSize: 8.5,
                                  color: handsFree?.isActive == true
                                      ? c.accent
                                      : c.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.xs),
                    Text(
                      '${_step + 1}/${steps.length}',
                      style: ShokuType.stat
                          .copyWith(fontSize: 12, color: c.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ShokuSpace.md),
              const ShokuHairline(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ShokuSpace.lg, vertical: ShokuSpace.sm),
                child: ShokuProgress(value: (_step + 1) / steps.length),
              ),
              if (handsFree != null &&
                  (handsFree.isActive || handsFreeNotice != null))
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.xs),
                  child: Row(
                    key: const ValueKey('hands-free-banner'),
                    children: [
                      Icon(
                        handsFree.notice == HandsFreeNotice.none
                            ? Icons.mic
                            : Icons.info_outline,
                        size: 12,
                        color: handsFree.notice == HandsFreeNotice.none
                            ? c.accent
                            : c.inkMuted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          handsFreeNotice ??
                              (handsFree.heard.isEmpty
                                  ? handsFreeLabel
                                  : l10n.handsFreeHeard(handsFree.heard)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ShokuType.label
                              .copyWith(fontSize: 9, color: c.inkMuted),
                        ),
                      ),
                    ],
                  ),
                ),

              // ---- swipeable steps + floating AI ---------------------------
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pages,
                      itemCount: steps.length,
                      onPageChanged: (i) {
                        unawaited(HapticFeedback.selectionClick());
                        // Leaving the step ends its timer. A ring for a step
                        // already left is the bug a kitchen notices.
                        if (!_adoptingPage) {
                          final timer = ref.read(cookTimerProvider);
                          if (timer != null && timer.dishId == dish.id) {
                            unawaited(
                                ref.read(cookTimerProvider.notifier).stop());
                          }
                        }
                        setState(() => _step = i);
                        // Steps read aloud, when the cook asked for it. Never
                        // the timer, never an answer.
                        final speech = ref.read(readAloudProvider);
                        if (speech && i < steps.length) {
                          ref.read(readAloudProvider.notifier).speak(steps[i]);
                        }
                      },
                      itemBuilder: (context, i) => SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          ShokuSpace.lg,
                          0,
                          ShokuSpace.lg,
                          ShokuSpace.xxxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StepMotionLibrary.build(context, steps[i],
                                height: 168),
                            const SizedBox(height: ShokuSpace.lg),
                            Row(
                              children: [
                                ShokuLabel(l10n.cookStepLabel(
                                    NumberFormat('00', locale).format(i + 1))),
                                const Spacer(),
                                // The assistant lives in the step header, not
                                // over the timer.
                                BotInlineChip(
                                  onTap: () => showRecipeChat(context,
                                      dish: dish, stepIndex: i),
                                  badge: _changes.isEmpty
                                      ? null
                                      : '${_changes.length}',
                                ),
                              ],
                            ),
                            const SizedBox(height: ShokuSpace.sm),
                            StepText(
                              text: steps[i],
                              fontSize: 26,
                              ingredients: dish.versions.last.ingredients,
                            ),
                            const SizedBox(height: ShokuSpace.sm),
                            // What this step uses, in the recipe's own words.
                            // Nothing at all when the parse predates the links.
                            StepIngredientsLine(
                              ingredients: dish.versions.last.ingredients,
                              indices:
                                  dish.versions.last.stepIngredientLinks(i),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- the timer ------------------------------------------------
              // Below the step text, above the buttons: the reading order the
              // design asks for, and still visible whichever step is open.
              if (timerForThisDish != null || _hasTime(steps[_step]))
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.sm),
                  child: CookTimerCard(
                    timer: timerForThisDish,
                    currentStep: _step,
                    remainingMs: remainingMs,
                    alerts: ref.watch(timerAlertPermissionProvider),
                    suggestedMinutes:
                        _hasTime(steps[_step]) ? _minutesIn(steps[_step]) : 0,
                    onStart: () =>
                        _startTimer(dish, versionId, _minutesIn(steps[_step])),
                    onPause: () => ref.read(cookTimerProvider.notifier).pause(),
                    onResume: _resumeTimer,
                    onStop: () => ref.read(cookTimerProvider.notifier).stop(),
                  ),
                ),
              if (_timerCleared && timerForThisDish == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.cookTimerCleared,
                      style: ShokuType.label.copyWith(color: c.inkMuted),
                    ),
                  ),
                ),

              // ---- navigation ---------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.lg),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: ShokuPressable(
                          onTap: () => _pages.previousPage(
                            duration: ShokuMotion.push,
                            curve: ShokuMotion.pushCurve,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(ShokuRadius.chip),
                              border: Border.all(color: c.hairline),
                            ),
                            child: Center(
                              child: Text(l10n.cookBack,
                                  style: ShokuType.title
                                      .copyWith(color: c.ink, fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      flex: 2,
                      child: ShokuPressable(
                        onTap: () {
                          if (!isLast) {
                            _pages.nextPage(
                              duration: ShokuMotion.push,
                              curve: ShokuMotion.pushCurve,
                            );
                          } else {
                            showDebriefSheet(context,
                                dish: dish, changes: _changes);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: ShokuGradients.crimsonPress,
                            borderRadius:
                                BorderRadius.circular(ShokuRadius.chip),
                            border: Border.all(
                                color: c.ink, width: ShokuStroke.brutal),
                            boxShadow: [
                              BoxShadow(
                                  color: c.ink,
                                  offset: ShokuStroke.brutalShadow,
                                  blurRadius: 0),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isLast ? l10n.cookFinishLog : l10n.cookNextStep,
                              style: ShokuType.title
                                  .copyWith(color: c.onAccent, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasTime(String step) =>
      RegExp(r'(\d+)\s*(min|minute)', caseSensitive: false).hasMatch(step);

  int _minutesIn(String step) {
    final match =
        RegExp(r'(\d+)\s*(min|minute)', caseSensitive: false).firstMatch(step);
    return int.tryParse(match?.group(1) ?? '5') ?? 5;
  }
}
