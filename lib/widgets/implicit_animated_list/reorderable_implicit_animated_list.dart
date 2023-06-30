import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/cubit/implicit_animated_list_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/implicit_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef DraggableWrapper = Draggable Function(
  BuildContext context,
  Widget child,
);

typedef DraggableItemBuilder<T extends Object> = Widget Function(
  BuildContext context,
  T element,
  Animation<double> animation,
  DraggableWrapper draggableWrapper,
);

typedef ReorderedDraggableItemBuilder<T extends Object> = Widget Function(
  BuildContext context,
  T element,
  Animation<double> animation,
  DraggableWrapper draggableWrapper,
  int indexDelta,
);

typedef ItemBuilder<T extends Object> = Widget Function(
  BuildContext context,
  T element,
);

class ReorderableImplicitAnimatedList<T extends Object>
    extends StatelessWidget {
  /// A reorderable, animated list with draggable items.
  ///
  /// They can be dragged onto other items to reorder the list.
  ///
  /// Each of the [elements] is wrapped by one of the builders
  /// to display the list items.
  /// Rebuilding this widget with a changed [elements] List implicitly
  /// animates adding, removing and reordering of the element's list items.
  ///
  /// While not dragged, the items are built by [itemBuilder].
  ///
  /// While dragged, the Widget on the cursor is built by [itemDragBuilder]
  /// and the item in the list is built by [itemPlaceholderBuilder].
  ///
  /// While in a reorder animation, items are built by [itemReorderBuilder].
  ///
  /// If [itemPlaceholderBuilder] or [itemReorderBuilder] are `null`,
  /// [itemBuilder] is the fallback.
  ///
  /// [onReorder] is called with the dragged item's old and new index.
  ///
  /// The dragging ability can be turned off with the [draggingEnabled] flag.
  ///
  /// The animations that the builders receive run for [duration].
  const ReorderableImplicitAnimatedList({
    super.key,
    required this.elements,
    required this.itemBuilder,
    this.itemReorderBuilder,
    this.itemPlaceholderBuilder,
    required this.itemDragBuilder,
    this.onReorder,
    this.draggingEnabled = true,
    this.duration,
    this.reorderTooltip,
  });

  final List<T> elements;

  /// Builds the items when they are added or removed.
  ///
  /// Use the given [Animation] to drive the add/remove transition.
  /// The animation plays backwards when the element is removed.
  ///
  /// If the item is supposed to be reorderable by drag & drop, the given
  /// [DraggableWrapper] has to  be used to wrap an area or the entire item.
  final DraggableItemBuilder<T> itemBuilder;

  /// Builds the items when they are reordered.
  ///
  /// Use the given [Animation] to drive the reorder transition.
  /// The [indexDelta] provides the amount of places that the element moved
  /// because of the reorder.
  /// E.g. an item that moves from index `3` to `1` has
  /// an index delta of `-2`. This can be used to animate a transition that
  /// moves the item to its new position in the list.
  ///
  /// The item should be the same as with [itemBuilder] just with
  /// different transition animation.
  final ReorderedDraggableItemBuilder<T>? itemReorderBuilder;

  /// Builds the items while they are dragged.
  ///
  /// The given [DraggableWrapper] still has to be part of the build to keep it
  /// in the widget tree. Otherwise the other items can't accept the Draggable.
  ///
  /// If the drag is cancelled it goes back to [itemBuilder].
  /// If the drag ends in a reorder it goes to [itemReorderBuilder].
  final DraggableItemBuilder<T>? itemPlaceholderBuilder;

  /// Builds the widget that sticks to the cursor during dragging.
  final ItemBuilder<T> itemDragBuilder;

  /// Is called when a reorder happens due to drag and drop.
  final void Function(int from, int to)? onReorder;

  final bool draggingEnabled;

  /// Duration of the transition animations.
  final Duration? duration;

  final String? reorderTooltip;

  @override
  Widget build(BuildContext context) {
    reorderableItemBuilder(
      BuildContext context,
      T element,
      Animation<double> animation,
    ) {
      return _ReorderableItem<T>(
        element: element,
        animation: animation,
        itemBuilder: itemBuilder,
        itemReorderBuilder: itemReorderBuilder,
        itemPlaceholderBuilder: itemPlaceholderBuilder,
        itemDragBuilder: itemDragBuilder,
        onReorder: onReorder,
        draggingEnabled: draggingEnabled,
        duration: duration,
        reorderTooltip: reorderTooltip,
      );
    }

    return _ReorderableImplicitAnimatedList<T>(
      key: key,
      elements: elements,
      itemBuilder: reorderableItemBuilder,
      duration: duration,
    );
  }
}

