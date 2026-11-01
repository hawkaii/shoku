import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/prefs.dart';
import '../../state/shoku_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/plate_mark.dart';

/// Three steps, and the middle one is the product: you actually perform the
/// share gesture once, here, so you know it forever.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final int _initialPage =
      int.tryParse(Uri.base.queryParameters['onboardStep'] ?? '') ?? 0;
  late final PageController _controller = PageController(initialPage: _initialPage);
  late int _page = _initialPage;
  int _stage = 0; // 0 = reel, 1 = share sheet, 2 = saved

  Future<void> _finish() async {
    await Prefs.setOnboardingDone(true);
    ref.read(onboardingDoneProvider.notifier).state = true;
  }

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
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
              padding: const EdgeInsets.fromLTRB(ShokuSpace.lg, ShokuSpace.sm, ShokuSpace.lg, 0),
              child: Row(
                children: [
                  Text('SHOKU', style: ShokuType.label.copyWith(color: c.inkMuted)),
                  const Spacer(),
                  if (_page < 2)
                    GestureDetector(
                      onTap: _finish,
                      child: Text('Skip',
                          style: ShokuType.label.copyWith(color: c.inkMuted)),
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
                    stage: _stage,
                    onShareTap: () => setState(() => _stage = 1),
                    onPickShoku: () => setState(() => _stage = 2),
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
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotWidth: 6,
                      dotHeight: 6,
                      expansionFactor: 3,
                      spacing: 4,
                      activeDotColor: c.ink,
                      dotColor: c.hairline,
                    ),
                  ),
                  const SizedBox(height: ShokuSpace.lg),
                  ShokuPressable(
                    onTap: _next,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: ShokuGradients.crimsonPress,
                        borderRadius: BorderRadius.circular(ShokuRadius.chip),
                        border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                        boxShadow: [
                          BoxShadow(
                              color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _page == 0
                              ? 'Start cooking'
                              : _page == 1
                                  ? (_stage == 2 ? 'Continue' : 'Share a reel to try it')
                                  : 'Open my journal',
                          style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14),
                        ),
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
          _reveal(
            context,
            const PlateMark(size: 84),
          ),
          const SizedBox(height: ShokuSpace.sm),
          _reveal(
            context,
            Text.rich(
              TextSpan(
                text: 'Shoku',
                style: ShokuType.display.copyWith(fontSize: 54, color: c.ink),
                children: [TextSpan(text: '.', style: TextStyle(color: c.accent))],
              ),
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
          _reveal(
            context,
            Text('Cook it once.\nMake it yours.',
                style: ShokuType.h1.copyWith(color: c.ink, fontSize: 28)),
            delayMs: 80,
          ),
          const SizedBox(height: ShokuSpace.md),
          _reveal(
            context,
            Text(
              'Every time you cook, you change something. Shoku remembers those changes, so next time you can pick the version that fits tonight.',
              style: ShokuType.body.copyWith(color: c.inkMuted),
            ),
            delayMs: 160,
          ),
          const SizedBox(height: ShokuSpace.xl),
          _reveal(
            context,
            const Row(
              children: [
                ShokuChip('Instagram', icon: Icons.camera_alt_outlined),
                SizedBox(width: 6),
                ShokuChip('YouTube', icon: Icons.play_circle_outline),
              ],
            ),
            delayMs: 240,
          ),
        ],
      ),
    );
  }
}

class _ShareStep extends StatelessWidget {
  final int stage;
  final VoidCallback onShareTap;
  final VoidCallback onPickShoku;

