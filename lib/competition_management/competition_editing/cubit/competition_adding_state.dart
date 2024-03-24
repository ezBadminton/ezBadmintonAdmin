part of 'competition_adding_cubit.dart';

class CompetitionAddingState extends CollectionQuerierState {
  CompetitionAddingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.ageGroups = const [],
    this.playingLevels = const [],
    this.competitionDisciplines = CompetitionDiscipline.baseCompetitions,
    this.disabledAgeGroups = const {},
    this.disabledPlayingLevels = const {},
    this.disabledCompetitionDisciplines = const {},
    this.formSubmittable = false,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final List<AgeGroup> ageGroups;
  final List<PlayingLevel> playingLevels;
  final List<CompetitionDiscipline> competitionDisciplines;

  final Set<AgeGroup> disabledAgeGroups;
  final Set<PlayingLevel> disabledPlayingLevels;
  final Set<CompetitionDiscipline> disabledCompetitionDisciplines;

  final bool formSubmittable;

  @override
  final List<List<Model>> collections;

  CompetitionAddingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    List<AgeGroup>? ageGroups,
    List<PlayingLevel>? playingLevels,
    List<CompetitionDiscipline>? competitionDisciplines,
    Set<AgeGroup>? disabledAgeGroups,
    Set<PlayingLevel>? disabledPlayingLevels,
    Set<CompetitionDiscipline>? disabledCompetitionDisciplines,
    bool? formSubmittable,
    List<List<Model>>? collections,
  }) {
    return CompetitionAddingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      ageGroups: ageGroups ?? this.ageGroups,
      playingLevels: playingLevels ?? this.playingLevels,
      competitionDisciplines:
          competitionDisciplines ?? this.competitionDisciplines,
      disabledAgeGroups: disabledAgeGroups ?? this.disabledAgeGroups,
      disabledPlayingLevels:
          disabledPlayingLevels ?? this.disabledPlayingLevels,
      disabledCompetitionDisciplines:
          disabledCompetitionDisciplines ?? this.disabledCompetitionDisciplines,
      formSubmittable: formSubmittable ?? this.formSubmittable,
      collections: collections ?? this.collections,
    );
  }
}
