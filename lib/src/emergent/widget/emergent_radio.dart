import 'package:itq_utils/itq_utils.dart';

typedef EmergentRadioListener<T> = void Function(T value);

/// A Style used to customize a [EmergentRadio]
///
/// [selectedDepth] : the depth when checked
/// [unselectedDepth] : the depth when unchecked (default : theme.depth)
///
/// [intensity] : a customizable emergent intensity for this widget
///
/// [boxShape] : a customizable emergent boxShape for this widget
///   @see [EmergentBoxShape]
///
/// [shape] : a customizable emergent shape for this widget
///   @see [EmergentShape] (concave, convex, flat)
///
class EmergentRadioStyle {
  final double? selectedDepth;
  final double? unselectedDepth;
  final bool disableDepth;

  final Color? selectedColor; //null for default
  final Color? unselectedColor; //null for unchanged color

  final double? intensity;
  final EmergentShape? shape;

  final EmergentBorder border;
  final EmergentBoxShape? boxShape;

  final LightSource? lightSource;

  const EmergentRadioStyle({
    this.selectedDepth,
    this.unselectedDepth,
    this.selectedColor,
    this.unselectedColor,
    this.lightSource,
    this.disableDepth = false,
    this.boxShape,
    this.border = const EmergentBorder.none(),
    this.intensity,
    this.shape,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergentRadioStyle &&
          runtimeType == other.runtimeType &&
          disableDepth == other.disableDepth &&
          lightSource == other.lightSource &&
          border == other.border &&
          selectedDepth == other.selectedDepth &&
          unselectedDepth == other.unselectedDepth &&
          selectedColor == other.selectedColor &&
          unselectedColor == other.unselectedColor &&
          boxShape == other.boxShape &&
          intensity == other.intensity &&
          shape == other.shape;

  @override
  int get hashCode =>
      disableDepth.hashCode ^
      selectedDepth.hashCode ^
      lightSource.hashCode ^
      selectedColor.hashCode ^
      unselectedColor.hashCode ^
      boxShape.hashCode ^
      border.hashCode ^
      unselectedDepth.hashCode ^
      intensity.hashCode ^
      shape.hashCode;
}

/// A Emergent Radio
///
/// It takes a `value` and a `groupValue`
/// if (value == groupValue) => checked
///
/// takes a EmergentRadioStyle as `style`
///
/// notifies the parent when user interact with this widget with `onChanged`
///
/// ```
/// int _groupValue;
///
/// Widget _buildRadios() {
///    return Row(
///      children: <Widget>[
///
///        EmergentRadio(
///          child: SizedBox(
///            height: 50,
///            width: 50,
///            child: Center(
///              child: Text("1"),
///            ),
///          ),
///          value: 1,
///          groupValue: _groupValue,
///          onChanged: (value) {
///            setState(() {
///              _groupValue = value;
///            });
///          },
///        ),
///
///        EmergentRadio(
///          child: SizedBox(
///            height: 50,
///            width: 50,
///            child: Center(
///              child: Text("2"),
///            ),
///          ),
///          value: 2,
///          groupValue: _groupValue,
///          onChanged: (value) {
///            setState(() {
///              _groupValue = value;
///            });
///          },
///        ),
///
///        EmergentRadio(
///          child: SizedBox(
///            height: 50,
///            width: 50,
///            child: Center(
///              child: Text("3"),
///            ),
///          ),
///          value: 3,
///          groupValue: _groupValue,
///          onChanged: (value) {
///            setState(() {
///              _groupValue = value;
///            });
///          },
///        ),
///
///      ],
///    );
///  }
/// ```
///
@immutable
class EmergentRadio<T> extends StatelessWidget {
  final Widget? child;
  final T? value;
  final T? groupValue;
  final EdgeInsets padding;
  final EmergentRadioStyle style;
  final EmergentRadioListener<T?>? onChanged;
  final bool isEnabled;

  final Duration duration;
  final Curve curve;

  const EmergentRadio({
    super.key,
    this.child,
    this.style = const EmergentRadioStyle(),
    this.value,
    this.curve = Emergent.defaultCurve,
    this.duration = Emergent.defaultDuration,
    this.padding = EdgeInsets.zero,
    this.groupValue,
    this.onChanged,
    this.isEnabled = true,
  });

  bool get isSelected => value != null && value == groupValue;

  void _onClick() {
    if (onChanged != null) {
      if (value == groupValue) {
        //unselect
        onChanged!(null);
      } else {
        onChanged!(value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final EmergentThemeData theme = EmergentTheme.currentTheme(context);

    final double selectedDepth =
        -1 * (style.selectedDepth ?? theme.depth).abs();
    final double unselectedDepth =
        (style.unselectedDepth ?? theme.depth).abs();

    double depth = isSelected ? selectedDepth : unselectedDepth;
    if (!isEnabled) {
      depth = 0;
    }

    final Color unselectedColor = style.unselectedColor ?? theme.baseColor;
    final Color selectedColor = style.selectedColor ?? unselectedColor;

    final Color color = isSelected ? selectedColor : unselectedColor;

    return EmergentButton(
      onPressed: () {
        _onClick();
      },
      duration: duration,
      curve: curve,
      padding: padding,
      pressed: isSelected,
      minDistance: selectedDepth,
      style: EmergentStyle(
        border: style.border,
        color: color,
        boxShape: style.boxShape,
        lightSource: style.lightSource ?? theme.lightSource,
        disableDepth: style.disableDepth,
        intensity: style.intensity,
        depth: depth,
        shape: style.shape ?? EmergentShape.flat,
      ),
      child: child,
    );
  }
}
