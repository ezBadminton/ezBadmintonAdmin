part of 'court_editing_cubit.dart';

class CourtEditingState extends CollectionFetcherState<CourtEditingState> {
  CourtEditingState({
    this.loadingStatus = LoadingStatus.done,
    this.formStatus = FormzSubmissionStatus.initial,
    this.gymnasium = const SelectionInput.pure(emptyAllowed: true, value: null),
    this.court = const SelectionInput.pure(emptyAllowed: true, value: null),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final SelectionInput<Gymnasium> gymnasium;
  final SelectionInput<Court> court;

  CourtEditingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    SelectionInput<Gymnasium>? gymnasium,
    SelectionInput<Court>? court,
    Map<Type, List<Model>>? collections,
  }) {
    return CourtEditingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      gymnasium: gymnasium ?? this.gymnasium,
      court: court ?? this.court,
      collections: collections ?? this.collections,
    );
  }
}
