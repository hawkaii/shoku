import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/prefs.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/foundation.dart';

/// Three steps, one of which you actually perform: tap share on a mock reel,
/// then tap Shoku in the mock share sheet. That gesture is the whole product.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  void _finish() {
    ref.read(onboardingDoneProvider.notifier).state = true;
    Prefs.setOnboardingDone(true);
  }

  void _next() {
    if (_page == 2) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.sm,
                ShokuSpace.lg,
                0,
              ),
              child: Row(
                children: [
                  Text('SHOKU', style: ShokuType.label.copyWith(color: c.inkMuted)),
                  const Spacer(),
                  if (_page < 2)
                    GestureDetector(
                      onTap: _finish,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Skip',
                          style: ShokuType.label.copyWith(color: c.inkMuted),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _IntroStep(),
                  _ShareStep(
                    onDone: () {
                      Future<void>.delayed(const Duration(milliseconds: 700), () {
                        if (mounted) _next();
                      });
                    },
                  ),
                  const _JournalStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                ShokuSpace.md,
                ShokuSpace.lg,
                ShokuSpace.lg,
              ),
              child: Column(
                children: [
                  AnimatedSmoothIndicator(
                    activeIndex: _page,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 3.2,
                      spacing: 5,
                      activeDotColor: c.ink,
                      dotColor: c.hairline,
                    ),
                  ),
                  const SizedBox(height: ShokuSpace.lg),
                  _PrimaryCta(
                    label: _page == 0
                        ? 'Show me how'
                        : _page == 1
                            ? 'Continue'
                            : 'Open my journal',
                    onTap: _next,
                  ),
                  const SizedBox(height: ShokuSpace.sm),
                  Text(
                    _page == 0
                        ? 'Takes 20 seconds'
                        : _page == 1
                            ? 'You can do this from any app'
                            : 'Everything stays on your phone',
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
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

class _PrimaryCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryCta({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: ShokuGradients.crimsonPress,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: c.ink, width: ShokuStroke.brutal),
          boxShadow: [
            BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
          ],
        ),
        child: Center(
          child: Text(label, style: ShokuType.title.copyWith(color: c.onAccent)),
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep();

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
              style: ShokuType.display.copyWith(fontSize: 54, color: c.ink),
              children: [TextSpan(text: '.', style: TextStyle(color: c.accent))],
            ),
          ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.12, curve: Curves.easeOutCubic),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'Your cooking,\nkept.',
            style: ShokuType.h1.copyWith(color: c.ink, fontSize: 30),
          ).animate().fadeIn(delay: 90.ms, duration: 420.ms).slideY(begin: 0.1),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'Save a recipe from a reel. Cook it. Log what you changed. Watch a dish become yours over four or five versions.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ).animate().fadeIn(delay: 170.ms, duration: 420.ms),
          const SizedBox(height: ShokuSpace.xl),
          Row(
            children: [
              ShokuChip('Instagram', icon: Icons.camera_alt_outlined),
              const SizedBox(width: ShokuSpace.xs),
              ShokuChip('YouTube', icon: Icons.play_circle_outline),
              const SizedBox(width: ShokuSpace.xs),
              ShokuChip('Versions', icon: Icons.history),
            ],
          ).animate().fadeIn(delay: 250.ms, duration: 420.ms),
        ],
      ),
    );
  }
}

class _ShareStep extends StatefulWidget {
  final VoidCallback onDone;
  const _ShareStep({required this.onDone});

  @override
  State<_ShareStep> createState() => _ShareStepState();
}

class _ShareStepState extends State<_ShareStep> {
  int _stage = 0; // 0 reel, 1 share sheet, 2 saved

  void _tapShare() => setState(() => _stage = 1);

  void _tapShoku() {
    setState(() => _stage = 2);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: ShokuSpace.md),
          ShokuLabel('step 1 · share', color: c.accent),
          const SizedBox(height: ShokuSpace.xs),
          Text(
            'Tap share, pick Shoku.',
            style: ShokuType.h1.copyWith(color: c.ink, fontSize: 24),
          ),
          const SizedBox(height: ShokuSpace.md),

