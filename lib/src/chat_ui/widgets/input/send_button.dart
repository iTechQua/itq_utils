import 'package:flutter/material.dart';
import 'package:itq_utils/src/chat_ui/widgets/state/inherited_chat_theme.dart';
import 'package:itq_utils/src/chat_ui/widgets/state/inherited_l10n.dart';


/// A class that represents send button widget.
class SendButton extends StatelessWidget {
  /// Creates send button widget.
  const SendButton({
    super.key,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
  });

  /// Callback for send button tap event.
  final VoidCallback onPressed;

  /// Padding around the button.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
        margin: InheritedChatTheme.of(context).theme.sendButtonMargin ??
            const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
        child: IconButton(
          constraints: const BoxConstraints(
            minHeight: 24,
            minWidth: 24,
          ),
          icon: InheritedChatTheme.of(context).theme.sendButtonIcon ??
              Image.asset(
                'assets/icon-send.png',
                color: InheritedChatTheme.of(context).theme.inputTextColor,
                package: 'htkc_utils',
              ),
          onPressed: onPressed,
          padding: padding,
          splashRadius: 24,
          tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
        ),
      );
}
