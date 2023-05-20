import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/predicate_producer.dart';

class GenderPredicateProducer extends PredicateProducer {
  static const String _genderDomain = 'gender';
  Gender? _gender;
  Gender? get gender => _gender;

  void genderChanged(Gender? gender) {
    if (gender == Gender.none || _gender == gender) {
      gender = null;
    }
    if (_gender == null && gender == null) {
      return;
    }
    _gender = gender;
    Predicate? genderFilter;
    if (gender != null) {
      genderFilter = (Object p) => (p as Player).gender == gender;
    }
    String filterName = gender == null ? '' : gender.name;
    var predicate = FilterPredicate(
      genderFilter,
      Player,
      filterName,
      _genderDomain,
    );
    predicateStreamController.add(predicate);
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (producesDomain(predicateDomain)) {
      genderChanged(null);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain == _genderDomain;
  }
}