          // Mock reel
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
                        child: Text('h', style: ShokuType.stat.copyWith(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.sm),
                    Text('@highprotein.eats', style: ShokuType.bodySmall.copyWith(color: c.ink)),
                    const Spacer(),
                    Icon(Icons.more_horiz, size: 16, color: c.inkMuted),
                  ],
                ),
                const SizedBox(height: ShokuSpace.sm),
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(ShokuRadius.media),
                    border: Border.all(color: c.hairline),
                  ),
                  child: const Center(child: Text('🍫', style: TextStyle(fontSize: 36))),
                ),
                const SizedBox(height: ShokuSpace.sm),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 15, color: c.inkMuted),
                    const SizedBox(width: 4),
                    Text('12.4k', style: ShokuType.stat.copyWith(fontSize: 10, color: c.inkMuted)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _stage == 0 ? _tapShare : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: _stage == 0 ? c.accent : c.surfaceAlt,
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          border: Border.all(
                            color: _stage == 0 ? c.ink : c.hairline,
                            width: _stage == 0 ? ShokuStroke.brutal : 1,
                          ),
                        ),
                        child: Icon(
                          Icons.send,
                          size: 15,
                          color: _stage == 0 ? c.onAccent : c.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_stage == 0)
            Padding(
              padding: const EdgeInsets.only(top: ShokuSpace.sm),
              child: Text(
                '↑ tap the share arrow',
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),

          // Mock share sheet
          if (_stage >= 1)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: ShokuSpace.md),
                  padding: const EdgeInsets.all(ShokuSpace.lg),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(ShokuRadius.sheet),
                    ),
                    border: Border.all(color: c.hairline),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 34,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: ShokuSpace.md),
                          decoration: BoxDecoration(
                            color: c.hairline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text('Share to', style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                      const SizedBox(height: ShokuSpace.md),
                      Row(
                        children: [
                          _Target(label: 'Messages', color: const Color(0xFF34C759), text: 'M'),
                          const SizedBox(width: ShokuSpace.md),
                          _Target(label: 'WhatsApp', color: const Color(0xFF25D366), text: 'W'),
                          const SizedBox(width: ShokuSpace.md),
                          GestureDetector(
                            onTap: _stage == 1 ? _tapShoku : null,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: _stage == 1 ? 1.06 : 1,
                              child: Container(
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
                                        color: c.accentSoft,
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
                                    Text('Shoku', style: ShokuType.label.copyWith(color: c.accent, fontSize: 9)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: ShokuSpace.md),
                          _Target(label: 'More', color: c.surfaceAlt, text: '+'),
                        ],
                      ),
                      const SizedBox(height: ShokuSpace.md),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _stage == 2 ? 'Saved as v1 — now cook it' : '↑ tap Shoku',
                          key: ValueKey(_stage),
                          style: ShokuType.bodySmall.copyWith(
                            color: _stage == 2 ? c.ready : c.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Target extends StatelessWidget {
  final String label;
  final Color color;
  final String text;
  const _Target({required this.label, required this.color, required this.text});

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
        Text(label, style: ShokuType.label.copyWith(color: c.inkMuted, fontSize: 9)),
      ],
    );
  }
}

class _JournalStep extends StatelessWidget {
  const _JournalStep();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShokuLabel('step 2 · keep', color: c.accent),
          const SizedBox(height: ShokuSpace.xs),
          Text(
            'Every cook becomes\na version.',
            style: ShokuType.h1.copyWith(color: c.ink, fontSize: 26),
          ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.08),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'Log a photo, how it went, and one thing you changed. Next time you cook it, you start from what you learned.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ).animate().fadeIn(delay: 80.ms, duration: 380.ms),
          const SizedBox(height: ShokuSpace.lg),
          ...[
            ('v1', 'Too sweet. Honey down to 1 tbsp.', c.inkMuted),
            ('v2', 'Whip the whites separately.', c.ink),
            ('v3', 'Nailed it. Salt on top.', c.ready),
          ].asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: ShokuSpace.sm),
                  child: Row(
                    children: [
                      Text(
                        e.value.$1,
                        style: ShokuType.stat.copyWith(fontSize: 12, color: c.accent),
                      ),
                      const SizedBox(width: ShokuSpace.md),
                      Container(width: 1, height: 26, color: c.hairline),
                      const SizedBox(width: ShokuSpace.md),
                      Expanded(
                        child: Text(
                          e.value.$2,
                          style: ShokuType.bodySmall.copyWith(color: e.value.$3),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: (120 + e.key * 70).ms)
                    .fadeIn(duration: 320.ms)
                    .slideX(begin: 0.04),
              ),
        ],
      ),
    );
  }
}
