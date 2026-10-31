import 'package:flutter/material.dart';

/// Shoku — "Kitchen Ticket".
///
/// Paper and ink, one hot accent, monospace for anything you measure.
/// Brutalism survives in exactly two places: the primary CTA and the live
/// cooking timer. Everywhere else: hairlines and surface tone.
@immutable
class ShokuColors {
  final Color canvas;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkMuted;
  final Color hairline;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color reward;
  final Color ready;
  final Color danger;

  const ShokuColors({
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkMuted,
    required this.hairline,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.reward,
    required this.ready,
    required this.danger,
  });

  static const light = ShokuColors(
    canvas: Color(0xFFF7F3EB),
    surface: Color(0xFFFFFDF9),
    surfaceAlt: Color(0xFFEFE9DD),
    ink: Color(0xFF1C1614),
    inkMuted: Color(0xFF6E5F58),
    hairline: Color(0xFFDED5C8),
    accent: Color(0xFF9E281E),
    onAccent: Color(0xFFFFF9F5),
    accentSoft: Color(0xFFF5DFD6),
    reward: Color(0xFFB87314),
    ready: Color(0xFF28664B),
    danger: Color(0xFFB42318),
  );

  static const dark = ShokuColors(
    canvas: Color(0xFF141110),
    surface: Color(0xFF1E1A18),
    surfaceAlt: Color(0xFF292320),
    ink: Color(0xFFF5EFE6),
    inkMuted: Color(0xFFA6988E),
    hairline: Color(0xFF332B27),
    accent: Color(0xFFC8372B),
    onAccent: Color(0xFFFFF9F5),
    accentSoft: Color(0xFF381D1A),
    reward: Color(0xFFE09F3E),
    ready: Color(0xFF4EA882),
    danger: Color(0xFFE5484D),
  );
}

@immutable
class ShokuTokens extends ThemeExtension<ShokuTokens> {
  final ShokuColors colors;
  final bool isDark;

  const ShokuTokens({required this.colors, required this.isDark});

  @override
  ShokuTokens copyWith({ShokuColors? colors, bool? isDark}) =>
      ShokuTokens(colors: colors ?? this.colors, isDark: isDark ?? this.isDark);

  @override
  ShokuTokens lerp(ThemeExtension<ShokuTokens>? other, double t) {
    if (other is! ShokuTokens) return this;
    return t < 0.5 ? this : other;
  }
}

class ShokuSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  const ShokuSpace._();
}

class ShokuRadius {
  static const double chip = 6;
  static const double media = 8;
  static const double card = 12;
  static const double sheet = 20;
  static const double pill = 999;

  const ShokuRadius._();
}

class ShokuStroke {
  static const double hairline = 1;
  static const double brutal = 1.5;
  static const Offset brutalShadow = Offset(0, 2);

  const ShokuStroke._();
}

/// Type system: Fraunces for editorial voice, Plus Jakarta Sans for reading,
/// JetBrains Mono for anything numeric.
class ShokuType {
  static TextStyle get display => const TextStyle(fontFamily: 'ShokuSerif', 
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.8,
      );

  static TextStyle get h1 => const TextStyle(fontFamily: 'ShokuSerif', 
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.18,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => const TextStyle(fontFamily: 'ShokuSerif', 
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.2,
      );

  static TextStyle get title => const TextStyle(fontFamily: 'ShokuSans', 
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.1,
      );

  static TextStyle get body => const TextStyle(fontFamily: 'ShokuSans', 
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  static TextStyle get bodySmall => const TextStyle(fontFamily: 'ShokuSans', 
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get label => const TextStyle(fontFamily: 'ShokuMono', 
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 1.2,
      );

  static TextStyle get stat => const TextStyle(fontFamily: 'ShokuMono', 
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -0.4,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get statHero => const TextStyle(fontFamily: 'ShokuMono', 
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -0.6,
        fontFeatures: [FontFeature.tabularFigures()],
      );

  static TextStyle get quote => const TextStyle(fontFamily: 'ShokuSerif', 
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.45,
      );

  const ShokuType._();
}


/// Six gradients, each with exactly one home. Everything else stays flat:
/// a gradient on a list row reads as venetian-blind striping.
class ShokuGradients {
  /// Primary CTA. Gives the brutalist button ink-stamp density.
  static const crimsonPress = LinearGradient(
    begin: Alignment(-0.3, -1.0),
    end: Alignment(0.3, 1.0),
    colors: [Color(0xFFB33227), Color(0xFF9E281E), Color(0xFF7D1D15)],
    stops: [0.0, 0.55, 1.0],
  );

  /// The one place the floral blush is allowed to be a field: the
  /// "just extracted / saved" ticket header.
  static const blushFolio = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFDF9), Color(0xFFF9EBE4), Color(0xFFF2D3C6)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Empty-state atmosphere. Melts into canvas, so it needs no border.
  static const warmVellum = RadialGradient(
    center: Alignment(0.0, -0.35),
    radius: 0.95,
    colors: [Color(0xFFF5DFD6), Color(0xFFF2E9DC), Color(0xFFF7F3EB)],
    stops: [0.0, 0.45, 1.0],
  );

  /// Featured card: top-lit paper curvature, not a shadow.
  static const ticketSheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFDF9), Color(0xFFF6EFE4)],
  );

  /// Dark-mode hero glow. Keeps dark mode from feeling like a dev tool.
  static const emberCellar = RadialGradient(
    center: Alignment(0.6, -0.8),
    radius: 1.1,
    colors: [Color(0xFF2E1916), Color(0xFF1C1614), Color(0xFF141110)],
    stops: [0.0, 0.50, 1.0],
  );

  /// Any photo with text over it. Never pure black — it turns food grey.
  static const photoScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x001C1614), Color(0x661C1614), Color(0xD91C1614)],
    stops: [0.0, 0.65, 1.0],
  );

  const ShokuGradients._();
}

class ShokuTheme {
  static ThemeData light() => _build(ShokuColors.light, false);

  static ThemeData dark() => _build(ShokuColors.dark, true);

  static ThemeData _build(ShokuColors c, bool isDark) {
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: c.canvas,
      canvasColor: c.canvas,
      dividerColor: c.hairline,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.accent,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).copyWith(
        primary: c.accent,
        onPrimary: isDark ? const Color(0xFF1A0D09) : Colors.white,
        surface: c.surface,
        onSurface: c.ink,
        error: c.danger,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: c.ink,
        displayColor: c.ink,
        fontFamily: const TextStyle(fontFamily: 'ShokuSans', ).fontFamily,
      ),
      extensions: <ThemeExtension<dynamic>>[
        ShokuTokens(colors: c, isDark: isDark),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: c.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.canvas,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(ShokuRadius.sheet)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.ink,
        contentTextStyle: ShokuType.bodySmall.copyWith(color: c.canvas),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  const ShokuTheme._();
}

extension ShokuContext on BuildContext {
  ShokuTokens get tokens => Theme.of(this).extension<ShokuTokens>()!;
  ShokuColors get colors => tokens.colors;
  bool get isDark => tokens.isDark;
  TextTheme get text => Theme.of(this).textTheme;
}
