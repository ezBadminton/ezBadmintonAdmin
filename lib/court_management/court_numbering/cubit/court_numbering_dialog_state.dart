part of 'court_numbering_dialog_cubit.dart';

class CourtNumberingDialogState {
  CourtNumberingDialogState({
    this.numberingType = CourtNumberingType.gymOnly,
    this.countingType = CourtCountingType.skipUnused,
    this.numberingDirection = Axis.vertical,
  });

  final CourtNumberingType numberingType;
  final CourtCountingType countingType;
  final Axis numberingDirection;

  CourtNumberingDialogState copyWith({
    CourtNumberingType? numberingType,
    CourtCountingType? countingType,
    Axis? numberingDirection,
  }) {
    return CourtNumberingDialogState(
      numberingType: numberingType ?? this.numberingType,
      countingType: countingType ?? this.countingType,
      numberingDirection: numberingDirection ?? this.numberingDirection,
    );
  }
}
