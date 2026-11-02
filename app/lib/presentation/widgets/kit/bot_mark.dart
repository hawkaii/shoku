import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

/// The bot's own mark: a tomato with a jagged crown and one long spike.
///
/// It is drawn, not a font icon and not an asset per size: the geometry is the
/// Designer's 22 px canvas, scaled. Four states, and only four: ink at rest,
/// accent-filled when a reply is waiting, slashed when there is no connection,
/// and a dot when a draft is held.
class BotMark extends StatelessWidget {
  const BotMark({
    super.key,
    this.size = 22,
    this.filled = false,
    this.offline = false,
    this.draftDot = false,
  });

  final double size;

  /// Belly filled with the accent, crown in `onAccent`.
  final bool filled;

  /// Hollow belly with an ink slash. The crown is never slashed.
  final bool offline;

  /// A 4.5 px accent disc at the lower right, ringed in canvas.
  final bool draftDot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BotMarkPainter(
          ink: c.ink,
          accent: c.accent,
          paper: c.canvas,
          onAccent: c.onAccent,
          filled: filled,
          offline: offline,
          draftDot: draftDot,
        ),
      ),
    );
  }
}

/// Which parts a given state paints. Exposed so the offline/draft rules can be
/// asserted without pixel-peeping.
enum BotMarkPart { crown, belly, slash, dot }

class BotMarkPainter extends CustomPainter {
  BotMarkPainter({
    required this.ink,
    required this.accent,
    required this.paper,
    required this.onAccent,
    this.filled = false,
    this.offline = false,
    this.draftDot = false,
  });

  final Color ink;
  final Color accent;
  final Color paper;
  final Color onAccent;
  final bool filled;
  final bool offline;
  final bool draftDot;

  /// The design canvas. Everything below is in these 22 units.
  static const design = 22.0;
  static const bellyCentre = Offset(10.4, 13.4);
  static const bellyRadius = Offset(5.8, 5.2);
  static const crownRoot = Offset(10.6, 11.2);

  /// Tips in angular order, clockwise from the long spike.
  static const crownTips = <Offset>[
    Offset(8.6, 4.9), // long up-left
    Offset(13.9, 6.6), // up-right
    Offset(15.6, 11.4), // right
    Offset(8.2, 15.0), // lower-left stub
    Offset(6.0, 10.9), // left
  ];

  static const draftCentre = Offset(17.5, 18.5);
  static const draftRadius = 2.25; // 4.5 px disc

  List<BotMarkPart> get parts => [
        BotMarkPart.crown,
        BotMarkPart.belly,
        if (offline) BotMarkPart.slash,
        if (draftDot && !offline) BotMarkPart.dot,
      ];

  Rect get bellyRect => Rect.fromCenter(
        center: bellyCentre,
        width: bellyRadius.dx * 2,
        height: bellyRadius.dy * 2,
      );

  Path get bellyPath => Path()..addOval(bellyRect);

  /// The crown as painted: fill kept out of the belly's interior so the lobes
  /// meet the rim instead of bleeding through it.
  Path get crownFill =>
      Path.combine(PathOperation.difference, crownPath, bellyPath);

  /// Root → each tip, with a valley pulled back toward the root between them.
  /// A single fan of root/tip/root triangles would cancel itself out; the
  /// valleys are what make it a crown with a jagged edge.
  Path get crownPath {
    final path = Path()..moveTo(crownRoot.dx, crownRoot.dy);
    for (var i = 0; i < crownTips.length; i++) {
      final tip = crownTips[i];
      final next = crownTips[(i + 1) % crownTips.length];
      path.lineTo(tip.dx, tip.dy);
      final mid = Offset.lerp(tip, next, 0.5)!;
      final valley = Offset.lerp(mid, crownRoot, 0.62)!;
      path.lineTo(valley.dx, valley.dy);
    }
    path.close();
    return path;
  }

  /// The slash, as an area clipped to the belly. Its bounds are what prove it
  /// can never reach the crown, which lives above the belly's top edge.
  Path get slashShape {
    const a = Offset(5.4, 10.2);
    const b = Offset(15.8, 17.2);
    final d = b - a;
    final len = d.distance;
    final n = Offset(-d.dy / len, d.dx / len) * 0.75;
    final quad = Path()
      ..moveTo(a.dx + n.dx, a.dy + n.dy)
      ..lineTo(b.dx + n.dx, b.dy + n.dy)
      ..lineTo(b.dx - n.dx, b.dy - n.dy)
      ..lineTo(a.dx - n.dx, a.dy - n.dy)
      ..close();
    return Path.combine(PathOperation.intersect, quad, bellyPath);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / design;
    canvas.save();
    canvas.scale(scale);

    // Crown first, so the belly line sits in front of its base. The crown is
    // filled, and the fill is kept out of the belly's interior: the lobes meet
    // the rim, they do not bleed into it.
    final crownFill = this.crownFill;
    final crownPaint = Paint()
      ..color = filled ? onAccent : ink
      ..style = PaintingStyle.fill;
    canvas.drawPath(crownFill, crownPaint);
    canvas.drawPath(
      crownFill,
      Paint()
        ..color = filled ? onAccent : ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Belly: hollow contour, or filled with an accent and a canvas gap.
    if (filled) {
      canvas.drawOval(bellyRect, Paint()..color = accent);
      canvas.drawOval(
        bellyRect.deflate(1.0),
        Paint()
          ..color = paper
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
    canvas.drawOval(
      bellyRect,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Offline: a canvas knockout under an ink slash, both inside the belly.
    if (offline) {
      canvas.save();
      canvas.clipPath(bellyPath);
      // 2.5 px of canvas around a 1.5 px ink slash; the clip keeps both inside
      // the belly, so the crown is never touched.
      canvas.drawLine(
        const Offset(5.4, 10.2),
        const Offset(15.8, 17.2),
        Paint()
          ..color = paper
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + 2.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(slashShape, Paint()..color = ink);
      canvas.restore();
    }

    // Draft: a disc with a canvas ring, only on the collapsed orb.
    if (draftDot) {
      canvas.drawCircle(
        draftCentre,
        draftRadius + 0.75,
        Paint()..color = paper,
      );
      canvas.drawCircle(draftCentre, draftRadius, Paint()..color = accent);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BotMarkPainter old) =>
      old.filled != filled ||
      old.offline != offline ||
      old.draftDot != draftDot ||
      old.ink != ink ||
      old.accent != accent ||
      old.paper != paper ||
      old.onAccent != onAccent;
}

/// The orb's state precedence, in one place: a held draft outranks an unread
/// reply, and a connection that is gone outranks both.
({bool filled, bool offline, bool draftDot}) botOrbStyle({
  required bool unread,
  required bool offline,
  required bool draft,
}) =>
    (
      filled: unread && !draft && !offline,
      offline: offline,
      draftDot: draft && !offline,
    );
