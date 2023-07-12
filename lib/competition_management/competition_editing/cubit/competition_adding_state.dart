part of 'competition_adding_cubit.dart';

class CompetitionAddingState
    extends CollectionFetcherState<CompetitionAddingState> {
  const CompetitionAddingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.ageGroups = const [],
    this.playingLevels = const [],
    this.competitionCategories = CompetitionCategory.defaultCompetitions,
    this.disabledAgeGroups = const [],
    this.disabledPlayingLevels = const [],
    this.disabledCompetitionCategories = const [],
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final List<AgeGroup> ageGroups;
  final List<PlayingLevel> playingLevels;
  final List<CompetitionCategory> competitionCategories;

  final List<AgeGroup> disabledAgeGroups;
  final List<PlayingLevel> disabledPlayingLevels;
  final List<CompetitionCategory> disabledCompetitionCategories;

  CompetitionAddingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    List<AgeGroup>? ageGroups,
    List<PlayingLevel>? playingLevels,
    List<CompetitionCategory>? competitionCategories,
    List<AgeGroup>? disabledAgeGroups,
    List<PlayingLevel>? disabledPlayingLevels,
    List<CompetitionCategory>? disabledCompetitionCategories,
    Map<Type, List<Model>>? collections,
  }) {
    return CompetitionAddingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      ageGroups: ageGroups ?? this.ageGroups,
      playingLevels: playingLevels ?? this.playingLevels,
      competitionCategories:
          competitionCategories ?? this.competitionCategories,
      disabledAgeGroups: disabledAgeGroups ?? this.disabledAgeGroups,
      disabledPlayingLevels:
          disabledPlayingLevels ?? this.disabledPlayingLevels,
      disabledCompetitionCategories:
          disabledCompetitionCategories ?? this.disabledCompetitionCategories,
      collections: collections ?? this.collections,
    );
  }
}
