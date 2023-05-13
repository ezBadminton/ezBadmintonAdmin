part of 'player_filter_cubit.dart';

@immutable
class PlayerFilterState {
  const PlayerFilterState({
    this.status = FormzSubmissionStatus.initial,
    this.overAge = const Age.pure(),
    this.underAge = const Age.pure(),
    this.gender,
    this.playingLevels = const [],
    this.competitions = const [],
    this.searchTerm = const SearchTerm.pure(),
    this.allPlayingLevels = const [],
    // The filterPredicate is used to output the filter to a filter state manager
    this.filterPredicate,
  });

  final FormzSubmissionStatus status;
  final Age overAge;
  final Age underAge;
  final Gender? gender;
  final List<PlayingLevel> playingLevels;
  final List<Competition> competitions;
  final SearchTerm searchTerm;

  final List<PlayingLevel> allPlayingLevels;

  final FilterPredicate? filterPredicate;

  PlayerFilterState copyWith({
    FormzSubmissionStatus? status,
    Age? overAge,
    Age? underAge,
    Gender? Function()? gender,
    List<PlayingLevel>? playingLevels,
    List<Competition>? competitions,
    SearchTerm? searchTerm,
    List<PlayingLevel>? allPlayingLevels,
  }) =>
      PlayerFilterState(
        status: status ?? this.status,
        overAge: overAge ?? this.overAge,
        underAge: underAge ?? this.underAge,
        gender: gender == null ? this.gender : gender(),
        playingLevels: playingLevels ?? this.playingLevels,
        competitions: competitions ?? this.competitions,
        searchTerm: searchTerm ?? this.searchTerm,
        allPlayingLevels: allPlayingLevels ?? this.allPlayingLevels,
        filterPredicate: null,
      );

  PlayerFilterState copyWithPredicate({
    required FilterPredicate filterPredicate,
  }) =>
      PlayerFilterState(
        status: status,
        overAge: overAge,
        underAge: underAge,
        gender: gender,
        playingLevels: playingLevels,
        competitions: competitions,
        searchTerm: searchTerm,
        allPlayingLevels: allPlayingLevels,
        filterPredicate: filterPredicate,
      );
}
