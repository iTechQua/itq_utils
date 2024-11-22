import 'package:flutter/material.dart';
import 'package:itq_utils/itq_utils.dart';

/// Text Styles

/// Returns a TextStyle with bold weight.
TextStyle boldTextStyle({
  int? size,
  Color? color,
  FontWeight? weight,
  String? fontFamily,
  double? letterSpacing,
  FontStyle? fontStyle,
  double? wordSpacing,
  TextDecoration? decoration,
  TextDecorationStyle? textDecorationStyle,
  TextBaseline? textBaseline,
  Color? decorationColor,
  Color? backgroundColor,
  double? height,
}) {
  return TextStyle(
    fontSize: size != null ? size.toDouble() : textBoldSizeGlobal,
    color: color ?? textPrimaryColorGlobal,
    fontWeight: weight ?? fontWeightBoldGlobal,
    fontFamily: fontFamily ?? fontFamilyBoldGlobal,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationStyle: textDecorationStyle,
    decorationColor: decorationColor,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    backgroundColor: backgroundColor,
    height: height,
  );
}

/// Returns a TextStyle with primary color and default settings.
TextStyle primaryTextStyle({
  int? size,
  Color? color,
  FontWeight? weight,
  String? fontFamily,
  double? letterSpacing,
  FontStyle? fontStyle,
  double? wordSpacing,
  TextDecoration? decoration,
  TextDecorationStyle? textDecorationStyle,
  TextBaseline? textBaseline,
  Color? decorationColor,
  Color? backgroundColor,
  double? height,
}) {
  return TextStyle(
    fontSize: size != null ? size.toDouble() : textPrimarySizeGlobal,
    color: color ?? textPrimaryColorGlobal,
    fontWeight: weight ?? fontWeightPrimaryGlobal,
    fontFamily: fontFamily ?? fontFamilyPrimaryGlobal,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationStyle: textDecorationStyle,
    decorationColor: decorationColor,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    backgroundColor: backgroundColor,
    height: height,
  );
}

/// Returns a TextStyle with secondary color and default settings.
TextStyle secondaryTextStyle({
  int? size,
  Color? color,
  FontWeight? weight,
  String? fontFamily,
  double? letterSpacing,
  FontStyle? fontStyle,
  double? wordSpacing,
  TextDecoration? decoration,
  TextDecorationStyle? textDecorationStyle,
  TextBaseline? textBaseline,
  Color? decorationColor,
  Color? backgroundColor,
  double? height,
}) {
  return TextStyle(
    fontSize: size != null ? size.toDouble() : textSecondarySizeGlobal,
    color: color ?? textSecondaryColorGlobal,
    fontWeight: weight ?? fontWeightSecondaryGlobal,
    fontFamily: fontFamily ?? fontFamilySecondaryGlobal,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationStyle: textDecorationStyle,
    decorationColor: decorationColor,
    wordSpacing: wordSpacing,
    textBaseline: textBaseline,
    backgroundColor: backgroundColor,
    height: height,
  );
}

// Create Rich Text
@Deprecated('Use RichTextWidget instead')
RichText createRichText({
  required List<TextSpan> list,
  TextOverflow overflow = TextOverflow.clip,
  int? maxLines,
  TextAlign textAlign = TextAlign.left,
  TextDirection? textDirection,
  StrutStyle? strutStyle,
}) {
  return RichText(
    text: TextSpan(children: list),
    overflow: overflow,
    maxLines: maxLines,
    textAlign: textAlign,
    textDirection: textDirection,
    strutStyle: strutStyle,
  );
}


final TextStyle semiBoldStyle = _textStyle.copyWith(
  fontSize: Dimens.fontSize16,
  fontWeight: FontWeight.w600,
);

final TextStyle mediumStyle = _textStyle.copyWith(
  fontSize: Dimens.fontSize16,
  fontWeight: FontWeight.w500,
);

final TextStyle boldStyle = _textStyle.copyWith(
  fontSize: Dimens.fontSize22,
  fontWeight: FontWeight.w700,
);

final TextStyle regularStyle = _textStyle.copyWith(
  fontSize: Dimens.fontSize18,
  fontWeight: FontWeight.w400,
);

final TextStyle buttonTextStyle = _textStyle.copyWith(
  fontSize: Dimens.fontSize16,
  fontWeight: FontWeight.w600,
);

const TextStyle _textStyle = TextStyle(
  fontFamily: 'SFProDisplay',
  color: Colors.grey,
  fontSize: Dimens.fontSize14,
);

class Dimens {
  const Dimens._();

  static const double fontSize9 = 9;
  static const double fontSize10 = 10;
  static const double fontSize12 = 12;
  static const double fontSize13 = 13;
  static const double fontSize14 = 14;
  static const double fontSize15 = 15;
  static const double fontSize16 = 16;
  static const double fontSize18 = 18;
  static const double fontSize17 = 17;
  static const double fontSize20 = 20;
  static const double fontSize22 = 22;
  static const double fontSize24 = 24;
  static const double fontSize26 = 26;
  static const double fontSize28 = 28;
  static const double fontSize30 = 30;
  static const double fontSize32 = 32;

  // ui
  static const double buttonHeight = 44;
}

class Dimensions {
  static double calcH(double height) {
    double factor = MediaQuery.of(getContext).size.height / height;
    return (MediaQuery.of(getContext).size.height / factor).roundToDouble();
  }

  static double calcW(double width) {
    double factor = MediaQuery.of(getContext).size.width / width;
    return (MediaQuery.of(getContext).size.width / factor).roundToDouble();
  }

  static double fontSizeExtraSmall = MediaQuery.of(getContext).size.width >= 1300 ? 14 : 10;
  static double fontSizeSmall = MediaQuery.of(getContext).size.width >= 1300 ? 16 : 12;
  static double fontSizeDefault = MediaQuery.of(getContext).size.width >= 1300 ? 18 : 14;
  static double fontSizeLarge = MediaQuery.of(getContext).size.width >= 1300 ? 20 : 16;
  static double fontSizeExtraLarge = MediaQuery.of(getContext).size.width >= 1300 ? 22 : 18;
  static double fontSizeOverLarge = MediaQuery.of(getContext).size.width >= 1300 ? 28 : 24;

  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;
  static const double paddingSizeExtremeLarge = 30.0;

  static const double radiusSmall = 5.0;
  static const double radiusDefault = 10.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 20.0;

  static const double webMaxWidth = 1170;
  static const int messageInputLength = 250;
}
