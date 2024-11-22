import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itq_utils/itq_utils.dart';

class ItqAppBar extends StatefulWidget {
  final double topPadding;
  final Widget child;
  final String? title;
  final Color bgColor;
  final Color color;
  final Color sColor;
  final FontWeight titleFontWeight;
  final bool action;
  final bool isDialog;
  final bool isBack;
  final bool isBackFunction;
  final bool isCenter;
  final bool isTitleSuffix;
  final String? actionTitle;
  final String? backButtonImage;
  final Widget? actionWidget;
  final Widget? titleSuffix;
  final GestureTapCallback? onTap;
  const ItqAppBar(
      {super.key,
        this.backButtonImage,
        this.onTap,
        this.titleSuffix,
        this.actionWidget,
        this.actionTitle,
        this.isTitleSuffix = false,
        this.isCenter = false,
        this.isBackFunction = false,
        this.isBack = true,
        this.isDialog = false,
        this.action = false,
        this.topPadding = kToolbarHeight,
        this.titleFontWeight = FontWeight.normal,
        this.color = Colors.white,
        this.sColor = blueViolet,
        this.bgColor = blueColor,
        required this.child,
        this.title});

  @override
  State<ItqAppBar> createState() => _ItqAppBarState();
}

class _ItqAppBarState extends State<ItqAppBar> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: itqGradient(),
          ),
          padding: EdgeInsets.only(
              top: Platform.isAndroid
                  ? widget.topPadding + 40
                  : widget.topPadding + size.height * 0.06),
          child: Container(
            padding: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18), topLeft: Radius.circular(18)),
            ),
            child: widget.child,
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IntrinsicHeight(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: widget.isTitleSuffix
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.isCenter
                      ? SizedBox(width: 35.toDouble())
                      : SizedBox(width: 0.toDouble()),
                  Text(widget.title ?? '',
                      style: TextStyle(
                          color: widget.color,
                          fontWeight: widget.titleFontWeight)),
                  GestureDetector(
                      onTap: widget.onTap,
                      child: Emergent(
                          style: EmergentStyle(
                              shape: EmergentShape.concave,
                              boxShape: EmergentBoxShape.roundRect(
                                  BorderRadius.circular(25)),
                              depth: 3,
                              lightSource: LightSource.topLeft,
                              color: widget.sColor),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: widget.titleSuffix,
                          ))),
                ],
              )
                  : Text(widget.title ?? '',
                  style: TextStyle(
                      color: widget.color,
                      fontWeight: widget.titleFontWeight)),
              leading: widget.isBack
                  ? GestureDetector(
                  onTap: () {
                    if (widget.isBackFunction) {
                      itqOnBackPressed(context);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      widget.backButtonImage!,
                      color: widget.color,
                    ),
                  ))
                  : Container(),
              centerTitle: !widget.isBack,
              actions: [
                widget.action
                    ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Emergent(
                    style: EmergentStyle(depth: -5, color: widget.sColor),
                    child: TextButton(
                      onPressed: () {
                        widget.isDialog
                            ? showDialog(
                          context: context,
                          builder: (_) => widget.actionWidget!,
                        )
                            : widget.actionWidget?.launch(context);
                      },
                      child: Text(
                        widget.actionTitle!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
