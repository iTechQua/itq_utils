import 'package:flutter/material.dart';
import 'package:itq_utils/itq_utils.dart';

class OpenAlertDialog extends StatefulWidget {
  final Widget child;

  const OpenAlertDialog({super.key, required this.child});
  @override
  OpenAlertDialogState createState() => OpenAlertDialogState();
}

class OpenAlertDialogState extends State<OpenAlertDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        shape: itqRoundedRectangleShape,
        content: SingleChildScrollView(
          child: widget.child,
        ),
      );
    });
  }
}
