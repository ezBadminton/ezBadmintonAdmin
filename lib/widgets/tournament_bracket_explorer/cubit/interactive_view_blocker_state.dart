part of 'interactive_view_blocker_cubit.dart';

class InteractiveViewBlockerState extends Equatable {
  const InteractiveViewBlockerState({
    this.zoomingBlocks = 0,
    this.edgePanningBlocks = 1,
  });

  final int zoomingBlocks;
  final int edgePanningBlocks;

  bool get isZoomBlocked => zoomingBlocks > 0;
  bool get isEdgePanBlocked => edgePanningBlocks > 0;

  @override
  List<Object> get props => [zoomingBlocks, edgePanningBlocks];

  InteractiveViewBlockerState copyWith({
    int? zoomingBlocks,
    int? edgePanningBlocks,
  }) {
    return InteractiveViewBlockerState(
      zoomingBlocks: zoomingBlocks ?? this.zoomingBlocks,
      edgePanningBlocks: edgePanningBlocks ?? this.edgePanningBlocks,
    );
  }
}
