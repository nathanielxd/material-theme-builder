library material_theme_builder;

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class MaterialThemeBuilder {

  final Brightness brightness;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color error;
  final Color neutral;

  static final neutralVariantPalette = tonalPalette(Colors.grey);

  MaterialThemeBuilder({
    this.brightness = Brightness.light,
    required this.primary, 
    required this.secondary, 
    required this.tertiary,
    this.error = Colors.red,
    this.neutral = Colors.grey
  });

  ColorScheme toScheme() {
    final isLight = brightness == Brightness.light;
    final primaryPalette = tonalPalette(primary);
    final secondaryPalette = tonalPalette(secondary);
    final tertiaryPalette = tonalPalette(tertiary);
    final errorPalette = tonalPalette(error);
    final neutralPalette = tonalPalette(neutral);

    return ColorScheme(
      brightness: brightness, 
      primary: isLight ? primaryPalette[40]! : primaryPalette[80]!, 
      onPrimary: isLight ? primaryPalette[100]! : primaryPalette[20]!,
      primaryContainer: isLight ? primaryPalette[90]! : primaryPalette[30]!,
      onPrimaryContainer: isLight ? primaryPalette[10]! : primaryPalette[90]!,
      secondary: isLight ? secondaryPalette[40]! : secondaryPalette[80]!,
      onSecondary: isLight ? secondaryPalette[100]! : secondaryPalette[20]!,
      secondaryContainer: isLight ? secondaryPalette[90]! : secondaryPalette[30]!,
      onSecondaryContainer: isLight ? secondaryPalette[10]! : secondaryPalette[90]!,
      tertiary: isLight ? tertiaryPalette[40]! : tertiaryPalette[80]!,
      onTertiary: isLight ? tertiaryPalette[100]! : tertiaryPalette[20]!,
      tertiaryContainer: isLight ? tertiaryPalette[90]! : tertiaryPalette[30]!,
      onTertiaryContainer: isLight ? tertiaryPalette[10]! : tertiaryPalette[90]!,
      error: isLight ? errorPalette[40]! : errorPalette[80]!,
      onError: isLight ? errorPalette[100]! : errorPalette[20]!,
      errorContainer: isLight ? errorPalette[90]! : errorPalette[30]!,
      onErrorContainer: isLight ? errorPalette[10]! : errorPalette[90]!,
      background: isLight ? neutralPalette[99]! : neutralPalette[10]!,
      onBackground: isLight ? neutralPalette[10]! : neutralPalette[90]!,
      surface: isLight ? neutralPalette[99]! : neutralPalette[10]!,
      onSurface: isLight ? neutralPalette[10]! : neutralPalette[90]!,
      surfaceVariant: isLight ? neutralVariantPalette[90] : neutralVariantPalette[30],
      onSurfaceVariant: isLight ? neutralVariantPalette[30] : neutralVariantPalette[80],
      outline: isLight ? neutralVariantPalette[50] : neutralVariantPalette[60]
    );
  }


  static Map<int, Color> tonalPalette(Color color) {
    final hct = HctColor.fromInt(color.value);
    final palette = TonalPalette.of(hct.hue, hct.chroma).asList;
    var colors = <int, Color>{};

    for(var i = 0; i < TonalPalette.commonSize; i++) {
      colors.addAll({
        TonalPalette.commonTones[i]: Color(palette[i])
      });
    }

    return colors;
  }
}