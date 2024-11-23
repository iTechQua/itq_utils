import 'package:flutter/material.dart';

class DragItem extends StatefulWidget {
  final bool isDraggable;
  final bool isDroppable;
  final Widget child;

  const DragItem({
    super.key,
    this.isDraggable = true,
    this.isDroppable = true,
    required this.child,
  });

  @override
  DragItemState createState() => DragItemState();
}

class DragItemState extends State<DragItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.key,
      child: widget.child,
    );
  }
}
