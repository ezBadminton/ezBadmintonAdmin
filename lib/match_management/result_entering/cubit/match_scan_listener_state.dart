part of 'match_scan_listener_cubit.dart';

class MatchScanListenerState
    extends CollectionFetcherState<MatchScanListenerState> {
  MatchScanListenerState({
    this.loadingStatus = LoadingStatus.loading,
    this.scannedMatch = const SelectionInput.dirty(),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;

  final SelectionInput<MatchData> scannedMatch;

  MatchScanListenerState copyWith({
    LoadingStatus? loadingStatus,
    SelectionInput<MatchData>? scannedMatch,
    Map<Type, List<Model>>? collections,
  }) {
    return MatchScanListenerState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      scannedMatch: scannedMatch ?? this.scannedMatch,
      collections: collections ?? this.collections,
    );
  }
}
