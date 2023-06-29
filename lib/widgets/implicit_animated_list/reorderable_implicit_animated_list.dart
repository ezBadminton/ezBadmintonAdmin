import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/cubit/implicit_animated_list_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/implicit_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef DraggableWrapper = Draggable Function(Widget child);

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
    extends ImplicitAnimatedList<T> {
  ReorderableImplicitAnimatedList({
    super.key,
    required super.elements,
    required DraggableItemBuilder<T> itemBuilder,
    required ReorderedDraggableItemBuilder<T> itemReorderBuilder,
    required ItemBuilder<T> itemDragBuilder,
    required ItemBuilder<T> itemPlaceholderBuilder,
    void Function(int from, int to)? onReorder,
    this.enabled = true,
    super.duration,
  }) : super(
            itemBuilder: _reorderableItemBuilder(
          itemBuilder,
          itemReorderBuilder,
          itemDragBuilder,
          itemPlaceholderBuilder,
          onReorder,
          enabled,
        ));

  final bool enabled;

  static Widget Function(
    BuildContext context,
    T element,
    Animation<double> animation,
  ) _reorderableItemBuilder<T extends Object>(
    DraggableItemBuilder<T> itemBuilder,
    ReorderedDraggableItemBuilder<T> itemReorderBuilder,
    ItemBuilder<T> itemDragBuilder,
    ItemBuilder<T> itemPlaceholderBuilder,
    void Function(int from, int to)? onReorder,
    bool enabled,
  ) {
    return (BuildContext context, T element, Animation<double> animation) {
      var cubit = context.read<ImplicitAnimatedListCubit>();
      ImplicitAnimatedListState state = cubit.state;
      int index = state.elements.indexOf(element);
      assert(index >= 0);
      int draggingIndex = state.draggingIndex;

      DraggableItemBuilder<T> currentItemBuilder = itemBuilder;

      if (state.removedElements.contains(element) &&
          state.addedElements.contains(element) &&
          !animation.isCompleted) {
        int indexBeforeReorder = state.previousElements.indexOf(element);
        int indexAfterReorder = state.elements.indexOf(element);
        assert(indexBeforeReorder >= 0);
        assert(indexAfterReorder >= 0);

        int indexDelta = indexAfterReorder - indexBeforeReorder;

        currentItemBuilder = (
          context,
          element,
          animation,
          draggableWrapper,
        ) =>
            itemReorderBuilder(
              context,
              element,
              animation,
              draggableWrapper,
              indexDelta,
            );
      }

      draggableWrapper(child) => Draggable<int>(
            key: _DraggableKey(element),
            data: index,
            dragAnchorStrategy: (draggable, context, position) =>
                const Offset(100, 0),
            feedback: itemDragBuilder(context, element),
            maxSimultaneousDrags: enabled ? 1 : 0,
            onDragStarted: () {
              cubit.dragStarted(index);
            },
            onDragEnd: (_) {
              cubit.dragEnded();
            },
            child: child,
          );

      return DragTarget(
        onAccept: (int draggedIndex) {
          if (draggedIndex != index) {
            if (onReorder != null) {
              onReorder(draggedIndex, index);
            }
          }
        },
        builder: (context, candidateData, rejectedData) {
          Widget dragTargetIndicator = Divider(
            color: Theme.of(context).primaryColor,
            height: 2,
            thickness: 2,
            indent: 2,
            endIndent: 30,
          );

          return Column(
            children: [
              if (candidateData.isNotEmpty && index < draggingIndex)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: dragTargetIndicator,
                )
              else
                const SizedBox(height: 6),
              Row(
                children: [
                  if (draggingIndex == index) ...[
                    Expanded(child: itemPlaceholderBuilder(context, element)),
                    draggableWrapper(const Icon(Icons.unfold_more)),
                  ] else
                    Expanded(
                      child: currentItemBuilder(
                        context,
                        element,
                        animation,
                        draggableWrapper,
                      ),
                    ),
                ],
              ),
              if (candidateData.isNotEmpty && index > draggingIndex)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: dragTargetIndicator,
                )
              else
                const SizedBox(height: 10),
            ],
          );
        },
      );
    };
  }

  @override
  ImplicitAnimatedListCubit createCubit() {
    return ImplicitAnimatedListCubit<T>(reorderable: true);
  }
}

class _DraggableKey extends GlobalObjectKey {
  const _DraggableKey(super.value);
}
