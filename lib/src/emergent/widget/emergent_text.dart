import 'dart:ui' as ui show FontFeature;

import 'package:flutter/material.dart' as material;
import 'package:itq_utils/src/emergent/decoration/emergent_text_decorations.dart';
import 'package:itq_utils/itq_utils.dart';

class EmergentTextStyle {
  final bool inherit;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final TextBaseline? textBaseline;
  final double? height;
  final Locale? locale;
  final List<ui.FontFeature>? fontFeatures;
  final TextDecoration? decoration;
  final String? debugLabel;
  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final String? package;
  //final Color color;
  //final Color backgroundColor;
  //final Paint foreground,
  //final Paint background,
  //final TextDecoration decoration,
  //final Color decorationColor;
  //final TextDecorationStyle decorationStyle;
  //final double decorationThickness;

  TextStyle get textStyle => TextStyle(
        inherit: inherit,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        fontFeatures: fontFeatures,
        decoration: decoration,
        debugLabel: debugLabel,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        package: package,
        //color: color,
        //backgroundColor: backgroundColor,
        //foreground: foreground,
        //background: background,
        //decoration: decoration,
        //decorationColor: decorationColor,
        //decorationStyle: decorationStyle,
        //decorationThickness: decorationThickness,
      );

  /// Creates a text style.
  ///
  /// The `package` argument must be non-null if the font family is defined in a
  /// package. It is combined with the `fontFamily` argument to set the
  /// [fontFamily] property.
  EmergentTextStyle({
    this.inherit = true,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.locale,
    this.fontFeatures,
    this.decoration,
    this.debugLabel,
    this.fontFamily,
    //this.color,
    //this.backgroundColor,
    //this.foreground,
    //this.background,
    //this.decoration,
    //this.decorationColor,
    //this.decorationStyle,
    //this.decorationThickness,
    this.fontFamilyFallback,
    this.package,
  });

  EmergentTextStyle copyWith({
    bool? inherit,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    List<ui.FontFeature>? fontFeatures,
    String? debugLabel,
    //Color color,
    //Color backgroundColor,
    //Paint foreground,
    //Paint background,
    //TextDecoration decoration,
    //Color decorationColor,
    //TextDecorationStyle decorationStyle,
    //double decorationThickness,
  }) {
    return EmergentTextStyle(
      inherit: inherit ?? this.inherit,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      textBaseline: textBaseline ?? this.textBaseline,
      height: height ?? this.height,
      locale: locale ?? this.locale,
      fontFeatures: fontFeatures ?? this.fontFeatures,
      debugLabel: debugLabel ?? this.debugLabel,
      //color: this.foreground == null && foreground == null ? color ?? this.color : null,
      //backgroundColor: this.background == null && background == null ? backgroundColor ?? this.backgroundColor : null,
      //foreground: foreground ?? this.foreground,
      //background: background ?? this.background,
      //shadows: shadows ?? this.shadows,
      //decoration: decoration ?? this.decoration,
      //decorationColor: decorationColor ?? this.decorationColor,
      //decorationStyle: decorationStyle ?? this.decorationStyle,
      //decorationThickness: decorationThickness ?? this.decorationThickness,
    );
  }
}

@immutable
class EmergentText extends StatelessWidget {
  final String text;
  final EmergentStyle? style;
  final TextAlign textAlign;
  final EmergentTextStyle? textStyle;
  final Curve curve;
  final Duration duration;

  const EmergentText(
    this.text, {
    super.key,
    this.duration = Emergent.defaultDuration,
    this.curve = Emergent.defaultCurve,
    this.style,
    this.textAlign = TextAlign.center,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EmergentTheme.currentTheme(context);
    final EmergentStyle style = (this.style ?? const EmergentStyle())
        .copyWithThemeIfNull(theme)
        .applyDisableDepth();

    return _EmergentText(
      textStyle: (textStyle ?? EmergentTextStyle()).textStyle,
      textAlign: textAlign,
      text: text,
      duration: duration,
      style: style,
      curve: curve,
    );
  }
}

class _EmergentText extends material.StatefulWidget {
  final String text;

  final EmergentStyle style;
  final TextStyle textStyle;
  final Duration duration;
  final Curve curve;

  final TextAlign textAlign;

  const _EmergentText({
    required this.duration,
    required this.curve,
    required this.textAlign,
    required this.style,
    required this.textStyle,
    required this.text,
  });

  @override
  __EmergentTextState createState() => __EmergentTextState();
}

class __EmergentTextState extends material.State<_EmergentText> {
  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: widget.textAlign);
    final textStyle = widget.textStyle;
    textPainter.text = TextSpan(
      text: widget.text,
      style: widget.textStyle,
    );

    return LayoutBuilder(builder: (context, constraints) {
      textPainter.layout(minWidth: 0, maxWidth: constraints.maxWidth);
      final double width = textPainter.width;
      final double height = textPainter.height;

      return DefaultTextStyle(
        style: textStyle,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          foregroundDecoration: EmergentTextDecoration(
            isForeground: true,
            textStyle: textStyle,
            textAlign: widget.textAlign,
            renderingByPath: true,
            style: widget.style,
            text: widget.text,
          ),
          child: SizedBox(
            width: width,
            height: height,
          ),
        ),
      );
    });
  }
}