class _ReorderableImplicitAnimatedList<T extends Object>
    extends ImplicitAnimatedList<T> {
  // ImplicitAnimatedList with
  // reorderable = true on the ImplicitAnimatedListCubit
  const _ReorderableImplicitAnimatedList({
    super.key,
    required super.elements,
    required super.itemBuilder,
    super.duration,
  });

  @override
  ImplicitAnimatedListCubit createCubit() {
    return ImplicitAnimatedListCubit<T>(reorderable: true);
  }
}

class _ReorderableItem<T extends Object> extends StatelessWidget {
  const _ReorderableItem({
    required this.element,
    required this.animation,
    required this.itemBuilder,
    this.itemReorderBuilder,
    this.itemPlaceholderBuilder,
    required this.itemDragBuilder,
    this.onReorder,
    this.draggingEnabled = true,
    this.duration,
    this.reorderTooltip,
  });

  final T element;

  /// The animation is being controlled by the underlying [AnimatedList]
  ///
  /// It plays on add, remove (backwards in this case) and reorder of the item.
  final Animation<double> animation;

  final DraggableItemBuilder<T> itemBuilder;
  final ReorderedDraggableItemBuilder<T>? itemReorderBuilder;
  final DraggableItemBuilder<T>? itemPlaceholderBuilder;
  final ItemBuilder<T> itemDragBuilder;
  final void Function(int from, int to)? onReorder;
  final bool draggingEnabled;
  final Duration? duration;

  final String? reorderTooltip;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ImplicitAnimatedListCubit>()
        as ImplicitAnimatedListCubit<T>;
    ImplicitAnimatedListState<T> state = cubit.state;

