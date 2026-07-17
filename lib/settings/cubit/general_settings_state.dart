part of 'general_settings_cubit.dart';

class GeneralSettingsState extends CollectionQuerierState {
  GeneralSettingsState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  @override
  final List<List<Model>> collections;

  TournamentEvent get tournament => getCollection<TournamentEvent>().first;

  /// The title of the tournament, shown e.g. in the header of printed plans.
  String get tournamentTitle => getCollection<TournamentEvent>().first.title;

  GeneralSettingsState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    List<List<Model>>? collections,
  }) {
    return GeneralSettingsState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      collections: collections ?? this.collections,
    );
  }
}
