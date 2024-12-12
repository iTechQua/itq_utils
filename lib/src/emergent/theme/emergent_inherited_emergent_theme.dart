import 'package:itq_utils/src/emergent/theme/emergent_theme_wrapper.dart';
import 'package:itq_utils/itq_utils.dart';

typedef EmergentThemeUpdater = EmergentThemeData Function(
    EmergentThemeData? current);

class EmergentThemeInherited extends InheritedWidget {
  final Widget itqChild;
  final ThemeWrapper value;
  final ValueChanged<ThemeWrapper> onChanged;

  const EmergentThemeInherited(
      {super.key,
      required this.itqChild,
      required this.value,
      required this.onChanged})
      : super(child: itqChild);

  @override
  bool updateShouldNotify(EmergentThemeInherited oldWidget) =>
      value != oldWidget.value;

  EmergentThemeData? get current {
    return value.current;
  }

  bool get isUsingDark {
    return value.useDark;
  }

  ThemeMode get themeMode => value.themeMode;

  set themeMode(ThemeMode currentTheme) {
    onChanged(value.copyWith(currentTheme: currentTheme));
  }

  void updateCurrentTheme(EmergentThemeData update) {
    if (value.useDark) {
      final newValue = value.copyWith(darkTheme: update);
      //this.value = newValue;
      onChanged(newValue);
    } else {
      final newValue = value.copyWith(theme: update);
      //this.value = newValue;
      onChanged(newValue);
    }
  }

  void update(EmergentThemeUpdater themeUpdater) {
    final update = themeUpdater(value.current);
    if (value.useDark) {
      final newValue = value.copyWith(darkTheme: update);
      //this.value = newValue;
      onChanged(newValue);
    } else {
      final newValue = value.copyWith(theme: update);
      //this.value = newValue;
      onChanged(newValue);
    }
  }
}
