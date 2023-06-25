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
      create: (context) => ImplicitAnimatedListCubit(),
      child: _ImplicitAnimatedList<T>(
        elements: elements,
        itemBuilder: itemBuilder,
        duration: duration ?? const Duration(milliseconds: 200),
      ),
    );
  }
}

class _ImplicitAnimatedList<T> extends StatelessWidget {
  const _ImplicitAnimatedList({
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
      listener: (context, state) {
        for (int index in state.removedIndices) {
          state.animatedListKey.currentState!.removeItem(
            index,
            (context, animation) => itemBuilder(
              state.previousElements[index],
              animation,
            ),
            duration: duration,
          );
        }
        for (int index in state.addedIndices) {
          state.animatedListKey.currentState!.insertItem(
            index,
            duration: duration,
          );
        }
      },
      builder: (context, state) {
        AnimatedList animatedList = AnimatedList(
          key: state.animatedListKey,
          itemBuilder: (context, index, animation) {
            return itemBuilder(state.elements[index], animation);
          },
        );

        return animatedList;
      },
    );
  }
}
