import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../state/nutrition_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

class NutritionSetupScreen extends ConsumerStatefulWidget {
  const NutritionSetupScreen({super.key});

  @override
  ConsumerState<NutritionSetupScreen> createState() => _NutritionSetupScreenState();
}

class _NutritionSetupScreenState extends ConsumerState<NutritionSetupScreen> {
  int _height = 175;
  int _weight = 72;
  int _age = 27;
  String _goal = 'maintain';
  String _activity = 'light';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition', style: ShokuType.h1.copyWith(color: c.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxxl,
        ),
        children: [
          Text(
            'Optional. Shoku only reads the meals you cook here — it is not a full-day food diary.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.xl),
          _SliderRow(
            label: 'Height',
            value: '$_height cm',
            value2: _height.toDouble(),
            min: 140,
            max: 210,
            onChanged: (v) => setState(() => _height = v.round()),
          ),
          _SliderRow(
            label: 'Weight',
            value: '$_weight kg',
            value2: _weight.toDouble(),
            min: 40,
            max: 160,
            onChanged: (v) => setState(() => _weight = v.round()),
          ),
          _SliderRow(
            label: 'Age',
            value: '$_age',
            value2: _age.toDouble(),
            min: 16,
            max: 80,
            onChanged: (v) => setState(() => _age = v.round()),
          ),
          const SizedBox(height: ShokuSpace.lg),
          ShokuLabel('goal'),
          const SizedBox(height: ShokuSpace.sm),
          ShokuSegmented(
            labels: const ['LOSE', 'MAINTAIN', 'GAIN'],
            selected: _goal == 'lose' ? 0 : (_goal == 'maintain' ? 1 : 2),
            onChanged: (i) => setState(() => _goal = ['lose', 'maintain', 'gain'][i]),
          ),
          const SizedBox(height: ShokuSpace.lg),
          ShokuLabel('how active are you'),
          const SizedBox(height: ShokuSpace.sm),
          ShokuSegmented(
            labels: const ['LIGHT', 'MODERATE', 'HIGH'],
            selected: _activity == 'light' ? 0 : (_activity == 'moderate' ? 1 : 2),
            onChanged: (i) => setState(() => _activity = ['light', 'moderate', 'high'][i]),
          ),
          const SizedBox(height: ShokuSpace.xl),
          Text(
            'Estimates only, not medical advice. Shoku will suggest a target and you can override it.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),
          ShokuPressable(
            onTap: () {
              ref.read(nutritionProvider.notifier).completeSetup(
                    heightCm: _height,
                    weightKg: _weight,
                    age: _age,
                    goal: _goal,
                    activity: _activity,
                  );
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: ShokuGradients.crimsonPress,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                boxShadow: [
                  BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
                ],
              ),
              child: Center(
                child: Text('Turn on nutrition',
                    style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String value;
  final double value2;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.value2,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
            const Spacer(),
            Text(value, style: ShokuType.stat.copyWith(fontSize: 12, color: c.accent)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: c.accent,
            inactiveTrackColor: c.surfaceAlt,
            thumbColor: c.ink,
            overlayShape: SliderComponentShape.noOverlay,
            trackHeight: 3,
          ),
          child: Slider(
            value: value2.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
