part of 'competition_adding_cubit.dart';

class CompetitionAddingState
    extends CollectionFetcherState<CompetitionAddingState> {
  CompetitionAddingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.ageGroups = const [],
    this.playingLevels = const [],
    this.competitionCategories = CompetitionDiscipline.baseCompetitions,
    this.disabledAgeGroups = const {},
    this.disabledPlayingLevels = const {},
    this.disabledCompetitionCategories = const {},
    super.collections = const {},
  }) : submittable = _isSubmittable(
          collections[Tournament]?.first as Tournament?,
          ageGroups,
          playingLevels,
          competitionCategories,
        );

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final List<AgeGroup> ageGroups;
  final List<PlayingLevel> playingLevels;
  final List<CompetitionDiscipline> competitionCategories;

  final Set<AgeGroup> disabledAgeGroups;
  final Set<PlayingLevel> disabledPlayingLevels;
  final Set<CompetitionDiscipline> disabledCompetitionCategories;

  final bool submittable;

  CompetitionAddingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    List<AgeGroup>? ageGroups,
    List<PlayingLevel>? playingLevels,
    List<CompetitionDiscipline>? competitionCategories,
    Set<AgeGroup>? disabledAgeGroups,
    Set<PlayingLevel>? disabledPlayingLevels,
    Set<CompetitionDiscipline>? disabledCompetitionCategories,
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

  static bool _isSubmittable(
    Tournament? tournament,
    List<AgeGroup> ageGroups,
    List<PlayingLevel> playingLevels,
    List<CompetitionDiscipline> competitionCategories,
  ) {
    if (tournament == null) {
      return false;
    }
    bool useAgeGroups = tournament.useAgeGroups;
    bool usePlayingLevels = tournament.usePlayingLevels;

    return useAgeGroups == ageGroups.isNotEmpty &&
        usePlayingLevels == playingLevels.isNotEmpty &&
        competitionCategories.isNotEmpty;
  }
}
