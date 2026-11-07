import 'package:flutter/material.dart';

const ink = Color(0xff111a24),
    accent = Color(0xff335dff),
    paper = Color(0xffedf1f4),
    muted = Color(0xff4d5b6d),
    rule = Color(0xffcad4df);
ThemeData machineTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: accent, surface: paper),
  scaffoldBackgroundColor: paper,
  fontFamily: 'SpaceGrotesk',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontVariations: [FontVariation('wght', 450)]),
    bodyMedium: TextStyle(fontVariations: [FontVariation('wght', 450)]),
    bodySmall: TextStyle(fontVariations: [FontVariation('wght', 450)]),
    labelLarge: TextStyle(fontVariations: [FontVariation('wght', 550)]),
    labelMedium: TextStyle(fontVariations: [FontVariation('wght', 550)]),
    labelSmall: TextStyle(fontVariations: [FontVariation('wght', 550)]),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: paper,
    foregroundColor: ink,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 22),
      shape: const RoundedRectangleBorder(),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    prefixIconColor: muted,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide.none,
    ),
  ),
);
