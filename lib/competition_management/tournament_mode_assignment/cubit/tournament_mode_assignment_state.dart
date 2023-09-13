part of 'tournament_mode_assignment_cubit.dart';

class TournamentModeAssignmentState with FormzMixin {
  TournamentModeAssignmentState({
    this.formStatus = FormzSubmissionStatus.initial,
    this.modeType = const SelectionInput.pure(value: null),
    this.modeSettings = const SelectionInput.pure(value: null),
  });

  final FormzSubmissionStatus formStatus;

  final SelectionInput<Type> modeType;
  final SelectionInput<TournamentModeSettings> modeSettings;

  TournamentModeAssignmentState copyWith({
    FormzSubmissionStatus? formStatus,
    SelectionInput<Type>? modeType,
    SelectionInput<TournamentModeSettings>? modeSettings,
  }) {
    return TournamentModeAssignmentState(
      formStatus: formStatus ?? this.formStatus,
      modeType: modeType ?? this.modeType,
      modeSettings: modeSettings ?? this.modeSettings,
    );
  }

  @override
  List<FormzInput> get inputs => [modeSettings];
}
