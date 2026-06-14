// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:to_best/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark({Color accent = AppColors.accent}) {
    const bg      = AppColors.darkBg;
    const bgCard  = AppColors.darkBgCard;
    const text1   = AppColors.darkText1;
    const text2   = AppColors.darkText2;
    const border  = AppColors.darkBorder;

    return ThemeData(
      useMaterial3:            true,
      brightness:              Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary:   accent,
        secondary: accent,
        surface:   bgCard,
        error:     AppColors.err,
        onPrimary: Colors.white,
        onSurface: text1,
      ),
      cardTheme: CardTheme(
        color:     bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.darkBgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.err),
        ),
        labelStyle: const TextStyle(color: text2),
        hintStyle:  const TextStyle(color: text2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700,
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCard,
        foregroundColor: text1,
        elevation:       0,
        centerTitle:     true,
        titleTextStyle:  TextStyle(
          color: text1, fontSize: 17, fontWeight: FontWeight.w700,
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgCard,
        indicatorColor:  accent.withOpacity(0.15),
        labelTextStyle:  WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent, size: 24);
          }
          return const IconThemeData(color: text2, size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(color: border, space: 1),
      textTheme: const TextTheme(
        bodyLarge:   TextStyle(color: text1, fontSize: 15),
        bodyMedium:  TextStyle(color: text1, fontSize: 13),
        bodySmall:   TextStyle(color: text2, fontSize: 11),
        titleLarge:  TextStyle(color: text1, fontSize: 20, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: text1, fontSize: 16, fontWeight: FontWeight.w700),
        titleSmall:  TextStyle(color: text1, fontSize: 14, fontWeight: FontWeight.w600),
        labelSmall:  TextStyle(color: text2, fontSize: 10),
        headlineSmall: TextStyle(color: text1, fontSize: 22, fontWeight: FontWeight.w900),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkBgInput,
        selectedColor:   accent.withOpacity(0.2),
        labelStyle:      const TextStyle(color: text1, fontSize: 12),
        side:            const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCard,
        contentTextStyle: const TextStyle(color: text1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: text1, fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : text2,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withOpacity(0.4)
              : AppColors.darkBgInput,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: border,
      ),
      tabBarTheme: TabBarTheme(
        labelColor:         accent,
        unselectedLabelColor: text2,
        indicatorColor:     accent,
        dividerColor:       border,
        labelStyle:  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
      ),
    );
  }

  static ThemeData light({Color accent = AppColors.accent}) {
    const bg      = AppColors.lightBg;
    const bgCard  = AppColors.lightBgCard;
    const text1   = AppColors.lightText1;
    const text2   = AppColors.lightText2;
    const border  = AppColors.lightBorder;

    return ThemeData(
      useMaterial3:            true,
      brightness:              Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.light(
        primary:   accent,
        secondary: accent,
        surface:   bgCard,
        error:     AppColors.err,
        onPrimary: Colors.white,
        onSurface: text1,
      ),
      cardTheme: CardTheme(
        color:     bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.lightBgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.err),
        ),
        labelStyle: const TextStyle(color: text2),
        hintStyle:  const TextStyle(color: text2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700,
          ),
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCard,
        foregroundColor: text1,
        elevation:       0,
        centerTitle:     true,
        titleTextStyle:  TextStyle(
          color: text1, fontSize: 17, fontWeight: FontWeight.w700,
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgCard,
        indicatorColor:  accent.withOpacity(0.15),
        labelTextStyle:  WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent, size: 24);
          }
          return const IconThemeData(color: text2, size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(color: border, space: 1),
      textTheme: const TextTheme(
        bodyLarge:   TextStyle(color: text1, fontSize: 15),
        bodyMedium:  TextStyle(color: text1, fontSize: 13),
        bodySmall:   TextStyle(color: text2, fontSize: 11),
        titleLarge:  TextStyle(color: text1, fontSize: 20, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: text1, fontSize: 16, fontWeight: FontWeight.w700),
        titleSmall:  TextStyle(color: text1, fontSize: 14, fontWeight: FontWeight.w600),
        labelSmall:  TextStyle(color: text2, fontSize: 10),
        headlineSmall: TextStyle(color: text1, fontSize: 22, fontWeight: FontWeight.w900),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightBgInput,
        selectedColor:   accent.withOpacity(0.15),
        labelStyle:      const TextStyle(color: text1, fontSize: 12),
        side:            const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCard,
        contentTextStyle: const TextStyle(color: text1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: text1, fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : text2,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? accent.withOpacity(0.4)
              : AppColors.lightBgInput,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: border,
      ),
      tabBarTheme: TabBarTheme(
        labelColor:           accent,
        unselectedLabelColor: text2,
        indicatorColor:       accent,
        dividerColor:         border,
        labelStyle:  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
      ),
    );
  }
}
