import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

/// The app's diagram language, taken from the chosen marks:
/// thick ink outlines, flat crimson and bay-leaf fills, paper ground,
/// nothing thinner than 6 units at 256. Every diagram is drawn, not stocked.
enum StepMotion { whisk, chop, fold, separate, simmer, bake, chill, plate }

class StepDiagram extends StatefulWidget {
  final String stepText;
  final double height;

  const StepDiagram({super.key, required this.stepText, this.height = 168});

  static StepMotion motionFor(String text) {
    final t = text.toLowerCase();
    if (t.contains('whisk') || t.contains('whip')) return StepMotion.whisk;
    if (t.contains('chop') || t.contains('slice') || t.contains('cube')) {
      return StepMotion.chop;
    }
    if (t.contains('separate') || t.contains('crack') || t.contains('yolk')) {
      return StepMotion.separate;
    }
    if (t.contains('fold') || t.contains('toss')) return StepMotion.fold;
    if (t.contains('simmer') ||
        t.contains('boil') ||
        t.contains('fry') ||
        t.contains('sauce')) {
      return StepMotion.simmer;
    }
    if (t.contains('bake') || t.contains('oven') || t.contains('roast')) {
      return StepMotion.bake;
    }
    if (t.contains('chill') || t.contains('fridge') || t.contains('cool')) {
      return StepMotion.chill;
    }
    return StepMotion.plate;
  }

  @override
  State<StepDiagram> createState() => _StepDiagramState();
}

