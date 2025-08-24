import 'package:equatable/equatable.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_groups.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';

const FilterGroup _statusDisjunction = FilterGroup.playerStatus;
const FilterGroup _metaStatusDisjunction = FilterGroup.playerMetaStatus;

class StatusPredicateProducer extends PredicateProducer {
  StatusPredicateProducer({required this.playerListCubit});

  final PlayerListCubit playerListCubit;

  final List<PlayerMetaStatus> _statusList = <PlayerMetaStatus>[];
  List<PlayerMetaStatus> get statusList => List.unmodifiable(_statusList);

  void statusToggled(PlayerMetaStatus status) {
    FilterPredicate predicate;
    if (_statusList.contains(status)) {
      _statusList.remove(status);
      predicate = FilterPredicate(null, Player, '', status);
    } else {
      _statusList.add(status);
      predicate = _producePredicate(status);
    }

    predicateStreamController.add(predicate);
  }

  FilterPredicate _producePredicate(PlayerMetaStatus status) {
    if (status.playerStatus == null) {
      return _produceMetaStatusPredicate(status);
    } else {
      return _producePlayerStatusPredicate(status);
    }
  }

  FilterPredicate _producePlayerStatusPredicate(PlayerMetaStatus status) {
    statusFilter(Object p) => (p as Player).status == status.playerStatus;
    final predicate = FilterPredicate(
      statusFilter,
      Player,
      status.name,
      status,
      _statusDisjunction,
    );
    return predicate;
  }

  FilterPredicate _produceMetaStatusPredicate(PlayerMetaStatus status) {
    final FilterPredicate predicate;
    switch (status.metaStatus!) {
      case MetaStatus.lookingForTeam:
        statusFilter(Object p) =>
            playerListCubit.state.playersLookingForTeam.contains(p);
        predicate = FilterPredicate(
          statusFilter,
          Player,
          status.name,
          status,
          _metaStatusDisjunction,
        );
    }
    return predicate;
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (producesDomain(predicateDomain) &&
        _statusList.contains(predicateDomain)) {
      statusToggled(predicateDomain);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain is PlayerMetaStatus;
  }
}

/// Each player is always in exactly one of the normal [PlayerStatus] options
/// but they can have additional status at the same time that is derived from
/// other (meta-) data.
/// To be able to filter for normal and meta status at the same time this
/// [PlayerMetaStatus] class offers a union of both.
class PlayerMetaStatus extends Equatable {
  const PlayerMetaStatus.fromStatus(PlayerStatus status)
      : playerStatus = status,
        metaStatus = null;

  const PlayerMetaStatus.fromMetaStatus(MetaStatus status)
      : metaStatus = status,
        playerStatus = null;

  final PlayerStatus? playerStatus;
  final MetaStatus? metaStatus;

  String get name => playerStatus?.name ?? metaStatus!.name;

  @override
  List<Object?> get props => [playerStatus, metaStatus];
}

enum MetaStatus {
  lookingForTeam,
}
