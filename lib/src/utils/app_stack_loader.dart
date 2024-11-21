
import 'package:flutter/material.dart';
import 'package:itq_utils/itq_utils.dart';

class AppStackLoader extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AppStackLoader({super.key, required this.visible, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        itqProgress().center().visible(visible.validate()),
      ],
    );
  }

  /// Circular Progressbar
  Widget itqProgress({
    Color color = Colors.blue,
  }) {
    return Container(
      alignment: Alignment.center,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 4,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(borderRadius: radius(50)),
        child: Container(
          width: 45,
          height: 45,
          padding: const EdgeInsets.all(8.0),
          child: Theme(
            data: ThemeData(
                colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: color)),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}
