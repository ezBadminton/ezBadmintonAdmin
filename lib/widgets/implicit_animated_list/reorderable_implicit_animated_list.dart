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
  /// The dragging ability can be turned off with the [enabled] flag.
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
    this.enabled = true,
    this.duration,
  });

  final List<T> elements;
  final DraggableItemBuilder<T> itemBuilder;
  final ReorderedDraggableItemBuilder<T>? itemReorderBuilder;
  final DraggableItemBuilder<T>? itemPlaceholderBuilder;
  final ItemBuilder<T> itemDragBuilder;
  final void Function(int from, int to)? onReorder;
  final bool enabled;
  final Duration? duration;

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
        enabled: enabled,
        duration: duration,
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
    this.enabled = true,
    this.duration,
  });

  final T element;
  final Animation<double> animation;

  final DraggableItemBuilder<T> itemBuilder;
  final ReorderedDraggableItemBuilder<T>? itemReorderBuilder;
  final DraggableItemBuilder<T>? itemPlaceholderBuilder;
  final ItemBuilder<T> itemDragBuilder;
  final void Function(int from, int to)? onReorder;
  final bool enabled;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ImplicitAnimatedListCubit>()
        as ImplicitAnimatedListCubit<T>;
    ImplicitAnimatedListState<T> state = cubit.state;

    return DragTarget(
      onAccept: (int draggedIndex) =>
          _onAcceptDraggable(state, element, draggedIndex),
      builder: (context, candidateData, rejectedData) {
        DraggableItemBuilder<T> currentItemBuilder =
            _getCurrentItemBuilder(state, element, animation);

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
              _getDraggableWrapper(cubit, element),
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

  /// Returns wether a given [element] is currently being reordered
  /// from one place in the list to another.
  ///
  /// Reordering elements are built by [itemReorderBuilder].
  bool _isReordering(
    ImplicitAnimatedListState<T> state,
    T element,
    Animation animation,
  ) {
    return state.removedElements.contains(element) &&
        state.addedElements.contains(element) &&
        !animation.isCompleted;
  }

  /// Returns the change in index of a reordering [element].
  ///
  /// An element moving from index `3` to `1` has an index delta of `-2`.
  /// This is useful for the [itemReorderBuilder] to animate the reorder.
  ///
  /// Returns 0 if the element is not currently reordering.
  int _getIndexDelta(
    ImplicitAnimatedListState<T> state,
    T element,
  ) {
    int indexBeforeReorder = state.previousElements.indexOf(element);
    int indexAfterReorder = state.elements.indexOf(element);
    if (indexBeforeReorder == -1 || indexAfterReorder == -1) {
      return 0;
    }

    int indexDelta = indexAfterReorder - indexBeforeReorder;
    return indexDelta;
  }

  /// Returns the [DraggableItemBuilder] that is currently responsible for
  /// building the [Widget] representing [element] in the animated list.
  ///
  /// In the basic case of no current interaction [itemBuilder] is returned.
  /// When the element is being dragged the [itemPlaceholderBuilder]
  /// is returned.
  /// When the element is being reordered (according to [_isReordering])
  /// [itemReorderBuilder] is returned.
  ///
  /// If [itemPlaceholderBuilder] or [itemReorderBuilder] are `null`,
  /// [itemBuilder] is the fallback.
  ///
  /// The [animation] is being controlled by the underlying [AnimatedList]. It
  /// runs each time the element is added, removed (backwards in this case)
  /// or reordered.
  DraggableItemBuilder<T> _getCurrentItemBuilder(
    ImplicitAnimatedListState<T> state,
    T element,
    Animation<double> animation,
  ) {
    int elementIndex = state.elements.indexOf(element);
    int draggingIndex = state.draggingIndex;

    DraggableItemBuilder<T> currentItemBuilder = itemBuilder;

    if (_isReordering(state, element, animation) &&
        itemReorderBuilder != null) {
      int indexDelta = _getIndexDelta(state, element);

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
    } else if (elementIndex == draggingIndex &&
        itemPlaceholderBuilder != null) {
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
    T element,
  ) {
    int elementIndex = cubit.state.elements.indexOf(element);

    draggableWrapper(BuildContext context, Widget child) => Draggable<int>(
          key: _DraggableKey(element),
          data: elementIndex,
          dragAnchorStrategy: (draggable, context, position) =>
              const Offset(100, 0),
          feedback: itemDragBuilder(context, element),
          maxSimultaneousDrags: enabled ? 1 : 0,
          onDragStarted: () {
            cubit.dragStarted(elementIndex);
          },
          onDragEnd: (_) {
            cubit.dragEnded();
          },
          child: child,
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
    T element,
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
      endIndent: 30,
    );
  }
}

class _DraggableKey extends GlobalObjectKey {
  const _DraggableKey(super.value);
}
