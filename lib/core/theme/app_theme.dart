import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final _outfitTextTheme = GoogleFonts.outfitTextTheme();

  static ThemeData light({Color seedColor = const Color(0xFF6750A4)}) {
    return FlexThemeData.light(
      colors: FlexSchemeColor.from(primary: seedColor),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 9,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: false,
        fabUseShape: true,
        fabAlwaysCircular: true,
        cardRadius: 20.0,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarMutedUnselectedLabel: true,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarIndicatorOpacity: 1.0,
        navigationBarBackgroundSchemeColor: SchemeColor.surfaceContainerLow,
      ),
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      useMaterial3: true,
      textTheme: _outfitTextTheme,
      primaryTextTheme: _outfitTextTheme,
    );
  }

  static ThemeData dark({Color seedColor = const Color(0xFF6750A4)}) {
    return FlexThemeData.dark(
      colors: FlexSchemeColor.from(primary: seedColor),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: false,
        fabUseShape: true,
        fabAlwaysCircular: true,
        cardRadius: 20.0,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarMutedUnselectedLabel: true,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarIndicatorOpacity: 1.0,
        navigationBarBackgroundSchemeColor: SchemeColor.surfaceContainerLow,
      ),
      keyColors: const FlexKeyColors(useSecondary: true, useTertiary: true),
      useMaterial3: true,
      textTheme: _outfitTextTheme,
      primaryTextTheme: _outfitTextTheme,
    );
  }
}
