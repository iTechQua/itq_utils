import 'dart:ui';
import 'package:itq_utils/itq_utils.dart';
import 'package:itq_utils/src/emergent/decoration/emergent_decoration_painter.dart';
import 'package:itq_utils/src/emergent/decoration/emergent_itq_decoration_painter.dart';

@immutable
class EmergentDecoration extends Decoration {
  final EmergentStyle style;
  final EmergentBoxShape shape;
  final bool splitBackgroundForeground;
  final bool renderingByPath;
  final bool isForeground;

  const EmergentDecoration({
    required this.style,
    required this.isForeground,
    required this.renderingByPath,
    required this.splitBackgroundForeground,
    required this.shape,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    //print("createBoxPainter : ${style.depth}");
    if (style.depth != null && style.depth! >= 0) {
      return EmergentDecorationPainter(
        style: style,
        drawGradient: (isForeground && splitBackgroundForeground) ||
            (!isForeground && !splitBackgroundForeground),
        drawBackground: !isForeground,
        //only box draw background
        drawShadow: !isForeground,
        //only box draw shadow
        renderingByPath: renderingByPath,
        onChanged: onChanged ?? () {},
        shape: shape,
      );
    } else {
      return EmergentItqDecorationPainter(
        drawBackground: !isForeground,
        style: style,
        drawShadow: (isForeground && splitBackgroundForeground) ||
            (!isForeground && !splitBackgroundForeground),
        onChanged: onChanged ?? () {},
        shape: shape,
      );
    }
  }

  @override
  EmergentDecoration lerpFrom(Decoration? a, double t) {
    if (a == null) return scale(t);
    if (a is EmergentDecoration) {
      return EmergentDecoration.itqlErp(a, this, t)!;
    }
    return super.lerpFrom(a, t) as EmergentDecoration;
  }

  @override
  EmergentDecoration lerpTo(Decoration? b, double t) {
    if (b == null) return scale(1.0 - t);
    if (b is EmergentDecoration) {
      return EmergentDecoration.itqlErp(this, b, t)!;
    }
    return super.lerpTo(b, t) as EmergentDecoration;
  }

  EmergentDecoration scale(double factor) {
    return EmergentDecoration(
        isForeground: isForeground,
        renderingByPath: renderingByPath,
        splitBackgroundForeground: splitBackgroundForeground,
        shape: EmergentBoxShape.itqlErp(null, shape, factor)!,
        style: style.copyWith());
  }

  static EmergentDecoration? itqlErp(
      EmergentDecoration? a, EmergentDecoration? b, double t) {
    //print("itqlErp $t ${a.style.depth}, ${b.style.depth}");

    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    if (t == 0.0) {
      //print("return a");
      return a;
    }
    if (t == 1.0) {
      //print("return b (1.0)");
      return b;
    }

    var aStyle = a.style;
    var bStyle = b.style;

    return EmergentDecoration(
        isForeground: a.isForeground,
        shape: EmergentBoxShape.itqlErp(a.shape, b.shape, t)!,
        splitBackgroundForeground: a.splitBackgroundForeground,
        renderingByPath: a.renderingByPath,
        style: a.style.copyWith(
          border: EmergentBorder.itqlErp(aStyle.border, bStyle.border, t),
          intensity: lerpDouble(aStyle.intensity, bStyle.intensity, t),
          surfaceIntensity:
              lerpDouble(aStyle.surfaceIntensity, bStyle.surfaceIntensity, t),
          depth: lerpDouble(aStyle.depth, bStyle.depth, t),
          color: Color.lerp(aStyle.color, bStyle.color, t),
          lightSource:
              LightSource.itqlErp(aStyle.lightSource, bStyle.lightSource, t),
        ));
  }

  @override
  bool get isComplex => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergentDecoration &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          shape == other.shape &&
          splitBackgroundForeground == other.splitBackgroundForeground &&
          isForeground == other.isForeground &&
          renderingByPath == other.renderingByPath;

  @override
  int get hashCode =>
      style.hashCode ^
      shape.hashCode ^
      splitBackgroundForeground.hashCode ^
      isForeground.hashCode ^
      renderingByPath.hashCode;
}
