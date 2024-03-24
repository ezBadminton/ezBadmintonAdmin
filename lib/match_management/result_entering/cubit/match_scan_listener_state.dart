part of 'match_scan_listener_cubit.dart';

class MatchScanListenerState extends CollectionQuerierState {
  MatchScanListenerState({
    this.loadingStatus = LoadingStatus.loading,
    this.scannedMatch = const SelectionInput.dirty(),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final SelectionInput<MatchData> scannedMatch;

  @override
  final List<List<Model>> collections;

  MatchScanListenerState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<MatchData>? scannedMatch,
    List<List<Model>>? collections,
  }) {
    return MatchScanListenerState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      scannedMatch: scannedMatch ?? const SelectionInput.dirty(),
      collections: collections ?? this.collections,
    );
  }
}
