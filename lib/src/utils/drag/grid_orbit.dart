import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:itq_utils/src/utils/drag/drag_drop_view.dart';

typedef WillAcceptCallback = bool Function(int data, int position);
typedef WidgetPositionBuilder = Widget Function(int index);

class MainGridView extends StatefulWidget {
  const MainGridView(
      {super.key,
      this.header,
      this.headerItemCount,
      this.reverse = false,
      this.headerGridDelegate,
      required this.itemBuilder,
      required this.onWillAccept,
      this.feedback,
      required this.onReorder,
      this.childWhenDragging,
      this.itemBuilderHeader,
      this.controller,
      this.isVertical = true,
      this.padding,
      this.semanticChildCount,
      this.physics,
      this.addAutomaticKeepAlive = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.headerPadding,
      this.cacheExtent,
      this.itemCount,
      this.allHeaderChildNonDraggable = false,
      this.primary,
      this.isStickyHeader = false,
      this.onReorderHeader,
      this.onWillAcceptHeader,
      this.isCustomFeedback = false,
      this.isCustomChildWhenDragging = false,
      required this.gridDelegate,
      this.dragStartBehavior = DragStartBehavior.start,
      this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual});
  final bool reverse;
  final Widget? header;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;

  // If you want to set custom feedback child at the time of drag then set this parameter to true
  final bool isCustomFeedback;

  // If you want to set custom child at the time of drag then set this parameter to true
  final bool isCustomChildWhenDragging;

  // onWillAccept determine whether the drag object will accept or not. Based on that return a bool.
  final WillAcceptCallback onWillAccept;
  final WillAcceptCallback? onWillAcceptHeader;
  final bool allHeaderChildNonDraggable;
  final EdgeInsetsGeometry? headerPadding;

  // This method onReorder has two parameters oldIndex and newIndex
  final ReorderCallback onReorder;
  final ReorderCallback? onReorderHeader;

  final EdgeInsetsGeometry? padding;
  final int? headerItemCount;
  final bool isStickyHeader;
  final SliverGridDelegate? headerGridDelegate;
  final SliverGridDelegate gridDelegate;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? itemBuilderHeader;
  final int? itemCount;
  final bool addAutomaticKeepAlive;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final bool isVertical;

  // set you feedback child here and to get this working please set isCustomFeedback to true
  final WidgetPositionBuilder? feedback;

  // set you custom child here and to get this working please set isCustomChildWhenDragging to true
  final WidgetPositionBuilder? childWhenDragging;

  @override
  MainGridViewState createState() => MainGridViewState();
}

class MainGridViewState extends State<MainGridView> {
  late final ScrollController _scrollController;
  ScrollController? _scrollController2;
  double _gridViewHeight = 0.0, _gridViewWidth = 0.0;
  var _isDragStart = false;
  bool _ownsScrollController = false;

  @override
  void initState() {
    super.initState();

    final ctl = widget.controller;

    if (ctl == null) {
      _ownsScrollController = true;
      _scrollController = ScrollController();
      _scrollController2 = ScrollController();
    } else {
      _scrollController = ctl;
    }
  }

