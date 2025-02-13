import 'package:itq_utils/itq_utils.dart';

const BoxConstraints _itqSizeConstraints = BoxConstraints.tightFor(
  width: 56.0,
  height: 56.0,
);

const BoxConstraints _itqMiniSizeConstraints = BoxConstraints.tightFor(
  width: 40.0,
  height: 40.0,
);

class EmergentFloatingActionButton extends StatelessWidget {
  final Widget? child;
  final EmergentButtonClickListener? onPressed;
  final bool mini;
  final String? tooltip;
  final EmergentStyle? style;

  const EmergentFloatingActionButton({
    super.key,
    this.mini = false,
    this.style,
    this.tooltip,
    @required this.child,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: mini ? _itqMiniSizeConstraints : _itqSizeConstraints,
      child: EmergentButton(
        padding: const EdgeInsets.all(0),
        onPressed: onPressed,
        tooltip: tooltip,
        style: style ??
            EmergentTheme.currentTheme(context).appBarTheme.buttonStyle,
        child: child,
      ),
    );
  }
}
