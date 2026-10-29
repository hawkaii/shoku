# Step motion assets

Drop licensed Lottie files here, one per cooking intent, then register them:

```dart
StepMotionLibrary.registerLottie(StepMotion.fold, 'assets/motion/fold.json');
```

The painted loops in `step_illustration.dart` remain the fallback, so a missing
or failed asset never leaves a blank step.
