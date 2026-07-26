import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Builds the app's ThemeData for light and dark modes.
/// Source of truth: docs/architecture/DESIGN_SYSTEM.md
abstract final class AppTheme {
  static ThemeData light({String fontFamily = 'Inter'}) {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
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
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.outlineLight,
      outlineVariant: Color(0xFFCAD0DC),
      shadow: Color(0x1A0F5EFF),
      scrim: Color(0x800A0F1E),
      inverseSurface: AppColors.surfaceDark,
      onInverseSurface: AppColors.textPrimaryDark,
      inversePrimary: Color(0xFFADC6FF),
    );

    return _buildTheme(colorScheme, fontFamily, Brightness.light);
  }

  static ThemeData dark({String fontFamily = 'Inter'}) {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: Color(0xFF1A3A8F),
      onPrimaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: Color(0xFF004D32),
      onSecondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: Color(0xFF3A0099),
      onTertiaryContainer: AppColors.tertiaryContainer,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.outlineDark,
      outlineVariant: Color(0xFF3A4060),
      shadow: Color(0x330F5EFF),
      scrim: Color(0xCC0A0F1E),
      inverseSurface: AppColors.surfaceLight,
      onInverseSurface: AppColors.textPrimaryLight,
      inversePrimary: AppColors.primary,
    );

    return _buildTheme(colorScheme, fontFamily, Brightness.dark);
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    String fontFamily,
    Brightness brightness,
  ) {
    final textTheme = AppTypography.buildTextTheme(fontFamily);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: AppColors.primaryContainer.withValues(alpha: isDark ? 0.3 : 1.0),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(color: AppColors.primary);
          }
          return textTheme.labelSmall?.copyWith(
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          );
        }),
        elevation: 4,
        height: AppSpacingConst.tabBarHeight,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, 44),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
      ),

      cardTheme: CardThemeData(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        margin: EdgeInsets.zero,
      ),

      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelSmall,
        side: BorderSide.none,
      ),

      dividerTheme: DividerThemeData(
        color: (isDark ? AppColors.outlineDark : AppColors.outlineLight)
            .withValues(alpha: 0.2),
        thickness: 1,
        space: 0,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
        showDragHandle: true,
        dragHandleSize: Size(36, 4),
        elevation: 5,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.textPrimaryLight,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.surfaceLight,
        ),
      ),

      listTileTheme: ListTileThemeData(
        minVerticalPadding: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        style: ListTileStyle.list,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.onPrimary : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.secondary
              : (isDark ? AppColors.outlineDark : AppColors.outlineLight);
        }),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// Convenience alias so theme file can reference spacing without importing both.
abstract final class AppSpacingConst {
  static const double tabBarHeight = 64.0;
}