class _StepDiagramState extends State<StepDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _DiagramPainter(
              motion: StepDiagram.motionFor(widget.stepText),
              t: reduce ? 0.3 : _c.value,
              ink: colors.ink,
              crimson: colors.accent,
              leaf: colors.ready,
              paper: colors.canvas,
              well: colors.surfaceAlt,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagramPainter extends CustomPainter {
  final StepMotion motion;
  final double t;
  final Color ink;
  final Color crimson;
  final Color leaf;
  final Color paper;
  final Color well;

  _DiagramPainter({
    required this.motion,
    required this.t,
    required this.ink,
    required this.crimson,
    required this.leaf,
    required this.paper,
    required this.well,
  });

  // 256-unit design space, exactly like the marks.
  static const double _design = 256;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _design, size.height / _design);
    canvas.save();
    canvas.translate(
      (size.width - _design * scale) / 2,
      (size.height - _design * scale) / 2,
    );
    canvas.scale(scale);

    final inkPaint = Paint()..color = ink;
    final crimsonPaint = Paint()..color = crimson;
    final leafPaint = Paint()..color = leaf;
    final paperPaint = Paint()..color = paper;
    final wellPaint = Paint()..color = well;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (motion) {
      case StepMotion.whisk:
        _whisk(canvas, inkPaint, crimsonPaint, stroke, paperPaint, wellPaint);
      case StepMotion.chop:
        _chop(canvas, inkPaint, crimsonPaint, stroke, paperPaint, leafPaint);
      case StepMotion.fold:
        _fold(canvas, inkPaint, crimsonPaint, stroke, paperPaint, leafPaint,
            wellPaint);
      case StepMotion.separate:
        _separate(
            canvas, inkPaint, crimsonPaint, stroke, paperPaint, wellPaint);
      case StepMotion.simmer:
        _simmer(canvas, inkPaint, crimsonPaint, stroke, paperPaint, wellPaint);
      case StepMotion.bake:
        _bake(canvas, inkPaint, crimsonPaint, stroke, paperPaint);
      case StepMotion.chill:
        _chill(canvas, inkPaint, crimsonPaint, stroke, paperPaint);
      case StepMotion.plate:
        _plate(canvas, inkPaint, crimsonPaint, stroke, paperPaint, leafPaint);
    }

    canvas.restore();
  }

  /// A bowl in the marks' plate language: thick ring, flat well, no gradients.
  void _bowl(Canvas canvas, Paint inkPaint, Paint wellPaint, Paint paperPaint) {
    canvas.drawOval(const Rect.fromLTWH(40, 96, 176, 120), inkPaint);
    canvas.drawOval(const Rect.fromLTWH(58, 108, 140, 96), paperPaint);
    canvas.drawOval(const Rect.fromLTWH(72, 118, 112, 76), wellPaint);
  }

  /// A chef's knife that reads as a knife: broad tapered blade, short handle.
  void _knife(Canvas canvas, Paint inkPaint, Paint crimsonPaint, double angle) {
    canvas.save();
    canvas.translate(128, 128);
    canvas.rotate(angle);
    canvas.translate(-128, -128);
    final blade = Path()
      ..moveTo(62, 132)
      ..lineTo(170, 104)
      ..lineTo(178, 122)
      ..quadraticBezierTo(150, 138, 120, 148)
      ..close();
    canvas.drawPath(blade, inkPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(158, 100, 52, 26), const Radius.circular(10)),
      crimsonPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(158, 100, 52, 26), const Radius.circular(10)),
      Paint()
        ..color = inkPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    canvas.restore();
  }

  void _whisk(Canvas canvas, Paint inkPaint, Paint crimsonPaint, Paint stroke,
      Paint paperPaint, Paint wellPaint) {
    _bowl(canvas, inkPaint, wellPaint, paperPaint);
    final angle = t * math.pi * 2;
    canvas.save();
    canvas.translate(128 + math.cos(angle) * 10, 150 + math.sin(angle) * 4);
    whiskHead(canvas, stroke);
    canvas.restore();
    // motion arcs
    final arc = Paint()
      ..color = crimsonPaint.color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        const Rect.fromLTWH(70, 130, 116, 74), angle, 1.1, false, arc);
  }

  void whiskHead(Canvas canvas, Paint stroke) {
    canvas.drawLine(const Offset(0, -76), const Offset(0, 24), stroke);
    for (var i = -1; i <= 1; i++) {
      final path = Path()
        ..moveTo(i * 11.0, -46)
        ..quadraticBezierTo(i * 26.0, -6, 0, 22);
      canvas.drawPath(path, stroke);
    }
  }

  void _chop(Canvas canvas, Paint inkPaint, Paint crimsonPaint, Paint stroke,
      Paint paperPaint, Paint leafPaint) {
    // board
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(46, 150, 164, 34), const Radius.circular(10)),
      inkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(56, 156, 144, 18), const Radius.circular(6)),
      paperPaint,
    );
    // onion halves
    canvas.drawCircle(const Offset(92, 138), 18, leafPaint);
    canvas.drawCircle(const Offset(124, 140), 15, leafPaint);
    // knife, rocking
    _knife(canvas, inkPaint, crimsonPaint,
        -0.5 + math.sin(t * math.pi * 2) * 0.12);
    // falling pieces
    for (var i = 0; i < 2; i++) {
      final p = (t + i * 0.4) % 1;
      canvas.drawCircle(
        Offset(150.0 + i * 14, 120 + p * 34),
        4,
        Paint()..color = crimsonPaint.color.withValues(alpha: 1 - p * 0.7),
      );
    }
  }

  void _fold(Canvas canvas, Paint inkPaint, Paint crimsonPaint, Paint stroke,
      Paint paperPaint, Paint leafPaint, Paint wellPaint) {
    _bowl(canvas, inkPaint, wellPaint, paperPaint);
    // mixture
    canvas.drawOval(const Rect.fromLTWH(86, 138, 84, 40), crimsonPaint);
    // spatula sweeping
    final angle = -0.7 + math.sin(t * math.pi * 2) * 0.45;
    canvas.save();
    canvas.translate(96, 92);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-6, -6, 96, 16), const Radius.circular(8)),
      inkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(74, -18, 40, 40), const Radius.circular(10)),
      leafPaint,
    );
    canvas.restore();
    canvas.drawArc(const Rect.fromLTWH(78, 132, 100, 56), t * math.pi * 2, 1.4,
        false, stroke);
  }

  void _separate(Canvas canvas, Paint inkPaint, Paint crimsonPaint,
      Paint stroke, Paint paperPaint, Paint wellPaint) {
    _bowl(canvas, inkPaint, wellPaint, paperPaint);

    // two yolks, deliberately off-centre so it never reads as a face
    final slide = math.sin(t * math.pi * 2) * 10;
    canvas.drawCircle(Offset(98 - slide, 172), 19, crimsonPaint);
    canvas.drawCircle(Offset(152 + slide, 162), 14, crimsonPaint);

    // one cracked shell resting beside the bowl
    final shell = Path()
      ..moveTo(186, 206)
      ..quadraticBezierTo(206, 186, 226, 204)
      ..quadraticBezierTo(206, 222, 186, 206)
      ..close();
    canvas.drawPath(shell, paperPaint);
    canvas.drawPath(shell, stroke..strokeWidth = 6);
  }

  void _simmer(Canvas canvas, Paint inkPaint, Paint crimsonPaint, Paint stroke,
      Paint paperPaint, Paint wellPaint) {
    // pan: wide body + handle
    final pan = Path()
      ..moveTo(48, 138)
      ..lineTo(174, 138)
      ..quadraticBezierTo(168, 198, 111, 198)
      ..quadraticBezierTo(54, 198, 48, 138)
      ..close();
    canvas.drawPath(pan, inkPaint);
    canvas.drawOval(const Rect.fromLTWH(58, 132, 106, 26), paperPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(168, 146, 46, 16), const Radius.circular(8)),
      inkPaint,
    );
    // sauce + bubbles
    canvas.drawOval(const Rect.fromLTWH(62, 140, 98, 22), crimsonPaint);
    for (var i = 0; i < 3; i++) {
      final p = (t + i * 0.33) % 1;
      canvas.drawCircle(
        Offset(84.0 + i * 30, 148 - p * 46),
        7 - p * 3,
        Paint()..color = crimsonPaint.color.withValues(alpha: 1 - p),
      );
    }
  }

  void _bake(Canvas canvas, Paint inkPaint, Paint crimsonPaint, Paint stroke,
      Paint paperPaint) {
    // oven
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(48, 76, 160, 132), const Radius.circular(16)),
      inkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(64, 94, 128, 76), const Radius.circular(10)),
      paperPaint,
    );
    // tray with a loaf
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(78, 176, 100, 18), const Radius.circular(8)),
      crimsonPaint,
    );
    // heat lines rising inside the window
    for (var i = 0; i < 3; i++) {
      final p = (t + i * 0.33) % 1;
      final x = 90.0 + i * 32;
      final y = 156 - p * 46;
      canvas.drawLine(Offset(x, y), Offset(x, y - 14), stroke);
    }
  }

  void _chill(Canvas canvas, Paint inkPaint, Paint crimsonPaint, Paint stroke,
      Paint paperPaint) {
    canvas.save();
    canvas.translate(128, 128);
    canvas.rotate(t * 0.5);
    for (var i = 0; i < 3; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 3);
      canvas.drawLine(const Offset(0, -54), const Offset(0, 54), stroke);
      canvas.restore();
    }
    canvas.restore();
    canvas.drawCircle(const Offset(128, 128), 14, crimsonPaint);
  }

  void _plate(Canvas canvas, Paint inkPaint, Paint crimsonPaint, Paint stroke,
      Paint paperPaint, Paint leafPaint) {
    // the chosen mark, reused as the default diagram
    canvas.drawOval(const Rect.fromLTWH(34, 54, 188, 152), inkPaint);
    canvas.drawOval(const Rect.fromLTWH(50, 66, 156, 126), paperPaint);
    canvas.drawOval(const Rect.fromLTWH(68, 78, 120, 102), paperPaint);
    canvas.drawCircle(const Offset(116, 122), 26, crimsonPaint);
    canvas.drawCircle(const Offset(150, 138), 11, leafPaint);
  }

  @override
  bool shouldRepaint(_DiagramPainter old) => old.t != t || old.ink != ink;
}
