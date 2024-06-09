import 'dart:math';
import 'package:flutter/material.dart';

/// Start DragGrid slideAnimations (from -> end)
void startRunDragGridSlideAnimations<T>({
  required bool enable,
  required Size itemSize,
  required List<T> oldItems,
  required List<T> newItems,
  required AnimationController animateController,
  required List<Animation<Offset>?> slideAnimations,
  required List<Animation<double>?> fadeAnimations,
  required double crossAxisSpacing,
  required double mainAxisSpacing,
  required Axis direction,
  required int crossCount,
}) {
  if (enable) {
    fadeAnimations.clear();
    slideAnimations.clear();

    // slideAnimations
    for (final end in newItems.asMap().keys) {
      int from = oldItems.indexOf(newItems[end]);

      slideAnimations.add(createGridItemSlideAnimation(
        enable: enable,
        itemSize: itemSize,
        direction: direction,
        crossCount: crossCount,
        animateController: animateController,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        from: from != -1 ? from : end,
        end: end,
      ));
    }

    // fadeAnimations
    for (final obj in newItems.asMap().entries) {
      if (obj.key >= oldItems.length) {
        fadeAnimations.add(null);
        continue;
      }

      if (oldItems.any((old) => old == obj.value)) {
        fadeAnimations.add(null);
        continue;
      }

      fadeAnimations.add(createGridItemFadeAnimation(
        animateController: animateController,
        enable: enable,
      ));
    }

    animateController.reset();
    animateController.forward();
  }
}

/// Create GridItem slideAnimation (from -> end)
Animation<Offset>? createGridItemSlideAnimation({
  required int end,
  required int from,
  required bool enable,
  required Size itemSize,
  required Axis direction,
  required int crossCount,
  required double mainAxisSpacing,
  required double crossAxisSpacing,
  required AnimationController animateController,
}) {
  if (enable && from != end) {
    Tween<Offset> tween = Tween(
      begin: getAnimationGridItemOffset(
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        crossCount: crossCount,
        direction: direction,
        itemSize: itemSize,
        from: from,
        end: end,
      ),
      end: const Offset(0.0, 0.0),
    );

    return tween.animate(
      CurvedAnimation(
        parent: animateController,
        curve: Curves.easeOut,
      ),
    );
  }

  return null;
}

/// Create GridItem slideAnimation (from -> end)
Animation<double>? createGridItemFadeAnimation({
  required bool enable,
  required AnimationController animateController,
}) {
  if (enable) {
    Tween<double> tween = Tween(
      begin: 0.0,
      end: 1.0,
    );

    return tween.animate(
      CurvedAnimation(
        parent: animateController,
        curve: Curves.easeOut,
      ),
    );
  }

  return null;
}

/// Computing GridItem Offset (from -> end)
Offset getAnimationGridItemOffset({
  required double crossAxisSpacing,
  required double mainAxisSpacing,
  required Axis direction,
  required int crossCount,
  required Size itemSize,
  required int from,
  required int end,
}) {
  int sx = 0;
  int ex = 0;
  int sy = 0;
  int ey = 0;

  double kw = 1.0;
  double kh = 1.0;

  if (direction == Axis.vertical) {
    sx = from % crossCount;
    ex = end % crossCount;
    sy = from ~/ crossCount;
    ey = end ~/ crossCount;

    kw = (itemSize.width + crossAxisSpacing) / itemSize.width;
    kh = (itemSize.height + mainAxisSpacing) / itemSize.height;
  }

  if (direction == Axis.horizontal) {
    sx = from ~/ crossCount;
    ex = end ~/ crossCount;
    sy = from % crossCount;
    ey = end % crossCount;

    kw = (itemSize.width + mainAxisSpacing) / itemSize.width;
    kh = (itemSize.height + crossAxisSpacing) / itemSize.height;
  }

  return Offset(
    (sx - ex).toDouble() * kw,
    (sy - ey).toDouble() * kh,
  );
}

/// Computing scrolling
double getScrollControllerOffset({
  required double dx,
  required double dy,
  required Offset delta,
  required Offset offset,
  required Offset scroll,
  required Size itemSize,
  required Size viewSize,
  required Axis direction,
  required ScrollPhysics physics,
  required ScrollController scrollController,
}) {
  if (physics == const NeverScrollableScrollPhysics()) {
    return 0.0;
  }

  final tx = dx + scroll.dx;
  final ty = dy + scroll.dy;
  final left = tx - offset.dx - itemSize.width / 2 - 16.0;
  final top = ty - offset.dy - itemSize.height / 2 - 16.0;

  final inx1 = left > scroll.dx;
  final iny1 = top > scroll.dy;
  final inx2 = left + itemSize.width < viewSize.width;
  final iny2 = top + itemSize.height < viewSize.height;
  final scrollExtent = scrollController.position.maxScrollExtent;
  final scollOffset = scrollController.offset;

  if (direction == Axis.vertical) {
    if (!iny1 && scollOffset > 0 && delta.dy <= 0) {
      return -min(scollOffset, 5.0);
    }

    if (!iny2 && scollOffset < scrollExtent && delta.dy >= 0) {
      return min(scrollExtent - scollOffset, 5.0);
    }
  }

  if (direction == Axis.horizontal) {
    if (!inx1 && scollOffset > 0 && delta.dx <= 0) {
      return -min(scollOffset, 5.0);
    }

    if (!inx2 && scollOffset < scrollExtent && delta.dx >= 0) {
      return min(scrollExtent - scollOffset, 5.0);
    }
  }

  return 0.0;
}

