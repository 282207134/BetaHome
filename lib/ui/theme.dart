import 'package:flutter/material.dart';

const blue = Color(0xFF3266FF);
const muted = Color(0xFF7A8499);
const pale = Color(0xFFF5F7FE);

ThemeData appTheme(bool dark) {
  final bg = dark ? const Color(0xFF111111) : Colors.white;
  final surface = dark ? const Color(0xFF1A1A1A) : pale;
  final ink = dark ? Colors.white : const Color(0xFF080808);
  final border = dark ? const Color(0xFF262626) : const Color(0xFFEEF2FC);
  final theme = ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    fontFamily: 'Urbanist',
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: blue,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: blue,
      surface: bg,
      onSurface: ink,
      surfaceContainerHighest: surface,
      outlineVariant: border,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
    dividerTheme: DividerThemeData(color: border, space: 32, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: blue),
      ),
      hintStyle: const TextStyle(color: muted, fontSize: 14),
      prefixIconColor: muted,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        minimumSize: const Size(double.infinity, 54),
        side: BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: blue),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? blue : border,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
  return theme.copyWith(
    textTheme: theme.textTheme
        .apply(bodyColor: ink, displayColor: ink)
        .copyWith(
          bodyMedium: TextStyle(
            fontFamily: 'Urbanist',
            color: ink,
            fontSize: 15,
            height: 1.35,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Urbanist',
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Urbanist',
            color: ink,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
  );
}
