import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/age.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/predicate_producer.dart';

class AgePredicateProducer extends PredicateProducer {
  static const String _overAgeDomain = 'over';
  static const String _underAgeDomain = 'under';

  Age _overAge = const Age.dirty('');
  Age _underAge = const Age.dirty('');

  String get overAge => _overAge.value;
  String get underAge => _underAge.value;

  void overAgeChanged(String ageInput) {
    _overAge = Age.dirty(ageInput);
  }

  void underAgeChanged(String ageInput) {
    _underAge = Age.dirty(ageInput);
  }

  void produceAgePredicates() {
    if (_overAge.isValid) {
      _produceAgePredicate(true);
    }
    if (_underAge.isValid) {
      _produceAgePredicate(false);
    }
  }

  void _produceAgePredicate(bool over) {
    Age newAge = over ? _overAge : _underAge;
    String filterDomain = over ? _overAgeDomain : _underAgeDomain;
    FilterPredicate predicate;
    if (newAge.value.isEmpty) {
      predicate = FilterPredicate(
        null,
        Player,
        '',
        filterDomain,
      );
    } else {
      int age = int.parse(newAge.value);
      String filterName = '$filterDomain$age';
      Predicate ageFilter = over
          ? (Object p) => (p as Player).calculateAge() >= age
          : (Object p) => (p as Player).calculateAge() < age;
      predicate = FilterPredicate(
        ageFilter,
        Player,
        filterName,
        filterDomain,
      );
    }
    predicateStreamController.add(predicate);
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (predicateDomain == _overAgeDomain) {
      overAgeChanged('');
      _produceAgePredicate(true);
    } else if (predicateDomain == _underAgeDomain) {
      underAgeChanged('');
      _produceAgePredicate(false);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain == _overAgeDomain ||
        predicateDomain == _underAgeDomain;
  }
}
