import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';

class CompetitionTypePredicateProducer extends PredicateProducer {
  static const FilterGroup competitionDisjunction = FilterGroup.competitionType;
  final _competitionTypes = <CompetitionType>[];
  List<CompetitionType> get competitionTypes =>
      List.unmodifiable(_competitionTypes);

  void competitionTypeToggled(CompetitionType competitionType) {
    FilterPredicate predicate;
    if (_competitionTypes.contains(competitionType)) {
      _competitionTypes.remove(competitionType);
      predicate = FilterPredicate(
        null,
        Competition,
        '',
        competitionType,
      );
    } else {
      _competitionTypes.add(competitionType);
      competitionFilter(Object c) => (c as Competition).type == competitionType;
      predicate = FilterPredicate(
        competitionFilter,
        Competition,
        competitionType.name,
        competitionType,
        competitionDisjunction,
      );
    }

    predicateStreamController.add(predicate);
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (producesDomain(predicateDomain) &&
        _competitionTypes.contains(predicateDomain)) {
      competitionTypeToggled(predicateDomain);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain is CompetitionType;
  }
}
