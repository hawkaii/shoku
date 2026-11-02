import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/models/cook_timer.dart';
import '../../../data/services/timer_alerts.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/kit/motion.dart';

/// The timer, as the cook sees it.
///
/// It has exactly four states and every one of them is written out: no timer on
/// a step that takes time offers to start, a running timer offers Pause and Stop,
/// a paused one offers Resume and Stop, and a finished one says so and offers to
/// go again. Nothing is implied by a disabled button or a colour alone.
class CookTimerCard extends StatelessWidget {
  const CookTimerCard({
    super.key,
    required this.timer,
    required this.remainingMs,
    required this.suggestedMinutes,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    this.currentStep,
    this.alerts = TimerAlertPermission.unknown,
  });

  final CookTimer? timer;
  final int remainingMs;
  final int suggestedMinutes;

  /// Whether the alert that mirrors this timer can be trusted to ring, be late,
  /// or not ring at all. Whatever it is, it is said out loud.
  final TimerAlertPermission alerts;

  /// Which step is on screen. When the timer belongs to another one, the card
  /// says so rather than looking like it watches whatever you are reading.
  final int? currentStep;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final timer = this.timer;

    if (timer == null) {
      if (suggestedMinutes <= 0) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: _TimerButton(
          key: const ValueKey('timer-start'),
          label: l10n.timerStart(suggestedMinutes),
          icon: Icons.timer_outlined,
          onTap: onStart,
        ),
      );
    }

    final done = remainingMs <= 0;
    final paused = timer.isPaused && !done;
    final state = done
        ? l10n.timerTimesUp
        : paused
            ? l10n.timerPaused
            : l10n.timerRunning;
    final elsewhere = currentStep != null && timer.stepIndex != currentStep;
    final status = elsewhere
        ? l10n.timerOnStep(timer.stepIndex + 1, state)
        : state;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CookTimer.formatRemaining(remainingMs),
                    key: const ValueKey('timer-clock'),
                    style: ShokuType.stat.copyWith(
                      fontSize: 22,
                      color: done ? c.ready : c.ink,
                    ),
                  ),
                  Text(
                    status,
                    key: const ValueKey('timer-status'),
                    style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted),
                  ),
                ],
              ),
              const Spacer(),
              if (done)
                _TimerButton(
                  key: const ValueKey('timer-start'),
                  label: l10n.timerStartAgain,
                  onTap: onStart,
                )
              else
                _TimerButton(
                  key: ValueKey(paused ? 'timer-resume' : 'timer-pause'),
                  label: paused ? l10n.timerResume : l10n.timerPause,
                  onTap: paused ? onResume : onPause,
                ),
              const SizedBox(width: ShokuSpace.xs),
              _TimerButton(
                key: const ValueKey('timer-stop'),
                label: l10n.timerStop,
                onTap: onStop,
                quiet: true,
              ),
            ],
          ),
          if (alertNote(l10n) != null) ...[
            const SizedBox(height: 6),
            Text(
              alertNote(l10n)!,
              key: const ValueKey('timer-alert-note'),
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  /// The truth about the alert, when it is not simply "yes, on time".
  String? alertNote(AppLocalizations l10n) => switch (alerts) {
        TimerAlertPermission.denied => l10n.timerAlertsOff,
        TimerAlertPermission.inexact => l10n.timerAlertsLate,
        _ => null,
      };
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.quiet = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: quiet ? Colors.transparent : c.surfaceAlt,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: quiet ? c.hairline : c.ink),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: c.ink),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: ShokuType.label.copyWith(
                fontSize: 10,
                color: c.ink,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
