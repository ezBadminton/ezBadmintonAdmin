part of 'player_filter_cubit.dart';

@immutable
class PlayerFilterState {
  const PlayerFilterState({
    this.loadingStatus = LoadingStatus.loading,
    this.overAge = const Age.pure(),
    this.underAge = const Age.pure(),
    this.gender,
    this.playingLevels = const [],
    this.competitionTypes = const [],
    this.searchTerm = const SearchTerm.pure(),
    this.allPlayingLevels = const [],
    // The filterPredicate is used to output the filter to a filter state manager
    this.filterPredicate,
  });

  final LoadingStatus loadingStatus;
  final Age overAge;
  final Age underAge;
  final Gender? gender;
  final List<PlayingLevel> playingLevels;
  final List<CompetitionType> competitionTypes;
  final SearchTerm searchTerm;

  final List<PlayingLevel> allPlayingLevels;

  final FilterPredicate? filterPredicate;

  PlayerFilterState copyWith({
    LoadingStatus? loadingStatus,
    Age? overAge,
    Age? underAge,
    Gender? Function()? gender,
    List<PlayingLevel>? playingLevels,
    List<CompetitionType>? competitionTypes,
    SearchTerm? searchTerm,
    List<PlayingLevel>? allPlayingLevels,
  }) =>
      PlayerFilterState(
        loadingStatus: loadingStatus ?? this.loadingStatus,
        overAge: overAge ?? this.overAge,
        underAge: underAge ?? this.underAge,
        gender: gender == null ? this.gender : gender(),
        playingLevels: playingLevels ?? this.playingLevels,
        competitionTypes: competitionTypes ?? this.competitionTypes,
        searchTerm: searchTerm ?? this.searchTerm,
        allPlayingLevels: allPlayingLevels ?? this.allPlayingLevels,
        filterPredicate: null,
      );

  PlayerFilterState copyWithPredicate({
    required FilterPredicate filterPredicate,
  }) =>
      PlayerFilterState(
        loadingStatus: loadingStatus,
        overAge: overAge,
        underAge: underAge,
        gender: gender,
        playingLevels: playingLevels,
        competitionTypes: competitionTypes,
        searchTerm: searchTerm,
        allPlayingLevels: allPlayingLevels,
        filterPredicate: filterPredicate,
      );
}
