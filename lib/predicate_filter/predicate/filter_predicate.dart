import 'package:ez_badminton_admin_app/predicate_filter/predicate_producers.dart';

typedef Predicate = bool Function(Object o);

class FilterPredicate {
  /// A predicate describing a single condition of a predicate filter.
  ///
  /// The [function] is the predicate function taking in an object of a
  /// set [type].
  /// The predicate has a describing [name] aswell as a [domain].
  /// A filter can only contain one predicate of a given domain at a
  /// time. It gets overwritten by new entries with the same domain.
  /// By default, all predicates of a type are conjoined to produce the final
  /// filter unless the predicate has a non-empty [disjunction] string.
  /// All filters (of a type) with a matching [disjunction] string get combined
  /// in a disjunction before being conjoined.
  const FilterPredicate(this.function, this.type, this.name, this.domain,
      [this.disjunction]);

  final Predicate? function;
  final Type type;
  final String name;
  final dynamic domain;
  final FilterGroup? disjunction;
}
