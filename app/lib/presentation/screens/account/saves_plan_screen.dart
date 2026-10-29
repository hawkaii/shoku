import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/foundation.dart';

class SavesPlanScreen extends ConsumerWidget {
  const SavesPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final plans = ref.watch(plansProvider);
    final saves = ref.watch(savesBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Saves & plan', style: ShokuType.h1.copyWith(color: c.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.sm,
          ShokuSpace.lg,
          ShokuSpace.xxl,
        ),
        children: [
          Text(
            'One save is one extraction. Retrying the same link is free.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Row(
            children: [
              ShokuStat('$saves', label: 'balance', hero: true, color: c.accent),
              const SizedBox(width: ShokuSpace.xl),
              ShokuStat('7', label: 'weekly free'),
            ],
          ),
          const SizedBox(height: ShokuSpace.xl),
          for (final plan in plans) ...[
            ShokuSurface(
              brutal: plan.highlighted,
              padding: const EdgeInsets.all(ShokuSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.name, style: ShokuType.h2.copyWith(color: c.ink)),
                      const Spacer(),
                      if (plan.highlighted)
                        ShokuChip('best value', color: c.accent, filled: true),
                    ],
                  ),
                  const SizedBox(height: ShokuSpace.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(plan.price, style: ShokuType.statHero.copyWith(color: c.ink)),
                      const SizedBox(width: ShokuSpace.xs),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          plan.cadence,
                          style: ShokuType.label.copyWith(color: c.inkMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ShokuSpace.md),
                  for (final perk in plan.perks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 14, color: c.ready),
                          const SizedBox(width: ShokuSpace.sm),
                          Expanded(
                            child: Text(
                              perk,
                              style: ShokuType.bodySmall.copyWith(color: c.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: ShokuSpace.md),
                  ShokuButton(
                    plan.name == 'Free' ? 'Current plan' : 'Choose ${plan.name}',
                    variant: plan.highlighted
                        ? ShokuButtonVariant.primary
                        : ShokuButtonVariant.outline,
                    onPressed: plan.name == 'Free' ? null : () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: ShokuSpace.md),
          ],
          Center(
            child: Text(
              'Purchases are not wired up in this build.',
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
