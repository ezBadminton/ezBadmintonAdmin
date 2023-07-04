import 'dart:math';

import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/cubit/implicit_animated_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef AnimatedObjectItemBuilder<T extends Object> = Widget Function(
  BuildContext context,
  T element,
  Animation<double> animation,
);

class ImplicitAnimatedList<T extends Object> extends StatelessWidget {
  const ImplicitAnimatedList({
    super.key,
    required this.elements,
    required this.itemBuilder,
    this.duration,
    this.elementsEqual,
  });

  final List<T> elements;
  final AnimatedObjectItemBuilder<T> itemBuilder;
  final Duration? duration;

  /// Optional element equality function. It is used to check for changes in the
  /// [elements] list.
  ///
  /// If omitted the [Object.==] operator is used.
  final bool Function(T element1, T element2)? elementsEqual;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createCubit(),
      child: ImplicitAnimatedListBuilder<T>(
        elements: elements,
        itemBuilder: itemBuilder,
        duration: duration ?? const Duration(milliseconds: 200),
        elementsEqual: elementsEqual,
      ),
    );
  }

  ImplicitAnimatedListCubit createCubit() {
    return ImplicitAnimatedListCubit<T>();
  }
}

class ImplicitAnimatedListBuilder<T extends Object> extends StatelessWidget {
  const ImplicitAnimatedListBuilder({
    super.key,
    required this.elements,
    required this.itemBuilder,
    required this.duration,
    this.elementsEqual,
  });

  final List<T> elements;
  final AnimatedObjectItemBuilder<T> itemBuilder;
  final Duration duration;
  final bool Function(T element1, T element2)? elementsEqual;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ImplicitAnimatedListCubit>()
        as ImplicitAnimatedListCubit<T>;

    cubit.elementsChanged(elements, elementsEqual: elementsEqual);

    return BlocConsumer<ImplicitAnimatedListCubit, ImplicitAnimatedListState>(
      listenWhen: (previous, current) => previous.elements != current.elements,
      listener: (context, state) =>
          handleListChanges(state as ImplicitAnimatedListState<T>),
      builder: (context, state) {
        if (state.animatedListKey.currentState == null) {
          _initAnimatedList(state as ImplicitAnimatedListState<T>);
        }
        return AnimatedList(
          key: state.animatedListKey,
          itemBuilder: (context, index, animation) {
            return itemBuilder(
              context,
              (state.elements as List<T>)[index],
              animation,
            );
          },
        );
      },
    );
  }

  void handleListChanges(ImplicitAnimatedListState<T> state) {
    AnimatedListState listState = state.animatedListKey.currentState!;
    List<T> currentElements = List.of(state.previousElements);

    for (T element in state.removedElements) {
      Duration removeDuration = duration;
      AnimatedObjectItemBuilder<T> removeBuilder = itemBuilder;

      if (state.addedElements.contains(element)) {
        // Don't play remove animation if element is re-added
        removeDuration = Duration.zero;
        removeBuilder = (context, element, animation) => const SizedBox();
      }

      listState.removeItem(
        currentElements.indexOf(element),
        (context, animation) => removeBuilder(
          context,
          element,
          animation,
        ),
        duration: removeDuration,
      );
      currentElements.remove(element);
    }
    for (T element in state.addedElements) {
      Duration addDuration = duration;
      int insertIndex =
          min(state.elements.indexOf(element), currentElements.length);
      int removedFromIndex = state.previousElements.indexOf(element);

      if (insertIndex == removedFromIndex) {
        // Don't play add animation if element is re-added into the same index
        addDuration = Duration.zero;
      }

      listState.insertItem(
        insertIndex,
        duration: addDuration,
      );
      currentElements.add(element);
    }
  }

  void _initAnimatedList(ImplicitAnimatedListState<T> state) async {
    // Wait for first AnimatedList build
    // Afterwards the GlobalKey is accessible to handleListChanges
    await Future.delayed(Duration.zero);
    handleListChanges(state);
  }
}
