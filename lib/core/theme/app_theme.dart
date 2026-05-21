import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design System: JAYANUSA Neon-Glass
/// Style: Glassmorphism + Cyberpunk-lite
/// Font: Plus Jakarta Sans (via Google Fonts fallback ke system sans-serif)
class AppColors {
  // ── Background & Surface ──────────────────────────────────────────────────
  static const Color background         = Color(0xFF121221); // Midnight Indigo
  static const Color surface            = Color(0xFF121221);
  static const Color surfaceContainerLowest = Color(0xFF0D0D1B);
  static const Color surfaceContainerLow    = Color(0xFF1A1A29);
  static const Color surfaceContainer       = Color(0xFF1E1E2E);
  static const Color surfaceContainerHigh   = Color(0xFF292839);
  static const Color surfaceContainerHighest= Color(0xFF343344);
  static const Color surfaceVariant         = Color(0xFF343344);
  static const Color surfaceBright          = Color(0xFF383848);

  // ── Primary (Lavender Blue) ───────────────────────────────────────────────
  static const Color primary            = Color(0xFFE2DFFF);
  static const Color primaryFixed       = Color(0xFFE3DFFF);
  static const Color primaryFixedDim    = Color(0xFFC3C0FF);
  static const Color primaryContainer   = Color(0xFFC3C0FF);
  static const Color onPrimary          = Color(0xFF2C2A5E);
  static const Color onPrimaryContainer = Color(0xFF4E4C83);

  // ── Secondary (Ice Blue) ─────────────────────────────────────────────────
  static const Color secondary          = Color(0xFFACC7FF);
  static const Color secondaryContainer = Color(0xFF2A4676);
  static const Color onSecondary        = Color(0xFF0F2F5E);
  static const Color onSecondaryContainer = Color(0xFF9AB5EC);

  // ── Tertiary / Neon Cyan (Action Color) ──────────────────────────────────
  static const Color tertiary           = Color(0xFF54FAED);
  static const Color tertiaryAlt        = Color(0xFF24DDD1);
  static const Color tertiaryContainer  = Color(0xFF23DDD1);
  static const Color onTertiary         = Color(0xFF003733);
  static const Color onTertiaryContainer= Color(0xFF005D57);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color onBackground       = Color(0xFFE3E0F6);
  static const Color onSurface          = Color(0xFFE3E0F6);
  static const Color onSurfaceVariant   = Color(0xFFC8C5D0);
  static const Color outline            = Color(0xFF928F9A);
  static const Color outlineVariant     = Color(0xFF47464F);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color error              = Color(0xFFFFB4AB);
  static const Color errorContainer     = Color(0xFF93000A);
  static const Color onError            = Color(0xFF690005);
  static const Color success            = Color(0xFF54FAED); // pakai tertiary
  static const Color warning            = Color(0xFFF59E0B);

  // ── Aspiration Status ─────────────────────────────────────────────────────
  static const Color statusDikirim      = Color(0xFFACC7FF); // secondary
  static const Color statusDiproses     = Color(0xFFF59E0B); // warning
  static const Color statusSelesai      = Color(0xFF54FAED); // tertiary

  // ── Registration Status ───────────────────────────────────────────────────
  static const Color statusPending      = Color(0xFFF59E0B);
  static const Color statusApproved     = Color(0xFF54FAED);
  static const Color statusRejected     = Color(0xFFFFB4AB);
  static const Color statusCompleted    = Color(0xFFC3C0FF);

  // ── Glass System ──────────────────────────────────────────────────────────
  static const Color glassBorder        = Color(0x1AC3C0FF); // rgba(195,192,255,0.1)
  static const Color glassSurface       = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)

  // ── Glow ──────────────────────────────────────────────────────────────────
  static const Color glowCyan           = Color(0x8024DDD1); // rgba(36,221,209,0.5)
  static const Color glowIndigo         = Color(0x4D3B2FC9); // rgba(59,47,201,0.3)

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B2FC9), Color(0xFF121221)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A29), Color(0xFF1E1E2E)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFC3C0FF), Color(0xFF54FAED)],
  );

  // ── Backward compat aliases ───────────────────────────────────────────────
  static const Color textPrimary   = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textHint      = outline;
  static const Color textWhite     = onBackground;
  static const Color border        = glassBorder;
  static const Color divider       = surfaceContainerHigh;
  static const Color info          = secondary;
}

class AppTheme {
  static const String _font = 'PlusJakartaSans';

  static ThemeData get darkTheme {
    // Status bar icons putih di atas background gelap
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D1B),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _font,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: -0.01,
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),

      // ── ElevatedButton (Neon Cyan CTA) ────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tertiary,
          foregroundColor: AppColors.onTertiary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: _font,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tertiary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.tertiaryAlt, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: _font,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tertiaryAlt, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: _font,
          fontSize: 14,
          color: AppColors.outline,
        ),
        labelStyle: const TextStyle(
          fontFamily: _font,
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: _font,
          fontSize: 12,
          color: AppColors.tertiaryAlt,
        ),
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIconColor: AppColors.onSurfaceVariant,
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xCC0D0D1B),
        selectedItemColor: AppColors.tertiary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: _font,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: _font,
          fontSize: 10,
          letterSpacing: 0.1,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: const Color(0x1A54FAED),
        labelStyle: const TextStyle(
          fontFamily: _font,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: 1,
      ),

      // ── Text Theme ────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.02),
        headlineLarge: TextStyle(fontFamily: _font, fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.02),
        headlineMedium:TextStyle(fontFamily: _font, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.02),
        headlineSmall: TextStyle(fontFamily: _font, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: -0.01),
        titleLarge:    TextStyle(fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface, letterSpacing: 0),
        titleMedium:   TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleSmall:    TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        bodyLarge:     TextStyle(fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        bodyMedium:    TextStyle(fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        bodySmall:     TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        labelLarge:    TextStyle(fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, letterSpacing: 0.05),
        labelMedium:   TextStyle(fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant, letterSpacing: 0.05),
        labelSmall:    TextStyle(fontFamily: _font, fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing: 0.1),
      ),
    );
  }

  // Backward compat — screens yang belum diupdate masih bisa pakai ini
  static ThemeData get lightTheme => darkTheme;
}
