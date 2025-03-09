// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'court_renaming_cubit.dart';

class CourtRenamingState {
  CourtRenamingState({
    this.formStatus = FormzSubmissionStatus.initial,
    required this.court,
    this.isFormOpen = false,
    this.name = const NonEmptyInput.pure(),
  });

  final FormzSubmissionStatus formStatus;
  final Court court;
  final bool isFormOpen;
  final NonEmptyInput name;

  CourtRenamingState copyWith({
    FormzSubmissionStatus? formStatus,
    Court? court,
    bool? isFormOpen,
    NonEmptyInput? name,
  }) {
    return CourtRenamingState(
      formStatus: formStatus ?? this.formStatus,
      court: court ?? this.court,
      isFormOpen: isFormOpen ?? this.isFormOpen,
      name: name ?? this.name,
    );
  }
}