    return DragTarget(
      onAccept: (int draggedIndex) => _onAcceptDraggable(state, draggedIndex),
      builder: (context, candidateData, rejectedData) {
        DraggableItemBuilder<T> currentItemBuilder =
            _getCurrentItemBuilder(state);

        return Column(
          children: [
            _ReorderableItemGap(
              dropCandidates: candidateData,
              state: state,
              element: element,
              top: true,
            ),
            currentItemBuilder(
              context,
              element,
              animation,
              _getDraggableWrapper(cubit),
            ),
            _ReorderableItemGap(
              dropCandidates: candidateData,
              state: state,
              element: element,
              top: false,
            ),
          ],
        );
      },
    );
  }

  /// Returns wether the item is currently being reordered
  /// from one place in the list to another.
  ///
  /// Reordering elements are built by [itemReorderBuilder].
  bool _isReordering(
    ImplicitAnimatedListState<T> state,
  ) {
    return state.removedElements.contains(element) &&
        state.addedElements.contains(element) &&
        !animation.isCompleted;
  }

  /// Returns wether the item is currently being dragged by the cursor.
  bool _isDragged(
    ImplicitAnimatedListState<T> state,
  ) {
    int elementIndex = state.elements.indexOf(element);

    return state.draggingIndex != -1 && elementIndex == state.draggingIndex;
  }

  /// Returns the change in index when reordering.
  ///
  /// The item moving from index `3` to `1` makes an index delta of `-2`.
  /// This is useful for the [itemReorderBuilder] to animate the reorder.
  ///
  /// Returns 0 if the item is not currently reordering.
  int _getIndexDelta(
    ImplicitAnimatedListState<T> state,
  ) {
    int from = state.previousElements.indexOf(element);
    int to = state.elements.indexOf(element);
    if (from == -1 || to == -1) {
      return 0;
    }

    int indexDelta = to - from;
    return indexDelta;
  }

  /// Returns the [DraggableItemBuilder] that is currently responsible for
  /// building the item.
  ///
  /// In the basic case of no current interaction [itemBuilder] is returned.
  /// When the element is being dragged the [itemPlaceholderBuilder]
  /// is returned.
  /// When the element is being reordered [itemReorderBuilder] is returned.
  ///
  /// If [itemPlaceholderBuilder] or [itemReorderBuilder] are `null`,
  /// [itemBuilder] is the fallback.
  DraggableItemBuilder<T> _getCurrentItemBuilder(
    ImplicitAnimatedListState<T> state,
  ) {
    DraggableItemBuilder<T> currentItemBuilder = itemBuilder;

    if (_isReordering(state) && itemReorderBuilder != null) {
      int indexDelta = _getIndexDelta(state);

      currentItemBuilder = (
        context,
        element,
        animation,
        draggableWrapper,
      ) =>
          itemReorderBuilder!(
            context,
            element,
            animation,
            draggableWrapper,
            indexDelta,
          );
    } else if (_isDragged(state) && itemPlaceholderBuilder != null) {
      currentItemBuilder = itemPlaceholderBuilder!;
    }

    return currentItemBuilder;
  }

  /// Returns a Wrapper making its child a [Draggable] that contains the
  /// [element]'s index as data.
  ///
  /// [itemBuilder] and [itemPlaceholderBuilder] have to use this to make a
  /// draggable area if the item is supposed to be reorderable via drag & drop.
  ///
  /// The [itemDragBuilder] is used to build the widget that moves with the
  /// cursor during dragging.
  DraggableWrapper _getDraggableWrapper(
    ImplicitAnimatedListCubit<T> cubit,
  ) {
    int elementIndex = cubit.state.elements.indexOf(element);

    draggableWrapper(BuildContext context, Widget child) => Draggable<int>(
          key: _DraggableKey(element),
          data: elementIndex,
          dragAnchorStrategy: (draggable, context, position) =>
              const Offset(0, 0),
          feedback: itemDragBuilder(context, element),
          maxSimultaneousDrags: draggingEnabled ? 1 : 0,
          onDragStarted: () {
            cubit.dragStarted(elementIndex);
          },
          onDragEnd: (_) {
            cubit.dragEnded();
          },
          child: Tooltip(
            message: reorderTooltip ?? '',
            triggerMode: TooltipTriggerMode.manual,
            waitDuration: const Duration(milliseconds: 500),
            child: child,
          ),
        );

    return draggableWrapper;
  }

  /// Handles dropping a dragged element onto another [element] by calling
  /// [onReorder].
  ///
  /// The [draggedIndex] contains the index of the dragged element.
  ///
  /// Does nothing if [onReorder] is null.
  void _onAcceptDraggable(
    ImplicitAnimatedListState<T> state,
    int draggedIndex,
  ) {
    if (onReorder != null) {
      int elementIndex = state.elements.indexOf(element);
      if (draggedIndex != elementIndex) {
        onReorder!(draggedIndex, elementIndex);
      }
    }
  }
}

class _ReorderableItemGap<T extends Object> extends StatelessWidget {
  /// A gap between reorderable items that highlights the position where a
  /// hovering item will land if dropped there.
  _ReorderableItemGap({
    required this.dropCandidates,
    required ImplicitAnimatedListState<T> state,
    required T element,
    required this.top,
  })  : elementIndex = state.elements.indexOf(element),
        draggingIndex = state.draggingIndex;

  final List<Object?> dropCandidates;
  final int elementIndex;
  final int draggingIndex;

  final bool top;

  @override
  Widget build(BuildContext context) {
    if (top) {
      if (dropCandidates.isNotEmpty && elementIndex < draggingIndex) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 4),
          child: _ReorderIndicator(),
        );
      } else {
        return const SizedBox(height: 6);
      }
    } else {
      if (dropCandidates.isNotEmpty && elementIndex > draggingIndex) {
        return const Padding(
          padding: EdgeInsets.only(top: 8),
          child: _ReorderIndicator(),
        );
      } else {
        return const SizedBox(height: 10);
      }
    }
  }
}

class _ReorderIndicator extends StatelessWidget {
  const _ReorderIndicator();

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).primaryColor,
      height: 2,
      thickness: 2,
      indent: 2,
      endIndent: 85,
    );
  }
}

class _DraggableKey extends GlobalObjectKey {
  const _DraggableKey(super.value);
}
