part of 'tournament_mode_assignment_cubit.dart';

class TournamentModeAssignmentState with FormzMixin implements DialogState {
  TournamentModeAssignmentState({
    required this.competitions,
    this.formStatus = FormzSubmissionStatus.initial,
    this.modeType = const SelectionInput.pure(value: null),
    this.modeSettings = const SelectionInput.pure(value: null),
    this.dialog = const CubitDialog(),
  });

  final List<Competition> competitions;

  final FormzSubmissionStatus formStatus;

  final SelectionInput<Type> modeType;
  final SelectionInput<TournamentModeSettings> modeSettings;

  @override
  final CubitDialog dialog;

  TournamentModeAssignmentState copyWith({
    List<Competition>? competitions,
    FormzSubmissionStatus? formStatus,
    SelectionInput<Type>? modeType,
    SelectionInput<TournamentModeSettings>? modeSettings,
    CubitDialog? dialog,
  }) {
    return TournamentModeAssignmentState(
      competitions: competitions ?? this.competitions,
      formStatus: formStatus ?? this.formStatus,
      modeType: modeType ?? this.modeType,
      modeSettings: modeSettings ?? this.modeSettings,
      dialog: dialog ?? this.dialog,
    );
  }

  @override
  List<FormzInput> get inputs => [modeSettings];
}
