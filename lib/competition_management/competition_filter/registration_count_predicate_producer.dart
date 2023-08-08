import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';

class RegistrationCountPredicateProducer extends PredicateProducer {
  static const FilterGroup overRegistrationsDomain =
      FilterGroup.moreRegistrations;
  static const FilterGroup underRegistrationsDomain =
      FilterGroup.lessRegistrations;

  PositiveNumber _overCount = const PositiveNumber.dirty('');
  PositiveNumber _underCount = const PositiveNumber.dirty('');

  String get overCount => _overCount.value;
  String get underCount => _underCount.value;

  void overRegistrationsChanged(String numberInput) {
    _overCount = PositiveNumber.dirty(numberInput);
  }

  void underRegistrationsChanged(String numberImput) {
    _underCount = PositiveNumber.dirty(numberImput);
  }

  void produceRegistrationCountPredicates() {
    if (_overCount.isValid) {
      _produceRegistrationCountPredicate(true);
    }
    if (_underCount.isValid) {
      _produceRegistrationCountPredicate(false);
    }
  }

  void _produceRegistrationCountPredicate(bool over) {
    PositiveNumber newCount = over ? _overCount : _underCount;
    FilterGroup filterDomain =
        over ? overRegistrationsDomain : underRegistrationsDomain;
    FilterPredicate predicate;
    if (newCount.value.isEmpty) {
      predicate = FilterPredicate(
        null,
        Competition,
        '',
        filterDomain,
      );
    } else {
      int count = int.parse(newCount.value);
      String filterName = '${filterDomain.name}:$count';
      Predicate registrationCountFilter = over
          ? (Object c) => (c as Competition).registrations.length >= count
          : (Object c) => (c as Competition).registrations.length <= count;
      predicate = FilterPredicate(
        registrationCountFilter,
        Competition,
        filterName,
        filterDomain,
      );
    }
    predicateStreamController.add(predicate);
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (predicateDomain == overRegistrationsDomain) {
      overRegistrationsChanged('');
      _produceRegistrationCountPredicate(true);
    } else if (predicateDomain == underRegistrationsDomain) {
      underRegistrationsChanged('');
      _produceRegistrationCountPredicate(false);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain == overRegistrationsDomain ||
        predicateDomain == underRegistrationsDomain;
  }
}
