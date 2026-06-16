import 'package:flutter/material.dart';

// ============================================================================
// Spacing tokens
// ============================================================================
const kSpacerHeight8 = SizedBox(height: 8);
const kSpacerHeight12 = SizedBox(height: 12);
const kSpacerHeight16 = SizedBox(height: 16);
const kSpacerHeight24 = SizedBox(height: 24);
const kSpacerHeight32 = SizedBox(height: 32);

const kSpacerWidth8 = SizedBox(width: 8);
const kSpacerWidth12 = SizedBox(width: 12);
const kSpacerWidth16 = SizedBox(width: 16);
const kSpacerWidth32 = SizedBox(width: 32);

// ============================================================================
// Radii
// ============================================================================
class AppRadii {
  static const double card = 20;
  static const double button = 16;
  static const double input = 14;
  static const double pill = 999;

  /// Large radius for the overlay sheet that rides over a hero image.
  static const double sheet = 28;

  /// Radius for hero/media surfaces.
  static const double hero = 28;
}

// ============================================================================
// Moment type colors (bad / romantic / good)
// ============================================================================
class MomentColors {
  const MomentColors({
    required this.bg,
    required this.accent,
    required this.onBg,
  });

  final Color bg;
  final Color accent;
  final Color onBg;
}

// ============================================================================
// Semantic palette — "romantic modern" identity, light + dark
// ============================================================================
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.secondaryAccent,
    required this.onPrimary,
    required this.primarySoft,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.gradient,
    required this.danger,
    required this.bad,
    required this.romantic,
    required this.good,
  });

  final Brightness brightness;
  final Color primary;

  /// Gradient companion to [primary] (peach/coral) for hero fills.
  final Color secondaryAccent;
  final Color onPrimary;
  final Color primarySoft;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color outline;
  final List<Color> gradient;
  final Color danger;
  final MomentColors bad;
  final MomentColors romantic;
  final MomentColors good;

  bool get isDark => brightness == Brightness.dark;

  /// Returns a copy of this palette re-themed around [accent] (used to let a
  /// timeline carry its own accent color).
  AppPalette withAccent(Color accent) {
    final onAccent = accent.computeLuminance() > 0.55 ? const Color(0xFF2B2330) : Colors.white;
    return AppPalette(
      brightness: brightness,
      primary: accent,
      secondaryAccent: Color.lerp(accent, Colors.white, 0.22) ?? accent,
      onPrimary: onAccent,
      primarySoft: accent.withValues(alpha: isDark ? 0.26 : 0.14),
      background: background,
      surface: surface,
      surfaceAlt: surfaceAlt,
      onSurface: onSurface,
      onSurfaceMuted: onSurfaceMuted,
      outline: outline,
      gradient: gradient,
      danger: danger,
      bad: bad,
      romantic: romantic,
      good: good,
    );
  }

  static const light = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFFFF6B7A),
    secondaryAccent: Color(0xFFFF9E7D),
    onPrimary: Colors.white,
    primarySoft: Color(0xFFFFE4E7),
    background: Color(0xFFFFF8F7),
    surface: Colors.white,
    surfaceAlt: Color(0xFFF5EBED),
    onSurface: Color(0xFF2B2330),
    onSurfaceMuted: Color(0xFF8C8594),
    outline: Color(0xFFEFE0E2),
    gradient: [Color(0xFFFFDDE1), Color(0xFFFFF8F7)],
    danger: Color(0xFFE5484D),
    bad: MomentColors(bg: Color(0xFFFFE2E2), accent: Color(0xFFE5616B), onBg: Color(0xFF7A2E33)),
    romantic: MomentColors(bg: Color(0xFFF6E2FB), accent: Color(0xFFB451D6), onBg: Color(0xFF5B2E6B)),
    good: MomentColors(bg: Color(0xFFDFF5E8), accent: Color(0xFF2E9E68), onBg: Color(0xFF1F5E40)),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFFFF7E8B),
    secondaryAccent: Color(0xFFFF9E8C),
    onPrimary: Colors.white,
    primarySoft: Color(0xFF3A232E),
    // Deep, neutral-cool base — no brown tint. Cards sit ABOVE the background.
    background: Color(0xFF120F18),
    surface: Color(0xFF221E2B),
    surfaceAlt: Color(0xFF2C2738),
    onSurface: Color(0xFFF4F0F7),
    onSurfaceMuted: Color(0xFFA89FB2),
    outline: Color(0xFF39323F),
    gradient: [Color(0xFF1B1626), Color(0xFF120F18)],
    danger: Color(0xFFFF6B6B),
    bad: MomentColors(bg: Color(0xFF3A2326), accent: Color(0xFFFF8A93), onBg: Color(0xFFFFD9DC)),
    romantic: MomentColors(bg: Color(0xFF2F2238), accent: Color(0xFFD9A0F0), onBg: Color(0xFFEAD2F7)),
    good: MomentColors(bg: Color(0xFF1E3328), accent: Color(0xFF6FD3A0), onBg: Color(0xFFCDEFDC)),
  );
}

/// Provides an optional accent color override to a subtree (e.g. a timeline
/// with its own color). Widgets read it transparently via `context.palette`.
class AppAccent extends InheritedWidget {
  const AppAccent({super.key, required this.color, required super.child});

