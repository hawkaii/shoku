import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'step_diagram.dart';

/// The step-motion library.
///
/// Two tiers so this scales past what one person can hand-draw:
///  1. painted loops (always available, offline, zero assets)
///  2. registered Lottie files — drop one in `assets/motion/` and register it
///     against an intent; the painted loop stays as the fallback.
class StepMotionLibrary {
  static final Map<StepMotion, String> _lottieAssets = {};

  static void registerLottie(StepMotion intent, String assetPath) {
    _lottieAssets[intent] = assetPath;
  }

  static bool hasLottie(StepMotion intent) => _lottieAssets.containsKey(intent);

  static StepMotion intentFor(String stepText) =>
      StepDiagram.motionFor(stepText);

  /// Renders the best available illustration for a step.
  static Widget build(BuildContext context, String stepText,
      {double height = 168}) {
    final intent = intentFor(stepText);
    final asset = _lottieAssets[intent];

    if (asset != null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: Lottie.asset(
          asset,
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (_, __, ___) => StepDiagram(
            stepText: stepText,
            height: height,
          ),
        ),
      );
    }

    return StepDiagram(stepText: stepText, height: height);
  }

  const StepMotionLibrary._();
}
