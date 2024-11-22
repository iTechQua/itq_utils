import 'package:flutter/material.dart';

/// Alert types
enum ItqAlertType { error, success, info, warning, none }

/// Alert animation types
enum ItqAnimationType { fromRight, fromLeft, fromTop, fromBottom, grow, shrink }

/// Alert style class for reusable customization of dialogs.
class ItqAlertStyle {
  final ItqAnimationType animationType;
  final Duration animationDuration;
  final ShapeBorder? alertBorder;
  final bool isCloseButton;
  final bool isOverlayTapDismiss;
  final Color overlayColor;
  final TextStyle titleStyle;
  final TextStyle descStyle;
  final EdgeInsets buttonAreaPadding;

  /// Alert style constructor function
  /// The [animationType] parameter is used for transitions. Default: "fromBottom"
  /// The [animationDuration] parameter is used to set the animation transition time. Default: "200 ms"
  /// The [alertBorder] parameter sets border.
  /// The [isCloseButton] parameter sets visibility of the close button. Default: "true"
  /// The [isOverlayTapDismiss] parameter sets closing the alert by clicking outside. Default: "true"
  /// The [overlayColor] parameter sets the background color of the outside. Default: "Color(0xDD000000)"
  /// The [titleStyle] parameter sets alert title text style.
  /// The [descStyle] parameter sets alert desc text style.
  /// The [buttonAreaPadding] parameter sets button area padding.
  const ItqAlertStyle({
    this.animationType = ItqAnimationType.grow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.alertBorder,
    this.isCloseButton = true,
    this.isOverlayTapDismiss = true,
    this.overlayColor = Colors.black87,
    this.titleStyle = const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 22.0),
    this.descStyle = const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        fontSize: 18.0),
    this.buttonAreaPadding = const EdgeInsets.all(10.0),
  });
}