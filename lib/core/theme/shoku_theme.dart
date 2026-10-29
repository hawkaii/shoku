import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    required this.reward,
    required this.ready,
    required this.danger,
  });

  static const light = ShokuColors(
    canvas: Color(0xFFF5F1E8),
    surface: Color(0xFFFFFDF7),
    surfaceAlt: Color(0xFFEFE9DD),
    ink: Color(0xFF1A1714),
    inkMuted: Color(0xFF6B6459),
    hairline: Color(0xFFDCD4C6),
    accent: Color(0xFFC8381A),
    reward: Color(0xFFB87D14),
    ready: Color(0xFF2D6A4F),
    danger: Color(0xFFA33C31),
  );

  static const dark = ShokuColors(
    canvas: Color(0xFF12100E),
    surface: Color(0xFF1C1916),
    surfaceAlt: Color(0xFF26221E),
    ink: Color(0xFFF4EFE6),
    inkMuted: Color(0xFFA69F94),
    hairline: Color(0xFF2E2924),
    accent: Color(0xFFE9664A),
    reward: Color(0xFFE5A93C),
    ready: Color(0xFF7FA07F),
    danger: Color(0xFFEF8E7C),
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
  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.8,
      );

  static TextStyle get h1 => GoogleFonts.fraunces(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.18,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.fraunces(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.2,
      );

  static TextStyle get title => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.1,
      );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get label => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 1.2,
      );

  static TextStyle get stat => GoogleFonts.jetBrainsMono(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -0.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get statHero => GoogleFonts.jetBrainsMono(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -0.6,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get quote => GoogleFonts.fraunces(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        height: 1.45,
      );

  const ShokuType._();
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
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
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
