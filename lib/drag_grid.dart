import 'package:flutter/material.dart';
import 'package:drag_grid/drag_grid_helper.dart';
import 'package:drag_grid/drag_grid_controller.dart';

/// itemList sort is changed when dragging grid item
typedef SortChanger<T> = void Function(
  List<T> list,
);

/// grid item builder
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

/// get itemList latest sorting when dragging is finish
typedef ItemListChanger<T> = void Function(
  List<T> list,
);

/// determine itemList is changed (using in didUpdateWidget)
typedef IsItemListChanged<T> = bool Function(
  List<T> newItemList,
  List<T> oldItemList,
);

/// DragGrid State (Cache slideAnimation state and grid renderBox/size)
class _DragGridState<T> extends State<DragGrid<T>>
    with TickerProviderStateMixin {
  late final onDragEnd = widget.onDragEnd;
  late final onDragUpdate = widget.onDragUpdate;
  late final onDragStarted = widget.onDragStarted;

  late final padding = widget.padding;
  late final duration = widget.duration;
  late final physics = widget.scrollPhysics;
  late final shrinkWrap = widget.shrinkWrap;
  late final itemBuilder = widget.itemBuilder;
  late final gridController = widget.gridController ?? GridController();
  late final scrollController = widget.scrollController ?? ScrollController();
  late final sliverGridDelegate = widget.sliverGridDelegate;
  late final isItemListChanged = widget.isItemListChanged;
  late final itemListChanger = widget.itemListChanger;
  late final sortChanger = widget.sortChanger;

  late List<Animation<Offset>?> slideAnimations = [];
  late List<Animation<double>?> fadeAnimations = [];
  late AnimationController animateController;
  late int crossCount;

  int? currentIndex;
  double mainAxisSpacing = 0.0;
  double crossAxisSpacing = 0.0;
  double childAspectRatio = 1.0;
  double maxCrossAxisExtent = 0.0;
  Axis direction = Axis.vertical;

  late bool enable = widget.enable;
  late bool animation = widget.animation;
  late int itemCount = widget.itemList.length;
  late List<T> renderItems = [...widget.itemList];
  late List<T> renderCache = [...widget.itemList];

  late RenderBox renderBox;
  late Offset scroll = Offset.zero;
  late Offset offset = Offset.zero;
  late Size itemSize = Size.infinite;
  late Size gridSize = Size.infinite;
  late Size viewSize = Size.infinite;

  @override
  void initState() {
    super.initState();

    gridController.update(renderItems);

    if (sliverGridDelegate is SliverGridDelegateWithFixedCrossAxisCount) {
      mainAxisSpacing = (sliverGridDelegate as dynamic).mainAxisSpacing;
      crossAxisSpacing = (sliverGridDelegate as dynamic).crossAxisSpacing;
      childAspectRatio = (sliverGridDelegate as dynamic).childAspectRatio;
      crossCount = (sliverGridDelegate as dynamic).crossAxisCount;
      crossCount = widget.crossCount ?? crossCount;
      direction = widget.direction;
    }

    if (sliverGridDelegate is SliverGridDelegateWithMaxCrossAxisExtent) {
      mainAxisSpacing = (sliverGridDelegate as dynamic).mainAxisSpacing;
      crossAxisSpacing = (sliverGridDelegate as dynamic).crossAxisSpacing;
      childAspectRatio = (sliverGridDelegate as dynamic).childAspectRatio;
      maxCrossAxisExtent = (sliverGridDelegate as dynamic).maxCrossAxisExtent;
      direction = widget.direction;
    }

    animateController = AnimationController(
      duration: duration,
      vsync: this,
    );

    animateController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        slideAnimations.clear();
        fadeAnimations.clear();
        currentIndex = null;
      }
    });

    scrollController.addListener(() {
      scroll = Offset.zero;

      for (final position in scrollController.positions) {
        if (position.axis == Axis.vertical) {
          scroll += Offset(0, position.pixels);
        }
        if (position.axis == Axis.horizontal) {
          scroll += Offset(position.pixels, 0);
        }
      }
    });

    gridController.addListener(() {
      if (!gridController.animation) {
        setState(() {
          renderItems = [...gridController.itemList];
          renderCache = [...gridController.itemList];
          itemListChanger?.call([...renderItems]);
        });
        return;
      }

      startRunDragGridSlideAnimations(
        enable: enable,
        itemSize: itemSize,
        oldItems: renderItems,
        newItems: [...gridController.itemList],
        direction: direction,
        crossCount: crossCount,
        animateController: animateController,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        slideAnimations: slideAnimations,
        fadeAnimations: fadeAnimations,
      );

      setState(() {
        renderItems = [...gridController.itemList];
        renderCache = [...gridController.itemList];
        itemListChanger?.call([...renderItems]);
      });
    });

    callOnceFrameCallback();
  }

  @override
  dispose() {
    super.dispose();
    animateController.dispose();
  }

  @override
  void didUpdateWidget(covariant DragGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    late final newItemList = widget.itemList;
    late final oldItemList = oldWidget.itemList;
    late final isEnableChanged = oldWidget.enable != widget.enable;
    late final isLengthChanged = oldItemList.length != newItemList.length;
    late final isAnimationChanged = oldWidget.animation != widget.animation;
    late final isDirectionChanged = oldWidget.direction != widget.direction;

    late final isHasItemChanged = isItemListChanged?.call(
      newItemList,
      oldItemList,
    );

    if (isDirectionChanged == true ||
        isAnimationChanged == true ||
        isHasItemChanged == true ||
        isEnableChanged == true ||
        isLengthChanged == true) {
      setState(() {
        enable = widget.enable;
        animation = widget.animation;
        direction = widget.direction;
        itemCount = newItemList.length;
        renderItems = [...newItemList];
        renderCache = [...newItemList];

        currentIndex = null;
        gridController.update(renderItems);
        callOnceFrameCallback();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics,
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      scrollDirection: direction,
      controller: scrollController,
      gridDelegate: sliverGridDelegate,
      itemBuilder: (context, index) {
        if (!enable) {
          return itemBuilder(
            context,
            renderItems[index],
            index,
          );
        }

        final draggable = SizedBox(
          width: itemSize.width,
          height: itemSize.height,
          child: itemBuilder(context, renderItems[index], index),
        );

        return LongPressDraggable(
          data: index,
          feedback: draggable,
          child: DragTarget<int>(
            builder: (context, candidates, rejects) {
              Animation<Offset>? slideAnimation;
              Animation<double>? fadeAnimation;
              Widget target = Container();

              if (currentIndex != index) {
                target = draggable;
              }

              if (animation && fadeAnimations.isNotEmpty) {
                fadeAnimation = fadeAnimations[index];
              }

              if (animation && slideAnimations.isNotEmpty) {
                slideAnimation = slideAnimations[index];
              }

              if (animation && slideAnimation != null) {
                return SlideTransition(position: slideAnimation, child: target);
              }

              if (animation && fadeAnimation != null) {
                return FadeTransition(opacity: fadeAnimation, child: target);
              }

              return target;
            },
          ),
          dragAnchorStrategy: (draggable, context, position) {
            return Offset(
              itemSize.width / 2 + 16.0,
              itemSize.height / 2 + 16.0,
            );
          },
          onDragStarted: () {
            // fix the bug: offset is not accurate when using in Get.bottomSheet (other animation is playing)
            callOnceFrameCallback();
            onDragStarted?.call();
            currentIndex = index;
          },
          onDragUpdate: (details) {
            onDragUpdate?.call(details);

            final isOutbounded = isOutbounding(
              dx: details.globalPosition.dx,
              dy: details.globalPosition.dy,
              offset: offset,
              scroll: scroll,
              itemSize: itemSize,
              gridSize: gridSize,
            );

            final targetIndex = getAnimationTargetIndex(
              dx: details.globalPosition.dx,
              dy: details.globalPosition.dy,
              total: itemCount,
              offset: offset,
              scroll: scroll,
              itemSize: itemSize,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              crossCount: crossCount,
              direction: direction,
            );

            final scollOffset = getScrollControllerOffset(
              dx: details.globalPosition.dx,
              dy: details.globalPosition.dy,
              delta: details.delta,
              offset: offset,
              scroll: scroll,
              itemSize: itemSize,
              viewSize: viewSize,
              direction: direction,
              scrollController: scrollController,
              physics: physics,
            );

            if (isOutbounded) {
              return;
            }

            if (scollOffset != 0.0) {
              scrollController.jumpTo(scrollController.offset + scollOffset);
            }

            if (currentIndex != null && currentIndex != targetIndex) {
              slideAnimations.clear();
              fadeAnimations.clear();

              setState(() {
                final tempItems = [...renderItems];
                final dragItem = renderItems.removeAt(currentIndex!);

                renderItems.insert(
                  targetIndex,
                  dragItem,
                );

                if (enable && animation) {
                  startRunDragGridSlideAnimations(
                    enable: enable,
                    itemSize: itemSize,
                    oldItems: tempItems,
                    newItems: renderItems,
                    direction: direction,
                    crossCount: crossCount,
                    mainAxisSpacing: mainAxisSpacing,
                    crossAxisSpacing: crossAxisSpacing,
                    animateController: animateController,
                    slideAnimations: slideAnimations,
                    fadeAnimations: fadeAnimations,
                  );
                }

                sortChanger?.call([...renderItems]);
              });
            }

            currentIndex = targetIndex;
          },
          onDragEnd: (details) {
            onDragEnd?.call(details);

            final isOutbounded = isOutbounding(
              // offset + dragAnchorStrategy
              dx: details.offset.dx + (itemSize.width / 2 + 16.0),
              dy: details.offset.dy + (itemSize.height / 2 + 16.0),
              offset: offset,
              scroll: scroll,
              itemSize: itemSize,
              gridSize: gridSize,
            );

            if (!isOutbounded) {
              renderCache = [...renderItems];
              renderItems = [...renderCache];
            }

            if (isOutbounded) {
              renderItems = [...renderCache];
            }

            setState(() {
              if (currentIndex != null && currentIndex != index) {
                itemListChanger?.call([...renderItems]);
              }

              currentIndex = null;
            });
          },
        );
      },
    );
  }

  void callOnceFrameCallback() {
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      renderBox = (context.findRenderObject() as RenderBox);
      offset = renderBox.localToGlobal(Offset.zero);
      viewSize = context.size!;

      if (sliverGridDelegate is SliverGridDelegateWithMaxCrossAxisExtent) {
        if (direction == Axis.vertical) {
          final itemWidth = maxCrossAxisExtent + crossAxisSpacing;
          final totalWidth = context.size!.width + crossAxisSpacing;
          crossCount = widget.crossCount ?? (totalWidth / itemWidth).ceil();
        }

        if (direction == Axis.horizontal) {
          final itemHeight = maxCrossAxisExtent + crossAxisSpacing;
          final totalHeight = context.size!.height + crossAxisSpacing;
          crossCount = widget.crossCount ?? (totalHeight / itemHeight).ceil();
        }
      }

      gridSize = getDragGridSize(
        total: itemCount,
        viewSize: context.size!,
        crossCount: crossCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        direction: direction,
      );

      itemSize = getGridItemSize(
        total: itemCount,
        gridSize: gridSize,
        crossCount: crossCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        direction: direction,
      );

      setState(() {});
    });
  }
}

