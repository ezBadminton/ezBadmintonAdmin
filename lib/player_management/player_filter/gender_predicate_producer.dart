import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';

class GenderCategoryPredicateProducer extends PredicateProducer {
  static const FilterGroup categoryDisjunction = FilterGroup.genderCategory;
  final List<GenderCategory> _categories = [];
  List<GenderCategory> get categories => List.unmodifiable(_categories);

  void categoryToggled(GenderCategory category) {
    Predicate? genderFilter;
    if (categories.contains(category)) {
      _categories.remove(category);
    } else {
      _categories.add(category);
      genderFilter =
          (Object c) => (c as Competition).genderCategory == category;
    }
    String filterName = category.name;
    var predicate = FilterPredicate(
      genderFilter,
      Competition,
      filterName,
      category,
      categoryDisjunction,
    );
    predicateStreamController.add(predicate);
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (producesDomain(predicateDomain) &&
        categories.contains(predicateDomain)) {
      categoryToggled(predicateDomain);
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain is GenderCategory;
  }
}
