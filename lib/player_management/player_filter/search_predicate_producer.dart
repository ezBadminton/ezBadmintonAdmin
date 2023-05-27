import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/models/search_term.dart';
import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate_producer/predicate_producer.dart';

class SearchPredicateProducer extends PredicateProducer {
  static const String searchDomain = 'search';
  SearchTerm _searchTerm = const SearchTerm.dirty('');
  String get searchTerm => _searchTerm.value;

  static bool searchTermMatchesPlayer(String searchTerm, Player p) {
    var cleanSearchTerm = searchTerm.trim().toLowerCase();
    var name = '${p.firstName} ${p.lastName}'.toLowerCase();
    var club = p.club?.name.toLowerCase() ?? '';

    return name.contains(cleanSearchTerm) || club.contains(cleanSearchTerm);
  }

  void searchTermChanged(String searchTerm) {
    _searchTerm = SearchTerm.dirty(searchTerm);
    if (_searchTerm.isValid) {
      searchPredicate(Object p) =>
          searchTermMatchesPlayer(searchTerm, p as Player);
      var predicate = FilterPredicate(
        searchPredicate,
        Player,
        searchTerm,
        searchDomain,
      );
      predicateStreamController.add(predicate);
    } else if (searchTerm.isEmpty) {
      var predicate = const FilterPredicate(
        null,
        Player,
        '',
        searchDomain,
      );
      predicateStreamController.add(predicate);
    }
  }

  @override
  void produceEmptyPredicate(dynamic predicateDomain) {
    if (producesDomain(predicateDomain)) {
      searchTermChanged('');
    }
  }

  @override
  bool producesDomain(dynamic predicateDomain) {
    return predicateDomain == searchDomain;
  }
}
