import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';

class AgeGroupPredicateProducer extends PredicateProducer {
  static const FilterGroup ageGroupDisjunction = FilterGroup.ageGroup;
  final _ageGroups = <AgeGroup>[];
  List<AgeGroup> get ageGroups => List.unmodifiable(_ageGroups);

  void ageGroupToggled(AgeGroup ageGroup) {
    FilterPredicate predicate;
    if (_ageGroups.contains(ageGroup)) {
      _ageGroups.remove(ageGroup);
      predicate = FilterPredicate(null, Competition, '', ageGroup);
    } else {
      _ageGroups.add(ageGroup);
      ageGroupFilter(Object c) => (c as Competition).ageGroup == ageGroup;
      predicate = FilterPredicate(
        ageGroupFilter,
        Competition,
        '${ageGroup.type.name}:${ageGroup.age}',
        ageGroup,
        ageGroupDisjunction,
      );
    }

    predicateStreamController.add(predicate);
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (producesDomain(predicateDomain) &&
        _ageGroups.contains(predicateDomain)) {
      ageGroupToggled(predicateDomain);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain is AgeGroup;
  }
}
