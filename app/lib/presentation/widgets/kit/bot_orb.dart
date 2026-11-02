import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../screens/bot/bot_scope.dart';
import '../../screens/bot/bot_surface.dart';
import '../../state/bot_providers.dart';
import 'bot_mark.dart';
import 'motion.dart';

/// The assistant, everywhere it is allowed to be.
///
/// It sits on the trailing edge, twelve pixels above the tab bar — never in the
/// middle, which belongs to the fridge. Resting it is paper and ink; it fills
/// with the accent only when a reply arrived while it was collapsed, and wears
/// a small dot when a draft is waiting. A slash means it cannot answer at all.
class BotOrb extends ConsumerWidget {
  const BotOrb({super.key, this.scope});

  /// Dish threads pass their dish; the shell leaves it null for the kitchen.
  final BotScope? scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    // The orb must not build the bot controller: that controller reads the
    // assistant thread and the pantry at construction, and doing it while the
    // Journal is still booting is what left the Journal looking empty on a
    // release web build. The sheet creates the controller when it opens.
    final offline = ref.watch(botOfflineProvider);
    final style = botOrbStyle(
      unread: false,
      offline: offline,
      draft: false,
    );

    return Semantics(
      button: true,
      label: 'Assistant',
      child: ShokuPressable(
        key: const ValueKey('bot-orb'),
        onTap: () => showBotSheet(context, scope: scope),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: style.filled ? c.accent : c.surface,
            shape: BoxShape.circle,
            border: Border.all(color: c.ink, width: ShokuStroke.brutal),
            boxShadow: [
              BoxShadow(color: c.ink, offset: const Offset(0, 2), blurRadius: 0),
            ],
          ),
          child: Center(
            child: BotMark(
              key: const ValueKey('bot-mark'),
              size: 22,
              filled: style.filled,
              offline: style.offline,
              draftDot: style.draftDot,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cook mode's assistant: 40 px, in the step header, never over the timer.
class BotInlineChip extends StatelessWidget {
  const BotInlineChip({super.key, required this.onTap, this.badge});

  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'Ask about this step',
      child: GestureDetector(
        key: const ValueKey('bot-inline-chip'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.pill),
            border: Border.all(color: c.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BotMark(
                key: ValueKey('bot-mark-chip'),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('Ask',
                  style:
                      ShokuType.title.copyWith(color: c.ink, fontSize: 12.5)),
              if (badge != null) ...[
                const SizedBox(width: 5),
                Text(badge!,
                    style: ShokuType.label
                        .copyWith(fontSize: 9, color: c.inkMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
