import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fetch App Theme Configuration
/// Material You (Material 3) with dynamic theming support
class AppTheme {
  // Primary brand colors
  static const Color primarySeed = Color(0xFF6366F1); // Indigo
  static const Color secondarySeed = Color(0xFF8B5CF6); // Purple
  static const Color tertiarySeed = Color(0xFF06B6D4); // Cyan

  // Semantic colors
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Confidence score colors
  static const Color confidenceHigh = Color(0xFF22C55E); // 80-100
  static const Color confidenceMedium = Color(0xFFF59E0B); // 50-79
  static const Color confidenceLow = Color(0xFFEF4444); // 0-49

  static Color getConfidenceColor(int score) {
    if (score >= 80) return confidenceHigh;
    if (score >= 50) return confidenceMedium;
    return confidenceLow;
  }

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
      secondary: secondarySeed,
      tertiary: tertiarySeed,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
      secondary: secondarySeed,
      tertiary: tertiarySeed,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(colorScheme: colorScheme).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surfaceContainerHighest,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: textTheme.labelMedium,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: colorScheme.surface,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        showDragHandle: true,
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelLarge,
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: colorScheme.surface,
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
        circularTrackColor: colorScheme.primaryContainer,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// Custom gradient definitions
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondary = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient error = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glassmorphism(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ]
          : [
              Colors.white.withValues(alpha: 0.7),
              Colors.white.withValues(alpha: 0.3),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Custom shadows
class AppShadows {
  static List<BoxShadow> small(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> medium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> large(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.16),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ];
  }
}

/// Animation durations
class AppDurations {
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slowest = Duration(milliseconds: 800);
}

/// Animation curves
class AppCurves {
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve sharp = Curves.easeInOutQuart;
}