  final Color? color;

  static Color? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppAccent>()?.color;

  @override
  bool updateShouldNotify(AppAccent oldWidget) => oldWidget.color != color;
}

/// Resolves the active [AppPalette] from the current [Theme] brightness,
/// re-themed around the nearest [AppAccent] override if present.
extension PaletteX on BuildContext {
  AppPalette get palette {
    final base = Theme.of(this).brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
    final accent = AppAccent.of(this);
    return accent == null ? base : base.withAccent(accent);
  }
}

/// Re-themes its subtree around [accentColor] — both the [AppPalette]
/// (`context.palette`) and the Material [ThemeData] (buttons, progress, etc.).
/// No-op when [accentColor] is null.
class AccentScope extends StatelessWidget {
  const AccentScope({super.key, required this.accentColor, required this.child});

  final int? accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final value = accentColor;
    if (value == null) return child;

    final accent = Color(value);
    final onAccent = accent.computeLuminance() > 0.55 ? const Color(0xFF2B2330) : Colors.white;
    final base = Theme.of(context);

    final themed = base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: accent, onPrimary: onAccent),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: base.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? accent.withValues(alpha: 0.35) : accent,
          ),
          foregroundColor: WidgetStatePropertyAll(onAccent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: base.outlinedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStatePropertyAll(accent),
          foregroundColor: WidgetStatePropertyAll(onAccent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: base.textButtonTheme.style?.copyWith(
          foregroundColor: WidgetStatePropertyAll(accent),
        ),
      ),
      progressIndicatorTheme: base.progressIndicatorTheme.copyWith(color: accent),
    );

    return AppAccent(color: accent, child: Theme(data: themed, child: child));
  }
}

// ============================================================================
// Soft shadows
// ============================================================================
class AppShadows {
  static List<BoxShadow> soft(BuildContext context) {
    final isDark = context.palette.isDark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : const Color(0xFFFF6B7A).withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ];
  }

  /// Stronger, upward shadow for floating bars/buttons (sticky CTA).
  static List<BoxShadow> lift(BuildContext context) {
    final isDark = context.palette.isDark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.55)
            : const Color(0xFFFF6B7A).withValues(alpha: 0.18),
        blurRadius: 28,
        offset: const Offset(0, -6),
      ),
    ];
  }
}

// ============================================================================
// Brand colors (kept as const for use in enums / const contexts)
// ============================================================================
class AppColors {
  static const Color primary = Color(0xFFFF6B7A);
  static const Color timeLineColor = primary; // legacy alias
  static const Color secondary = Color(0xFFFF9AA5);

  // Legacy moment-type hues (the live palette is in AppPalette).
  static const Color badColor = Color(0xFFE5616B);
  static const Color romanticColor = Color(0xFFB451D6);
  static const Color goodColor = Color(0xFF2E9E68);

  static const List<Color> instagramGradient = [
    Color(0xFFBF16EA),
    Color(0xFFD00A0A),
    Color(0xFFCBA622),
  ];
}

// ============================================================================
// Reusable decorations
// ============================================================================
class AppThemes {
  static final BoxDecoration circularBorder = BoxDecoration(
    border: Border.all(color: Colors.transparent),
    color: Colors.white,
    shape: BoxShape.circle,
  );

  static final BoxDecoration roundedBorder = BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(AppRadii.input)),
  );

  static const BoxDecoration coloredBorder = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: AppColors.instagramGradient,
    ),
  );
}

// ============================================================================
// Strings / Assets
// ============================================================================
class Assets {
  static final Widget iconAddMoments = Image.asset('assets/images/icon_add_moments.png');
}

class Strings {
  static const appName = 'Nossos Momentos';
}

// ============================================================================
// ThemeData builders — light + dark
// ============================================================================
class AppTheme {
  static ThemeData get light => _build(AppPalette.light);
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: p.brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      surface: p.surface,
      onSurface: p.onSurface,
      surfaceContainerHighest: p.surfaceAlt,
      outline: p.outline,
      error: p.danger,
    );

    final textTheme = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: p.onSurface),
      dividerTheme: DividerThemeData(color: p.outline, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: p.onSurface,
        iconTheme: IconThemeData(color: p.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: p.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.primary.withValues(alpha: 0.35),
          disabledForegroundColor: p.onPrimary.withValues(alpha: 0.8),
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.onSurfaceMuted),
        prefixIconColor: p.onSurfaceMuted,
        suffixIconColor: p.onSurfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: p.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: p.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          borderSide: BorderSide(color: p.danger, width: 1.6),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.isDark ? p.surfaceAlt : p.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: p.isDark ? p.onSurface : p.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );
  }

  static TextTheme _textTheme(AppPalette p) {
    final base = p.onSurface;
    final muted = p.onSurfaceMuted;
    return TextTheme(
      displaySmall: TextStyle(fontWeight: FontWeight.w800, fontSize: 34, height: 1.1, letterSpacing: -0.5, color: base),
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 30, height: 1.15, letterSpacing: -0.5, color: base),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, height: 1.2, letterSpacing: -0.3, color: base),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, height: 1.2, color: base),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: -0.2, color: base),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: base),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: base),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, height: 1.45, color: base),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 1.45, color: base),
      bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 1.4, color: muted),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: base),
    );
  }
}