/// Computing Animation Target Index
int getAnimationTargetIndex({
  required double dx,
  required double dy,
  required int total,
  required Size itemSize,
  required Offset offset,
  required Offset scroll,
  required double crossAxisSpacing,
  required double mainAxisSpacing,
  required Axis direction,
  required int crossCount,
}) {
  int topIndex = 0;
  int leftIndex = 0;
  int targetIndex = 0;

  double newTop = 0;
  double newLeft = 0;
  double newWidth = 0;
  double newHeight = 0;

  final tx = dx + scroll.dx;
  final ty = dy + scroll.dy;
  final left = tx - offset.dx - itemSize.width / 2 - 16.0;
  final top = ty - offset.dy - itemSize.height / 2 - 16.0;

  if (direction == Axis.vertical) {
    newTop = top + mainAxisSpacing / 2;
    newLeft = left + crossAxisSpacing / 2;
    newWidth = itemSize.width + crossAxisSpacing;
    newHeight = itemSize.height + mainAxisSpacing;

    topIndex = max((newTop / newHeight).round(), 0);
    leftIndex = max((newLeft / newWidth).round(), 0);
    targetIndex = leftIndex + crossCount * topIndex;
  }

  if (direction == Axis.horizontal) {
    newTop = top + crossAxisSpacing / 2;
    newLeft = left + mainAxisSpacing / 2;
    newWidth = itemSize.width + mainAxisSpacing;
    newHeight = itemSize.height + crossAxisSpacing;

    topIndex = max((newTop / newHeight).round(), 0);
    leftIndex = max((newLeft / newWidth).round(), 0);
    targetIndex = topIndex + crossCount * leftIndex;
  }

  if (targetIndex >= total) {
    targetIndex = total - 1;
  }

  if (targetIndex < 0) {
    targetIndex = 0;
  }

  return targetIndex;
}

/// Computing Drag Grid Size
Size getDragGridSize({
  required int total,
  required Size viewSize,
  required double childAspectRatio,
  required double crossAxisSpacing,
  required double mainAxisSpacing,
  required int crossCount,
  required Axis direction,
}) {
  int line = 1;
  double width = 0.0;
  double height = 0.0;
  double ctxWidth = viewSize.width;
  double ctxHeight = viewSize.height;

  line = (total ~/ crossCount);
  line += (total % crossCount > 0 ? 1 : 0);

  if (direction == Axis.vertical) {
    width = (ctxWidth - crossAxisSpacing * (crossCount - 1)) / crossCount;
    height = width / childAspectRatio * line + mainAxisSpacing * (line - 1);
    return Size(ctxWidth, height);
  }

  if (direction == Axis.horizontal) {
    height = (ctxHeight - crossAxisSpacing * (crossCount - 1)) / crossCount;
    width = height / childAspectRatio * line + mainAxisSpacing * (line - 1);
    return Size(width, ctxHeight);
  }

  return Size.zero;
}

/// Computing GridItem Size
Size getGridItemSize({
  required int total,
  required Size gridSize,
  required double crossAxisSpacing,
  required double mainAxisSpacing,
  required int crossCount,
  required Axis direction,
}) {
  int line = 1;

  if (total > 0) {
    line = (total ~/ crossCount);
    line += (total % crossCount > 0 ? 1 : 0);
  }

  if (direction == Axis.vertical) {
    return Size(
      (gridSize.width - crossAxisSpacing * (crossCount - 1)) / crossCount,
      (gridSize.height - mainAxisSpacing * (line - 1)) / line,
    );
  }

  if (direction == Axis.horizontal) {
    return Size(
      (gridSize.width - mainAxisSpacing * (line - 1)) / line,
      (gridSize.height - crossAxisSpacing * (crossCount - 1)) / crossCount,
    );
  }

  return Size.zero;
}

/// Computing bounding
bool isOutbounding({
  required double dx,
  required double dy,
  required Offset offset,
  required Offset scroll,
  required Size itemSize,
  required Size gridSize,
}) {
  final tx = dx + scroll.dx;
  final ty = dy + scroll.dy;
  final left = tx - offset.dx - itemSize.width / 2 - 16.0;
  final top = ty - offset.dy - itemSize.height / 2 - 16.0;

  final inx = left > -itemSize.width && left < gridSize.width;
  final iny = top > -itemSize.height && top < gridSize.height;

  return !inx || !iny;
}
