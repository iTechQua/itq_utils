import 'package:flutter/material.dart';

class DecoratedTabBar extends StatelessWidget implements PreferredSizeWidget {
  const DecoratedTabBar(
      {super.key,
      required this.tabBar,
      required this.decoration,
      required this.bgColor});

  final TabBar tabBar;
  final BoxDecoration? decoration;
  final Color bgColor;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Stack(
        children: [
          decoration == null
              ? Positioned.fill(child: Container())
              : Positioned.fill(child: Container(decoration: decoration)),
          tabBar,
        ],
      ),
    );
  }
}
