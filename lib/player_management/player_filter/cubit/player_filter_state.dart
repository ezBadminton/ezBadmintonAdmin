part of 'player_filter_cubit.dart';

@immutable
class PlayerFilterState {
  const PlayerFilterState({
    this.loadingStatus = LoadingStatus.loading,
    this.allPlayingLevels = const [],
    this.filterPredicate,
  });

  final LoadingStatus loadingStatus;
  final List<PlayingLevel> allPlayingLevels;

  final FilterPredicate? filterPredicate;

  PlayerFilterState copyWith({
    LoadingStatus? loadingStatus,
    List<PlayingLevel>? allPlayingLevels,
  }) =>
      PlayerFilterState(
        loadingStatus: loadingStatus ?? this.loadingStatus,
        allPlayingLevels: allPlayingLevels ?? this.allPlayingLevels,
        filterPredicate: null,
      );

  PlayerFilterState copyWithPredicate({
    required FilterPredicate filterPredicate,
  }) =>
      PlayerFilterState(
        loadingStatus: loadingStatus,
        allPlayingLevels: allPlayingLevels,
        filterPredicate: filterPredicate,
      );
}