  const _ShareStep({
    required this.stage,
    required this.onShareTap,
    required this.onPickShoku,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('01 · SHARE THE REEL', style: ShokuType.label.copyWith(color: c.accent)),
          const SizedBox(height: ShokuSpace.sm),
          Text('One tap, from the app you are already in.',
              style: ShokuType.h1.copyWith(color: c.ink, fontSize: 24)),
          const SizedBox(height: ShokuSpace.md),

          // Mock reel
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: stage == 2 ? 0.35 : 1,
            child: Container(
              padding: const EdgeInsets.all(ShokuSpace.sm),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.card),
                border: Border.all(color: c.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.hairline),
                        ),
                        child: Center(
                          child: Text('h',
                              style: ShokuType.stat.copyWith(fontSize: 10, color: c.ink)),
                        ),
                      ),
                      const SizedBox(width: ShokuSpace.sm),
                      Text('@highprotein.eats',
                          style: ShokuType.bodySmall.copyWith(color: c.ink)),
                      const Spacer(),
                      Text('0:48',
                          style: ShokuType.stat.copyWith(fontSize: 10, color: c.inkMuted)),
                    ],
                  ),
                  const SizedBox(height: ShokuSpace.sm),
                  Container(
                    height: 74,
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(ShokuRadius.media),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Center(
                      child: Text('4-ingredient protein mousse',
                          style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                    ),
                  ),
                  const SizedBox(height: ShokuSpace.sm),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 15, color: c.inkMuted),
                      const SizedBox(width: 4),
                      Text('12.4k',
                          style: ShokuType.stat.copyWith(fontSize: 10, color: c.inkMuted)),
                      const Spacer(),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _GlowRing(
                            active: stage == 0,
                            child: ShokuPressable(
                        onTap: onShareTap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: stage == 0 ? c.accent : c.surfaceAlt,
                            borderRadius: BorderRadius.circular(ShokuRadius.chip),
                            border: Border.all(
                              color: stage == 0 ? c.ink : c.hairline,
                              width: stage == 0 ? ShokuStroke.brutal : 1,
                            ),
                          ),
                          child: Icon(Icons.send,
                              size: 14, color: stage == 0 ? c.onAccent : c.ink),
                        ),
                      ),
                          ),
                          if (stage == 0)
                            Positioned(
                              right: 6,
                              top: -58,
                              child: _Bob(child: _ArrowHint()),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Share sheet
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: stage == 0
                ? const SizedBox(width: double.infinity)
                : Container(
                    margin: const EdgeInsets.only(top: ShokuSpace.sm),
                    padding: const EdgeInsets.all(ShokuSpace.sm),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(ShokuRadius.card),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share to',
                            style: ShokuType.title.copyWith(color: c.ink, fontSize: 12)),
                        const SizedBox(height: ShokuSpace.sm),
                        Row(
                          children: [
                            const _Target(label: 'Messages', text: 'M', color: Color(0xFF34C759)),
                            const SizedBox(width: ShokuSpace.sm),
                            const _Target(label: 'WhatsApp', text: 'W', color: Color(0xFF25D366)),
                            const SizedBox(width: ShokuSpace.sm),
                            _Target(
                              label: 'Shoku',
                              text: '',
                              color: stage == 1 ? c.accent : c.surfaceAlt,
                              highlighted: stage == 1,
                              onTap: onPickShoku,
                              mark: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          if (stage == 2)
            Padding(
              padding: const EdgeInsets.only(top: ShokuSpace.sm),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: c.ready),
                  const SizedBox(width: 6),
                  Text('Saved as v1 · extracted in 4 seconds',
                      style: ShokuType.bodySmall.copyWith(color: c.ready)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Target extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  final bool highlighted;
  final VoidCallback? onTap;
  final bool mark;

  const _Target({
    required this.label,
    required this.text,
    required this.color,
    this.highlighted = false,
    this.onTap,
    this.mark = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(ShokuRadius.media),
              border: Border.all(
                color: highlighted ? c.ink : Colors.transparent,
                width: highlighted ? ShokuStroke.brutal : 0,
              ),
            ),
            child: Center(
              child: mark
                  ? const PlateMark(size: 30)
                  : Text(text,
                      style: ShokuType.title.copyWith(
                        color: color == c.surfaceAlt ? c.ink : Colors.white,
                        fontSize: 15,
                      )),
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: ShokuType.label.copyWith(
                fontSize: 8.5,
                color: highlighted ? c.accent : c.inkMuted,
              )),
        ],
      ),
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
          Text('02 · COOK IT, CHANGE IT', style: ShokuType.label.copyWith(color: c.accent)),
          const SizedBox(height: ShokuSpace.sm),
          Text('Your journal remembers the changes.',
              style: ShokuType.h1.copyWith(color: c.ink, fontSize: 24)),
          const SizedBox(height: ShokuSpace.md),
          Text(
            'Cook mode walks you through it. When you swap something, say so. At the end you get one version — with a photo, a rating and what altered.',
            style: ShokuType.body.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Container(
            padding: const EdgeInsets.all(ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.card),
              border: Border.all(color: c.hairline),
            ),
            child: Row(
              children: [
                Text('v1', style: ShokuType.stat.copyWith(fontSize: 13, color: c.inkMuted)),
                Container(
                  width: 18,
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: c.hairline,
                ),
                Text('v2', style: ShokuType.stat.copyWith(fontSize: 13, color: c.inkMuted)),
                Container(
                  width: 18,
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  color: c.hairline,
                ),
                Text('v3', style: ShokuType.stat.copyWith(fontSize: 13, color: c.accent)),
                const SizedBox(width: ShokuSpace.sm),
                ShokuChip('altered', color: c.reward, filled: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


Widget _reveal(BuildContext context, Widget child, {int delayMs = 0}) {
  if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
  return child
      .animate(delay: Duration(milliseconds: delayMs))
      .fadeIn(duration: 320.ms)
      .slideY(begin: 0.06, end: 0);
}


/// A hand-drawn-looking arrow that points at the share icon, plus a label.
class _ArrowHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('TAP', style: ShokuType.label.copyWith(fontSize: 8, color: c.onAccent)),
        ),
        const SizedBox(height: 2),
        CustomPaint(
          size: const Size(34, 30),
          painter: _ArrowPainter(color: c.accent),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(4, 2)
      ..cubicTo(26, 2, 32, 12, 28, 26);
    canvas.drawPath(path, p);
    // arrowhead
    final head = Path()
      ..moveTo(21, 20)
      ..lineTo(28, 27)
      ..lineTo(34, 19);
    canvas.drawPath(head, p);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => oldDelegate.color != color;
}


/// Gentle 6px bob, disabled when the OS asks for reduced motion.
class _Bob extends StatefulWidget {
  final Widget child;
  const _Bob({required this.child});

  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -4 * _c.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// A pulsing ring around the share button, so the eye lands on it without copy.
class _GlowRing extends StatefulWidget {
  final bool active;
  final Widget child;
  const _GlowRing({required this.active, required this.child});

  @override
  State<_GlowRing> createState() => _GlowRingState();
}

class _GlowRingState extends State<_GlowRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (!widget.active) return widget.child;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = reduce ? 0.35 : (1 - _c.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 52 + 18 * (1 - v),
              height: 52 + 18 * (1 - v),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: c.accent.withValues(alpha: 0.55 * v),
                  width: 2,
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
