import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:itq_utils/src/emergent/widget/emergent_container.dart';

/// Defines default colors used in Emergent theme & shadows generators
@immutable
class EmergentColors {
  static const background = Color(0xFFDDE6E8);
  static const accent = Color(0xFF2196F3);
  static const variant = Color(0xFF00BCD4);
  static const disabled = Color(0xFF9E9E9E);

  static const darkBackground = Color(0xFF2D2F2F);
  static const darkAccent = Color(0xFF4CAF50);
  static const darkVariant = Color(0xFF607D8B);
  static const darkDisabled = Color(0xB3FFFFFF);
  static const darkDefaultTextColor = Color(0xB3FFFFFF);

  static const Color defaultBorder = Color(0x33000000);
  static const Color darkDefaultBorder = Color(0x33FFFFFF);

  static const Color decorationMaxWhiteColor =
      Color(0xFFFFFFFF); //for intensity = 1
  static const Color decorationMaxDarkColor =
      Color(0x8A000000); //for intensity = 1

  static const Color itqMaxWhiteColor = Color(0x99FFFFFF); //for intensity = 1
  static const Color itqMaxDarkColor = Color(0x73000000); //for intensity = 1

  static const Color _gradientShaderDarkColor = Color(0x8A000000);
  static const Color _gradientShaderWhiteColor = Color(0xFFFFFFFF);

  static const Color defaultTextColor = Color(0xFF000000);

  const EmergentColors._();

  static Color decorationWhiteColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(
      maxColor: color,
      percent: intensity,
    );
  }

  static Color decorationDarkColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(
      maxColor: color,
      percent: intensity,
    );
  }

  static Color itqWhiteColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(
      maxColor: color,
      percent: intensity,
    );
  }

  static Color itqDarkColor(Color color, {required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(
      maxColor: color,
      percent: intensity,
    );
  }

  static Color gradientShaderDarkColor({required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(
        maxColor: EmergentColors._gradientShaderDarkColor, percent: intensity);
  }

  static Color gradientShaderWhiteColor({required double intensity}) {
    // intensity act on opacity;
    return _applyPercentageOnOpacity(
        maxColor: EmergentColors._gradientShaderWhiteColor, percent: intensity);
  }

  static Color _applyPercentageOnOpacity(
      {required Color maxColor, required double percent}) {
    final maxOpacity = maxColor.a;
    const maxIntensity = Emergent.maxIntensity;
    final newOpacity = percent * maxOpacity / maxIntensity;
    final newColor =
        maxColor.withValues(alpha: newOpacity); //<-- intensity act on opacity;
    return newColor;
  }
}