  _moveUp() {
    _scrollController.animateTo(_scrollController.offset - _gridViewHeight,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown() {
    _scrollController.animateTo(_scrollController.offset + _gridViewHeight,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveLeft() {
    _scrollController.animateTo(_scrollController.offset - _gridViewWidth,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveRight() {
    _scrollController.animateTo(_scrollController.offset + _gridViewWidth,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  Widget _headerChild(Widget header) {
    return ListView(
      controller: _scrollController,
      children: [header, _dragAndDropGrid()],
    );
  }

  Widget _dragAndDropGrid() {
    return GridView.builder(
      key: widget.key,
      reverse: widget.reverse,
      shrinkWrap: true,
      controller:
          widget.header == null ? _scrollController : _scrollController2,
      padding: widget.padding,
      scrollDirection: widget.isVertical ? Axis.vertical : Axis.horizontal,
      semanticChildCount: widget.semanticChildCount,
      physics: widget.physics,
      addSemanticIndexes: widget.addSemanticIndexes,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlive,
      cacheExtent: widget.cacheExtent,
      itemCount: widget.itemCount,
      primary: widget.primary,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      itemBuilder: (context, pos) {
        var mainWidget = widget.itemBuilder(context, pos);
        if (mainWidget is DragItem) {
          if (!mainWidget.isDraggable) {
            if (!mainWidget.isDroppable) {
              return mainWidget;
            }
            return _gridChild(mainWidget, pos, isNonDraggable: true);
          }
        }

        return _gridChild(mainWidget, pos);
      },
      gridDelegate: widget.gridDelegate,
    );
  }

  Widget _gridChild(Widget mainWidget, int pos,
      {bool isFromArrangeP = false, bool isNonDraggable = false}) {
    return DragTarget(
      builder: (_, __, ___) => isNonDraggable
          ? mainWidget
          : _dragItemBuilder(mainWidget, pos, isFromArrange: isFromArrangeP),
      onWillAcceptWithDetails: (data) {
        if (data.data != null) {
          final onWillAcceptHeader = widget.onWillAcceptHeader;
          if (!isFromArrangeP) {
            return widget.onWillAccept(int.parse(data.data.toString()), pos);
          }
          return data.toString().contains("h") && onWillAcceptHeader != null
              ? onWillAcceptHeader(
                  int.parse(data.toString().replaceAll("h", "")), pos)
              : false;
        }

        return false;
      },
      onAcceptWithDetails: (data) {
        if (isFromArrangeP) {
          if (data.toString().contains("h") && widget.onReorderHeader != null) {
            widget.onReorderHeader!(
                int.parse(data.toString().replaceAll("h", "")), pos);
          }
        } else {
          widget.onReorder(int.parse(data.data.toString()), pos);
        }
      },
    );
  }

  Widget _dragItemBuilder(Widget mainWidget, int pos,
      {bool isFromArrange = false}) {
    final feedback = widget.feedback;
    final childWhenDragging = widget.childWhenDragging;

    return LongPressDraggable(
      data: isFromArrange ? "h$pos" : "$pos",
      feedback: widget.isCustomFeedback && feedback != null
          ? feedback(pos)
          : mainWidget,
      childWhenDragging:
          widget.isCustomChildWhenDragging && childWhenDragging != null
              ? childWhenDragging(pos)
              : mainWidget,
      axis: isFromArrange
          ? widget.isVertical
              ? Axis.horizontal
              : Axis.vertical
          : null,
      onDragStarted: () {
        setState(() {
          _isDragStart = true;
        });
      },
      onDragCompleted: () {
        setState(() {
          _isDragStart = false;
        });
      },
      child: mainWidget,
    );
  }

  Widget _tableBuilderHorizontal() {
    return Row(
      children: [
        NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: GridView.builder(
            shrinkWrap: true,
            padding: widget.headerPadding,
            gridDelegate: widget.headerGridDelegate ?? widget.gridDelegate,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, pos) {
              var mainWidget = widget.itemBuilderHeader!(context, pos);
              if (widget.allHeaderChildNonDraggable) {
                return mainWidget;
              }
              if (mainWidget is DragItem) {
                if (!mainWidget.isDraggable) {
                  if (!mainWidget.isDroppable) {
                    return mainWidget;
                  }
                  return _gridChild(mainWidget, pos,
                      isFromArrangeP: true, isNonDraggable: true);
                }
              }

              return _gridChild(mainWidget, pos, isFromArrangeP: true);
            },
            itemCount: widget.headerItemCount,
          ),
        ),
        Expanded(
          child: _dragAndDropGrid(),
        ),
      ],
    );
  }

  Widget _tableBuilder() {
    return Column(
      children: [
        NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: GridView.builder(
            shrinkWrap: true,
            padding: widget.headerPadding,
            gridDelegate: widget.headerGridDelegate ?? widget.gridDelegate,
            itemBuilder: (context, pos) {
              var mainWidget = widget.itemBuilderHeader!(context, pos);
              if (widget.allHeaderChildNonDraggable) {
                return mainWidget;
              }
              if (mainWidget is DragItem) {
                if (!mainWidget.isDraggable) {
                  if (!mainWidget.isDroppable) {
                    return mainWidget;
                  }
                  return _gridChild(mainWidget, pos,
                      isFromArrangeP: true, isNonDraggable: true);
                }
              }

              return _gridChild(mainWidget, pos, isFromArrangeP: true);
            },
            itemCount: widget.headerItemCount,
          ),
        ),
        Expanded(
          child: _dragAndDropGrid(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = widget.header;

    return Stack(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          _gridViewHeight = constraints.maxHeight;
          _gridViewWidth = constraints.maxWidth;
          return widget.isStickyHeader
              ? widget.isVertical
                  ? _tableBuilder()
                  : _tableBuilderHorizontal()
              : header == null
                  ? _dragAndDropGrid()
                  : _headerChild(header);
        }),
        !_isDragStart
            ? const SizedBox()
            : Align(
                alignment: widget.isVertical
                    ? Alignment.topCenter
                    : Alignment.centerRight,
                child: DragTarget(
                  builder:
                      (context, List<String?> candidateData, rejectedData) =>
                          Container(
                    height: widget.isVertical ? 20 : double.infinity,
                    width: widget.isVertical ? double.infinity : 20,
                    color: Colors.transparent,
                  ),
                  onWillAcceptWithDetails: (_) {
                    if (!widget.isVertical) {
                      _moveRight();
                      return false;
                    }
                    _moveUp();
                    return false;
                  },
                ),
              ),
        !_isDragStart
            ? const SizedBox()
            : Align(
                alignment: widget.isVertical
                    ? Alignment.bottomCenter
                    : Alignment.centerLeft,
                child: DragTarget(
                  builder:
                      (context, List<String?> candidateData, rejectedData) =>
                          Container(
                    height: widget.isVertical ? 20 : double.infinity,
                    width: widget.isVertical ? double.infinity : 20,
                    color: Colors.transparent,
                  ),
                  onWillAcceptWithDetails: (_) {
                    if (!widget.isVertical) {
                      _moveLeft();
                      return false;
                    }
                    _moveDown();
                    return false;
                  },
                ),
              ),
      ],
    );
  }

  @override
  void dispose() {
    if (_ownsScrollController) {
      _scrollController.dispose();
    }
    _scrollController2?.dispose();
    super.dispose();
  }
}
