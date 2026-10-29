import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/controls.dart';
import '../../widgets/kit/foundation.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = 4;

  void _next() {
    if (_page == _pages - 1) {
      ref.read(onboardingDoneProvider.notifier).state = true;
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---- Skip ---------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.sm,
                ShokuSpace.lg,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    'SHOKU',
                    style: ShokuType.label.copyWith(color: c.inkMuted),
                  ),
                  const Spacer(),
                  if (_page < _pages - 1)
                    GestureDetector(
                      onTap: () => ref.read(onboardingDoneProvider.notifier).state = true,
                      child: Text(
                        'Skip',
                        style: ShokuType.label.copyWith(color: c.inkMuted),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _IntroPage(),
                  _SharePage(),
                  _SavePage(),
                  _NotifyPage(),
                ],
              ),
            ),
            // ---- Footer -------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.md,
                ShokuSpace.lg,
                ShokuSpace.lg,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: i == _page ? 18 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i == _page ? c.ink : c.hairline,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: ShokuSpace.lg),
                  ShokuButton(
                    _page == 0
                        ? 'Learn to Shoku'
                        : _page == _pages - 1
                            ? 'Enable notifications'
                            : 'Continue',
                    onPressed: _next,
                  ),
                  if (_page == _pages - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: ShokuSpace.sm),
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(onboardingDoneProvider.notifier).state = true,
                        child: Text(
                          'Not now',
                          style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Shoku',
              style: ShokuType.display.copyWith(fontSize: 52, color: c.ink),
              children: [TextSpan(text: '.', style: TextStyle(color: c.accent))],
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'Reels in.\nRecipes out.',
            style: ShokuType.h1.copyWith(color: c.ink, fontSize: 30),
          ),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'Share a cooking reel from Instagram or YouTube and it lands here as a recipe, a note, or a line in your pantry.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.xl),
          Row(
            children: [
              ShokuChip('Instagram', icon: Icons.camera_alt_outlined),
              const SizedBox(width: ShokuSpace.xs),
              ShokuChip('YouTube', icon: Icons.play_circle_outline),
              const SizedBox(width: ShokuSpace.xs),
              ShokuChip('Links', icon: Icons.link),
            ],
          ),
        ],
      ),
    );
  }
}

class _SharePage extends StatelessWidget {
  const _SharePage();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('01 · share the reel', style: ShokuType.label.copyWith(color: c.accent)),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'Tap share in the app you are already in.',
            style: ShokuType.h1.copyWith(color: c.ink),
          ),
          const SizedBox(height: ShokuSpace.lg),

          // Mock reel card
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c.surfaceAlt,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.hairline),
                      ),
                      child: Center(
                        child: Text(
                          'h',
                          style: ShokuType.stat.copyWith(fontSize: 11, color: c.ink),
                        ),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.sm),
                    Text(
                      '@highprotein.eats',
                      style: ShokuType.bodySmall.copyWith(color: c.ink),
                    ),
                    const Spacer(),
                    Icon(Icons.more_horiz, size: 16, color: c.inkMuted),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(ShokuRadius.media),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Center(
                    child: Text('🍫', style: TextStyle(fontSize: 34, color: c.ink)),
                  ),
                ),
                const SizedBox(height: ShokuSpace.md),
                Text(
                  '4-ingredient protein chocolate mousse',
                  style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                ),
                const SizedBox(height: ShokuSpace.md),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 16, color: c.inkMuted),
                    const SizedBox(width: 4),
                    Text('12.4k', style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted)),
                    const SizedBox(width: ShokuSpace.md),
                    Icon(Icons.mode_comment_outlined, size: 16, color: c.inkMuted),
                    const SizedBox(width: 4),
                    Text('318', style: ShokuType.stat.copyWith(fontSize: 11, color: c.inkMuted)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(ShokuRadius.chip),
                        border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                      ),
                      child: Icon(
                        Icons.send,
                        size: 15,
                        color: context.isDark ? const Color(0xFF1A0D09) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'That is the whole gesture. No copy-pasting links.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _SavePage extends StatelessWidget {
  const _SavePage();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('02 · pick shoku', style: ShokuType.label.copyWith(color: c.accent)),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'It shows up in your share sheet.',
            style: ShokuType.h1.copyWith(color: c.ink),
          ),
          const SizedBox(height: ShokuSpace.lg),
          ShokuSurface(
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share to', style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                const SizedBox(height: ShokuSpace.md),
                Row(
                  children: [
                    _ShareTarget(label: 'Messages', color: const Color(0xFF34C759), text: 'M'),
                    const SizedBox(width: ShokuSpace.md),
                    _ShareTarget(label: 'WhatsApp', color: const Color(0xFF25D366), text: 'W'),
                    const SizedBox(width: ShokuSpace.md),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ShokuRadius.card),
                        border: Border.all(color: c.accent, width: ShokuStroke.brutal),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(ShokuRadius.media),
                            ),
                            child: Center(
                              child: Text(
                                'S.',
                                style: ShokuType.h2.copyWith(color: c.accent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Shoku', style: ShokuType.label.copyWith(color: c.accent)),
                        ],
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.md),
                    _ShareTarget(label: 'More', color: c.surfaceAlt, text: '+'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'One tap. A few seconds later it is a recipe with steps and a shopping list.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _ShareTarget extends StatelessWidget {
  final String label;
  final Color color;
  final String text;
  const _ShareTarget({required this.label, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ShokuRadius.media),
          ),
          child: Center(
            child: Text(
              text,
              style: ShokuType.title.copyWith(
                color: label == 'More' ? c.ink : Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: ShokuType.label.copyWith(color: c.inkMuted, fontSize: 9.5)),
      ],
    );
  }
}

class _NotifyPage extends StatelessWidget {
  const _NotifyPage();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ShokuRadius.card),
              border: Border.all(color: c.accent.withValues(alpha: 0.35)),
            ),
            child: Icon(Icons.notifications_active_outlined, color: c.accent),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Text(
            'Know the second it is ready.',
            style: ShokuType.h1.copyWith(color: c.ink),
          ),
          const SizedBox(height: ShokuSpace.sm),
          Text(
            'Extraction takes a few seconds. We ping you when the recipe or the notes are done, so you can put the phone down.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),
          ShokuSurface(
            color: c.surfaceAlt,
            padding: const EdgeInsets.all(ShokuSpace.md),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 17, color: c.inkMuted),
                const SizedBox(width: ShokuSpace.sm),
                Expanded(
                  child: Text(
                    'No streaks, no nudges. Only when a save finishes.',
                    style: ShokuType.bodySmall.copyWith(color: c.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
