// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'starting_fee_cubit.dart';

class StartingFeeState extends CollectionQuerierState {
  const StartingFeeState({
    this.loadingStatus = LoadingStatus.loading,
    this.playerFees = const {},
    this.clubFees = const {},
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final Map<Player, int> playerFees;
  final Map<Club, int> clubFees;

  @override
  final List<List<Model>> collections;

  StartingFeeState copyWith({
    LoadingStatus? loadingStatus,
    Map<Player, int>? playerFees,
    Map<Club, int>? clubFees,
    List<List<Model>>? collections,
  }) {
    return StartingFeeState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      playerFees: playerFees ?? this.playerFees,
      clubFees: clubFees ?? this.clubFees,
      collections: collections ?? this.collections,
    );
  }
}
