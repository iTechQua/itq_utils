import 'package:flutter/material.dart';
import 'package:itq_utils/itq_utils.dart';

class EmergentBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final EmergentStyle? style;
  final EdgeInsets? padding;
  final bool forward;

  const EmergentBackButton({
    super.key,
    this.onPressed,
    this.style,
    this.padding,
    this.forward = false,
  });

  @override
  Widget build(BuildContext context) {
    final nThemeIcons = EmergentTheme.of(context)!.current!.appBarTheme.icons;
    return EmergentButton(
      style: style,
      padding: padding,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      child: forward ? nThemeIcons.forwardIcon : nThemeIcons.backIcon,
    );
  }
}
