import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nutrition is a lens, not a tab. Off until the user finishes the setup.
class NutritionProfile {
  final bool onboarded;
  final int heightCm;
  final int weightKg;
  final int age;
  final String goal; // lose / maintain / gain
  final int kcalTarget;
  final int proteinTarget;
  final int fibreTarget;
  final int startWeightKg;

  const NutritionProfile({
    this.onboarded = false,
    this.heightCm = 175,
    this.weightKg = 72,
    this.age = 27,
    this.goal = 'maintain',
    this.kcalTarget = 2100,
    this.proteinTarget = 130,
    this.fibreTarget = 28,
    this.startWeightKg = 72,
  });

  NutritionProfile copyWith({
    bool? onboarded,
    int? heightCm,
    int? weightKg,
    int? age,
    String? goal,
    int? kcalTarget,
    int? proteinTarget,
    int? fibreTarget,
    int? startWeightKg,
  }) =>
      NutritionProfile(
        onboarded: onboarded ?? this.onboarded,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        age: age ?? this.age,
        goal: goal ?? this.goal,
        kcalTarget: kcalTarget ?? this.kcalTarget,
        proteinTarget: proteinTarget ?? this.proteinTarget,
        fibreTarget: fibreTarget ?? this.fibreTarget,
        startWeightKg: startWeightKg ?? this.startWeightKg,
      );

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));
}

class NutritionNotifier extends StateNotifier<NutritionProfile> {
  NutritionNotifier() : super(const NutritionProfile());

  void update(NutritionProfile profile) => state = profile;

  /// Mifflin–St Jeor with a light activity factor. Deliberately conservative:
  /// no aggressive deficits, and a floor of 1500 kcal.
  void completeSetup({
    required int heightCm,
    required int weightKg,
    required int age,
    required String goal,
    required String activity,
  }) {
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    final factor = switch (activity) {
      'high' => 1.725,
      'moderate' => 1.55,
      _ => 1.35,
    };
    final tdee = bmr * factor;
    final adjust = switch (goal) {
      'lose' => -350.0,
      'gain' => 250.0,
      _ => 0.0,
    };
    final kcal = (tdee + adjust).clamp(1500, 3600).round();
    final protein = (weightKg * 1.6).round();

    state = state.copyWith(
      onboarded: true,
      heightCm: heightCm,
      weightKg: weightKg,
      startWeightKg: weightKg,
      age: age,
      goal: goal,
      kcalTarget: kcal,
      proteinTarget: protein,
    );
  }
}

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, NutritionProfile>((ref) => NutritionNotifier());
