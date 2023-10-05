part of 'bracket_section_navigator_cubit.dart';

class BracketSectionNavigatorState extends Equatable {
  const BracketSectionNavigatorState({
    this.horizontalOffset = 0,
    this.visibleWidth = 99999,
  });

  final double horizontalOffset;
  final double visibleWidth;

  @override
  List<Object> get props => [
        horizontalOffset,
        visibleWidth,
      ];
}
