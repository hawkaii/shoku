import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../widgets/kit/plate_mark.dart';

/// Nutrition is not built yet. This screen exists so the route never lies:
/// no targets, no BMI, no macro deltas, no body-detail form.
class NutritionComingSoonScreen extends StatelessWidget {
  const NutritionComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition', style: ShokuType.h1.copyWith(color: c.ink)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PlateMark(size: 96),
              const SizedBox(height: ShokuSpace.lg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.reward,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                ),
                child: Text('COMING SOON',
                    style: ShokuType.label.copyWith(color: c.canvas, fontSize: 9)),
              ),
              const SizedBox(height: ShokuSpace.md),
              Text('A lens on how your cooking changes.',
                  textAlign: TextAlign.center,
                  style: ShokuType.h2.copyWith(color: c.ink)),
              const SizedBox(height: ShokuSpace.sm),
              Text(
                'Your journal works without it. When it lands, it will read only the meals you cook here.',
                textAlign: TextAlign.center,
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: ShokuSpace.xl),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text('Back to You',
                    style: ShokuType.title.copyWith(color: c.ink, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
