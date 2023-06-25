// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'implicit_animated_list_cubit.dart';

class ImplicitAnimatedListState<T> {
  ImplicitAnimatedListState({
    this.elements = const [],
    this.previousElements = const [],
    this.addedIndices = const [],
    this.removedIndices = const [],
    GlobalKey<AnimatedListState>? animatedListKey,
  }) : animatedListKey = animatedListKey ?? GlobalKey<AnimatedListState>();

  final GlobalKey<AnimatedListState> animatedListKey;
  final List<T> elements;
  final List<T> previousElements;
  final Iterable<int> removedIndices;
  final Iterable<int> addedIndices;

  ImplicitAnimatedListState<T> copyWith({
    List<T>? elements,
    List<T>? previousElements,
    Iterable<int>? removedIndices,
    Iterable<int>? addedIndices,
  }) {
    return ImplicitAnimatedListState<T>(
      elements: elements ?? this.elements,
      previousElements: previousElements ?? this.previousElements,
      removedIndices: removedIndices ?? this.removedIndices,
      addedIndices: addedIndices ?? this.addedIndices,
      animatedListKey: this.animatedListKey,
    );
  }
}
