part of 'match_context_cubit.dart';

class MatchContextState extends CollectionQuerierState {
  MatchContextState({
    this.loadingStatus = LoadingStatus.loading,
    TournamentMatch? match,
    ScheduledMatch? scheduledMatch,
    this.collections = const [],
  })  : _match = match,
        _scheduledMatch = scheduledMatch;

  @override
  final LoadingStatus loadingStatus;

  final TournamentMatch? _match;
  final ScheduledMatch? _scheduledMatch;

  TournamentMatch get match => _match ?? _scheduledMatch!.match;
  ScheduledMatch get scheduledMatch => _scheduledMatch!;

  @override
  final List<List<Model>> collections;

  MatchContextState copyWith({
    LoadingStatus? loadingStatus,
    TournamentMatch? match,
    ScheduledMatch? scheduledMatch,
    List<List<Model>>? collections,
  }) {
    return MatchContextState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      match: match ?? _match,
      scheduledMatch: scheduledMatch ?? _scheduledMatch,
      collections: collections ?? this.collections,
    );
  }
}
