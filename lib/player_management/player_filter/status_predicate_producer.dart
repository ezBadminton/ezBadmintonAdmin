import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';

class StatusPredicateProducer extends PredicateProducer {
  static const String statusDisjunction = 'playerStatus';

  final List<PlayerStatus> _statusList = <PlayerStatus>[];
  List<PlayerStatus> get statusList => List.unmodifiable(_statusList);

  void statusToggled(PlayerStatus status) {
    FilterPredicate predicate;
    if (_statusList.contains(status)) {
      _statusList.remove(status);
      predicate = FilterPredicate(null, Player, '', status);
    } else {
      _statusList.add(status);
      statusFilter(Object p) => (p as Player).status == status;
      predicate = FilterPredicate(
        statusFilter,
        Player,
        status.name,
        status,
        statusDisjunction,
      );
    }

    predicateStreamController.add(predicate);
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
    return predicateDomain is PlayerStatus;
  }
}
