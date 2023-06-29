// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'implicit_animated_list_cubit.dart';

class ImplicitAnimatedListState<T extends Object> {
  ImplicitAnimatedListState({
    this.elements = const [],
    this.previousElements = const [],
    this.addedElements = const [],
    this.removedElements = const [],
    this.draggingIndex = -1,
    GlobalKey<AnimatedListState>? animatedListKey,
  }) : animatedListKey = animatedListKey ?? GlobalKey<AnimatedListState>();

  final GlobalKey<AnimatedListState> animatedListKey;
  final List<T> elements;
  final List<T> previousElements;
  final List<T> removedElements;
  final List<T> addedElements;

  final int draggingIndex;

  ImplicitAnimatedListState<T> copyWith({
    List<T>? elements,
    List<T>? previousElements,
    List<T>? removedElements,
    List<T>? addedElements,
    int? draggingIndex,
  }) {
    return ImplicitAnimatedListState<T>(
      elements: elements ?? this.elements,
      previousElements: previousElements ?? this.previousElements,
      removedElements: removedElements ?? this.removedElements,
      addedElements: addedElements ?? this.addedElements,
      animatedListKey: this.animatedListKey,
      draggingIndex: draggingIndex ?? this.draggingIndex,
    );
  }
}
