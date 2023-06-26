import 'dart:math';

import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/cubit/implicit_animated_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImplicitAnimatedList<T> extends StatelessWidget {
  const ImplicitAnimatedList({
    super.key,
    required this.elements,
    required this.itemBuilder,
    this.duration,
  });

  final List<T> elements;
  final Widget Function(T element, Animation<double> animation) itemBuilder;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createCubit(),
      child: ImplicitAnimatedListBuilder<T>(
        elements: elements,
        itemBuilder: itemBuilder,
        duration: duration ?? const Duration(milliseconds: 200),
      ),
    );
  }

  ImplicitAnimatedListCubit createCubit() {
    return ImplicitAnimatedListCubit<T>();
  }
}

class ImplicitAnimatedListBuilder<T> extends StatelessWidget {
  const ImplicitAnimatedListBuilder({
    super.key,
    required this.elements,
    required this.itemBuilder,
    required this.duration,
  });

  final List<T> elements;
  final Widget Function(T element, Animation<double> animation) itemBuilder;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<ImplicitAnimatedListCubit>();

    if ((elements.isNotEmpty || cubit.state.elements.isNotEmpty) &&
        elements != cubit.state.elements) {
      cubit.elementsChanged(elements);
    }

    return BlocConsumer<ImplicitAnimatedListCubit, ImplicitAnimatedListState>(
      listener: (context, state) => handleListChanges(state),
      builder: (context, state) => AnimatedList(
        key: state.animatedListKey,
        itemBuilder: (context, index, animation) {
          return itemBuilder(state.elements[index], animation);
        },
      ),
    );
  }

  void handleListChanges(ImplicitAnimatedListState state) {
    AnimatedListState listState = state.animatedListKey.currentState!;
    List<T> currentElements = List.of(state.previousElements as List<T>);

    for (T element in state.removedElements) {
      listState.removeItem(
        currentElements.indexOf(element),
        (context, animation) => itemBuilder(
          element,
          animation,
        ),
        duration: duration,
      );
      currentElements.remove(element);
    }
    for (T element in state.addedElements) {
      listState.insertItem(
        min(state.elements.indexOf(element), currentElements.length),
        duration: duration,
      );
      currentElements.add(element);
    }
  }
}
