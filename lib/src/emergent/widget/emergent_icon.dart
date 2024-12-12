import 'package:itq_utils/itq_utils.dart';

@immutable
class EmergentIcon extends StatelessWidget {
  final IconData icon;
  final EmergentStyle? style;
  final Curve curve;
  final double size;
  final Duration duration;

  const EmergentIcon(
    this.icon, {
    super.key,
    this.duration = Emergent.defaultDuration,
    this.curve = Emergent.defaultCurve,
    this.style,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return EmergentText(
      String.fromCharCode(icon.codePoint),
      textStyle: EmergentTextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
      ),
      duration: duration,
      style: style,
      curve: curve,
    );
  }
}