/// Dragging GridView (Using LongPressDraggable)
class DragGrid<T> extends StatefulWidget {
  const DragGrid({
    super.key,
    this.enable = true,
    this.padding = EdgeInsets.zero,
    this.animation = true,
    this.duration = const Duration(milliseconds: 500),
    this.shrinkWrap = true,
    this.crossCount,
    this.onDragEnd,
    this.onDragUpdate,
    this.onDragStarted,
    this.direction = Axis.vertical,
    this.scrollPhysics = const NeverScrollableScrollPhysics(),
    this.scrollController,
    this.gridController,
    this.sortChanger,
    this.itemListChanger,
    this.isItemListChanged,
    required this.sliverGridDelegate,
    required this.itemBuilder,
    required this.itemList,
  });

  /// LongPressDraggable onDragStarted
  final VoidCallback? onDragStarted;

  /// LongPressDraggable onDragUpdate
  final DragUpdateCallback? onDragUpdate;

  /// LongPressDraggable onDragEnd
  final DragEndCallback? onDragEnd;

  /// itemList sort is changed when dragging grid item
  final SortChanger<T>? sortChanger;

  /// get itemList latest sorting when dragging is finish
  final ItemListChanger<T>? itemListChanger;

  /// determine itemList is changed (using for didUpdateWidget)
  final IsItemListChanged<T>? isItemListChanged;

  /// GridView GridController
  final GridController<T>? gridController;

  /// GridView ScrollController
  final ScrollController? scrollController;

  /// GridView SliverGridDelegate:
  /// 1. SliverGridDelegateWithFixedCrossAxisCount
  /// 2. SliverGridDelegateWithMaxCrossAxisExtent
  final SliverGridDelegate sliverGridDelegate;

  /// GridView physics
  final ScrollPhysics scrollPhysics;

  /// GridView item builder
  final ItemBuilder<T> itemBuilder;

  /// GridView padding
  final EdgeInsets padding;

  /// GridView sideAnimation duration
  final Duration duration;

  /// GridView cross count (default: get from sliverGridDelegate)
  final int? crossCount;

  /// GridView scrollDirection (default: Axis.vertical)
  final Axis direction;

  /// GridView item list
  final List<T> itemList;

  /// GridView shrinkWrap
  final bool shrinkWrap;

  /// GridView enable animation
  final bool animation;

  /// GridView enable dragging
  final bool enable;

  @override
  State<DragGrid<T>> createState() => _DragGridState<T>();
}
