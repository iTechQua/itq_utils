import 'package:flutter/material.dart';
import 'package:itq_utils/itq_utils.dart';

class EmergentCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final EmergentStyle? style;
  final EdgeInsets? padding;

  const EmergentCloseButton({
    Key? key,
    this.onPressed,
    this.style,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nThemeIcons = EmergentTheme.of(context)!.current!.appBarTheme.icons;
    return EmergentButton(
      style: style,
      padding: padding,
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      child: nThemeIcons.closeIcon,
    );
  }
}
