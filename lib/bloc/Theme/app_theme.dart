import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  static final AppTheme instance = AppTheme._();

  static const String _fontFamily = 'Delius';

  // ── Backgrounds ──────────────────────────────────────────
  static const Color backgroundDeep = Color(0xFF000000);
  static const Color backgroundMid = Color(0xFF0A0A0A);
  static const Color surfaceBase = Color(0xFF111111);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color surfaceBorder = Color(0xFF2A2A2A);

  // ── Gold Palette ──────────────────────────────────────────
  static const Color primary = Color(0xFFD4AF37);
  static const Color primaryBright = Color(0xFFE8C847);
  static const Color primaryDim = Color(0xFF9E8229);
  static const Color primaryGlow = Color(0x33D4AF37);
  static const Color primarySoft = Color(0x1AD4AF37);
  static const Color goldDark = Color(0xFF8B6914);

  // ── Accent ────────────────────────────────────────────────
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentSoft = Color(0x1AD4AF37);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF4B5563);

  // ── Status ────────────────────────────────────────────────
  static const Color statusSuccess = Color(0xFF22C55E);
  static const Color statusWarning = Color(0xFFD4AF37);
  static const Color statusDanger = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryBright],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDeep, backgroundMid],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBright, primary, goldDark],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceBase, surfaceElevated],
  );

  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,

    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDeep,

    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.black,
      primaryContainer: goldDark,
      onPrimaryContainer: textPrimary,
      secondary: primaryBright,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF1C1608),
      onSecondaryContainer: primary,
      tertiary: statusInfo,
      onTertiary: Colors.white,
      error: statusDanger,
      onError: Colors.white,
      surface: surfaceBase,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceElevated,
      surfaceContainerHigh: surfaceElevated,
      surfaceContainer: surfaceBase,
      surfaceContainerLow: backgroundMid,
      surfaceContainerLowest: backgroundDeep,
      onSurfaceVariant: textSecondary,
      outline: surfaceBorder,
      outlineVariant: Color(0xFF1F1F1F),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: textPrimary,
      onInverseSurface: backgroundDeep,
      inversePrimary: primaryDim,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.3),
      iconTheme: IconThemeData(color: textPrimary),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceBase,
      indicatorColor: primaryGlow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 22);
        }
        return const IconThemeData(color: textMuted, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: primary);
        }
        return const TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w400, color: textMuted);
      }),
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: surfaceBase,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: surfaceBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    dividerTheme: const DividerThemeData(color: surfaceBorder, thickness: 1, space: 1),

    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: primary,
      textColor: textPrimary,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),

    iconTheme: const IconThemeData(color: primary, size: 22),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        color: textPrimary,
        fontSize: 56,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.0,
        height: 1.0,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        color: textPrimary,
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      headlineLarge: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      headlineSmall: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleLarge: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: _fontFamily, color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 15, height: 1.6, letterSpacing: 0.1),
      bodyMedium: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 13, height: 1.5, letterSpacing: 0.2),
      bodySmall: TextStyle(fontFamily: _fontFamily, color: textSecondary, fontSize: 11, height: 1.4, letterSpacing: 0.3),
      labelLarge: TextStyle(fontFamily: _fontFamily, color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: TextStyle(fontFamily: _fontFamily, color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.3),
      labelSmall: TextStyle(fontFamily: _fontFamily, color: textMuted, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.black,
      elevation: 8,
      shape: CircleBorder(),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceElevated,
      selectedColor: primaryGlow,
      disabledColor: surfaceBorder,
      labelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary),
      side: const BorderSide(color: surfaceBorder, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceBase,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: surfaceBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: surfaceBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: statusDanger, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: statusDanger, width: 2),
      ),
      labelStyle: const TextStyle(fontFamily: _fontFamily, color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(fontFamily: _fontFamily, color: textMuted, fontSize: 14),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: surfaceBorder, width: 1),
      ),
      titleTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      contentTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13, color: textSecondary, height: 1.5),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceBase,
      modalBackgroundColor: surfaceBase,
      elevation: 0,
      modalElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary : textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primaryGlow : surfaceBorder),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary, linearTrackColor: surfaceBorder, circularTrackColor: surfaceBorder),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceElevated,
      contentTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13, color: textPrimary),
      actionTextColor: primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: surfaceBorder),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),

    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
    splashColor: primaryGlow,
    highlightColor: Colors.transparent,
    hoverColor: accentSoft,
  );
}

var lightThemeData = AppTheme.theme;
var darkThemeData = AppTheme.theme;
