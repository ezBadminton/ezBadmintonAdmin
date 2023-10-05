part of 'interactive_view_blocker_cubit.dart';

class InteractiveViewBlockerState extends Equatable {
  const InteractiveViewBlockerState({
    this.blocks = 0,
  });

  final int blocks;

  bool get isBlocked => blocks > 0;

  @override
  List<Object> get props => [blocks];
}
