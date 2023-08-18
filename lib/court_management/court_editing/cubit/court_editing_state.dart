part of 'court_editing_cubit.dart';

class CourtEditingState extends CollectionFetcherState<CourtEditingState> {
  CourtEditingState({
    this.loadingStatus = LoadingStatus.done,
    this.formStatus = FormzSubmissionStatus.initial,
    this.gymnasium = const SelectionInput.pure(emptyAllowed: true, value: null),
    this.courts = const [],
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final SelectionInput<Gymnasium> gymnasium;
  final List<Court> courts;

  CourtEditingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    SelectionInput<Gymnasium>? gymnasium,
    List<Court>? courts,
    Map<Type, List<Model>>? collections,
  }) {
    return CourtEditingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      gymnasium: gymnasium ?? this.gymnasium,
      courts: courts ?? this.courts,
      collections: collections ?? this.collections,
    );
  }
}
