import 'package:itq_utils/itq_utils.dart';

abstract class EmergentPathProvider extends CustomClipper<Path> {
  const EmergentPathProvider({super.reclip});

  @override
  Path getClip(Size size) {
    return getPath(size);
  }

  /// only used when shape == convex || concave
  /// when you have multiple path (with some moveTo) inside :
  /// true -> draw a different gradient for each sub path
  /// false -> draw an unique gradient for all the widget
  bool get oneGradientPerPath;

  Path getPath(Size size);

  @override
  bool shouldReclip(EmergentPathProvider oldClipper) {
    return false;
  }
}
