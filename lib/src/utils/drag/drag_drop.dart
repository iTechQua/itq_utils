import 'package:flutter/material.dart';
import 'package:itq_utils/src/utils/drag/grid_orbit.dart';

class DragAndDropView extends MainGridView {
  /// DragAndDropGridView has the all same parameters (except `shrinkWrap` and `scrollDirection`)
  /// that GridView.builder constructor
  ///
  /// Providing a non-null `itemCount` improves the ability of the [GridView] to
  /// estimate the maximum scroll extent.
  ///
  /// `itemBuilder` will be called only with indices greater than or equal to
  /// zero and less than `itemCount`.
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlive] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
  /// this [onReorder] have the old index and new index. Called when an acceptable piece of data was dropped over this grid child.
  /// [onWillAccept] this funciton allows you to validate if you want to accept the change in the order of the gridViewItems.
  ///  If you always want to accept the change simply return true
  const DragAndDropView({
    super.key,
    super.reverse,
    super.header,
    super.controller,
    super.primary,
    super.physics,
    super.isCustomFeedback,
    super.isCustomChildWhenDragging,
    required super.onWillAccept,
    required super.onReorder,
    super.padding,
    required super.gridDelegate,
    required super.itemBuilder,
    super.itemCount,
    bool addAutomaticKeepAlives = true,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.feedback,
    super.childWhenDragging,
  }) : super(
          addAutomaticKeepAlive: addAutomaticKeepAlives,
        );

  /// This constructor  use to achive the Horizontal Reorderable / Re-Indexing feature in DragAndDropGridView.
  /// Providing a non-null `itemCount` improves the ability of the [GridView] to
  /// estimate the maximum scroll extent.
  ///
  /// `itemBuilder` will be called only with indices greater than or equal to
  /// zero and less than `itemCount`.
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
  /// this [onReorder] have the old index and new index. Called when an acceptable piece of data was dropped over this grid child.
  /// [onWillAccept] this funciton allows you to validate if you want to accept the change in the order of the gridViewItems.
  ///  If you always want to accept the change simply return true
  const DragAndDropView.horizontal({
    super.key,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.isCustomFeedback,
    super.isCustomChildWhenDragging,
    required super.onWillAccept,
    required super.onReorder,
    super.padding,
    required super.gridDelegate,
    required super.itemBuilder,
    super.itemCount,
    bool addAutomaticKeepAlives = true,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.feedback,
    super.childWhenDragging,
  }) : super(
          addAutomaticKeepAlive: addAutomaticKeepAlives,
          isVertical: false,
        );

  /// To achive the sticky header in gridview just call this stickyHeader constructor.

  /// By Default allHeaderChildNonDraggable is set to false making all header draggable.

  /// [onWillAcceptHeader] (Implement your logic on accepting and rejecting the drop of an header element),

  /// [onReorderHeader] (implement your logic for reodering and reindexing the elements)

  /// And if you want the header to be non-draggable element simple set [allHeaderChildNonDraggable] to true.

  ///  [itemBuilderHeader] will be called only with indices greater than or equal to
  ///
  ///
  /// Providing a non-null `itemCount` improves the ability of the [GridView] to
  /// estimate the maximum scroll extent.
  ///
  /// `itemBuilder` will be called only with indices greater than or equal to
  /// zero and less than `itemCount`.
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
  /// this [onReorder] have the old index and new index. Called when an acceptable piece of data was dropped over this grid child.
  /// [onWillAccept] this funciton allows you to validate if you want to accept the change in the order of the gridViewItems.
  ///  If you always want to accept the change simply return true
  const DragAndDropView.stickyHeader({
    super.key,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.isCustomFeedback,
    super.isCustomChildWhenDragging,
    required super.onWillAccept,
    super.onWillAcceptHeader,
    required IndexedWidgetBuilder super.itemBuilderHeader,
    super.allHeaderChildNonDraggable,
    super.headerGridDelegate,
    required super.onReorder,
    super.onReorderHeader,
    super.headerItemCount,
    super.headerPadding,
    super.padding,
    required super.gridDelegate,
    required super.itemBuilder,
    super.itemCount,
    bool addAutomaticKeepAlives = true,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.feedback,
    super.childWhenDragging,
  }) : super(
          addAutomaticKeepAlive: addAutomaticKeepAlives,
          isStickyHeader: true,
        );

  /// To achive the sticky header in horizontal gridview just call this horizontalStickyHeader constructor.

  /// By Default allHeaderChildNonDraggable is set to false making all header draggable.

  /// [onWillAcceptHeader] (Implement your logic on accepting and rejecting the drop of an header element),

  /// [onReorderHeader] (implement your logic for reodering and reindexing the elements)

  /// And if you want the header to be non-draggable element simple set [allHeaderChildNonDraggable] to true.

  ///  [itemBuilderHeader] will be called only with indices greater than or equal to
  ///
  ///
  /// Providing a non-null `itemCount` improves the ability of the [GridView] to
  /// estimate the maximum scroll extent.
  ///
  /// `itemBuilder` will be called only with indices greater than or equal to
  /// zero and less than `itemCount`.
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
  /// this [onReorder] have the old index and new index. Called when an acceptable piece of data was dropped over this grid child.
  /// [onWillAccept] this funciton allows you to validate if you want to accept the change in the order of the gridViewItems.
  ///  If you always want to accept the change simply return true
  const DragAndDropView.horizontalStickyHeader({
    super.key,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.isCustomFeedback,
    super.isCustomChildWhenDragging,
    required super.onWillAccept,
    super.onWillAcceptHeader,
    required IndexedWidgetBuilder super.itemBuilderHeader,
    super.allHeaderChildNonDraggable,
    super.headerGridDelegate,
    required super.onReorder,
    super.onReorderHeader,
    super.headerItemCount,
    super.headerPadding,
    super.padding,
    required super.gridDelegate,
    required super.itemBuilder,
    super.itemCount,
    bool addAutomaticKeepAlives = true,
    super.addRepaintBoundaries,
    super.addSemanticIndexes,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.feedback,
    super.childWhenDragging,
  }) : super(
            addAutomaticKeepAlive: addAutomaticKeepAlives,
            isStickyHeader: true,
            isVertical: false);
}
