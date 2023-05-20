import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import "package:collection/collection.dart";

part 'predicate_filter_state.dart';

typedef Predicate = bool Function(Object o);

class PredicateFilterCubit extends Cubit<PredicateFilterState> {
  /// A predicate filter consisting of multiple [FilterPredicate]s.
  ///
  /// This cubit combines multiple predicates into a filter for different types
  /// of objects.
  PredicateFilterCubit() : super(_ListFilterState());

  /// Update the filter with a given [predicate]
  ///
  /// The given [FilterPredicate] will be incorporated into the filter as
  /// follows:
  ///
  /// 1. If the `predicate.function` is null and a predicate of the same
  /// `predicate.domain` is already present, the present predicate will be
  /// removed
  /// 2. If a predicate of the same `predicate.domain` is already present, then
  /// the present predicate will be replaced by `predicate`
  /// 3. The `predicate` is newly added
  void consumePredicate(FilterPredicate predicate) {
    if (predicate.function == null) {
      _removePredicate(predicate);
    } else {
      _addPredicate(predicate);
    }
  }

  void _addPredicate(FilterPredicate predicate) {
    _removePredicate(predicate, emit: false);

    var privateState = state as _ListFilterState;
    privateState.predicates.putIfAbsent(predicate.type, () => []);
    privateState.predicates[predicate.type]!.add(predicate);
    _emit();
  }

  /// Checks if other [FilterPredicate]s have the same domain as
  /// [predicate]. If so, removes the existing one.
  void _removePredicate(FilterPredicate predicate, {bool emit = true}) {
    var domain = predicate.domain;
    var privateState = state as _ListFilterState;
    if (privateState.predicates.containsKey(predicate.type)) {
      List<FilterPredicate> predicates =
          privateState.predicates[predicate.type]!;
      if (predicates.map((predicate) => predicate.domain).contains(domain)) {
        predicates.removeWhere((predicate) => predicate.domain == domain);
        if (predicates.isEmpty) {
          privateState.predicates.remove(predicate.type);
        }
        if (emit) {
          _emit();
        }
      }
    }
  }

  void _emit() {
    var privateState = state as _ListFilterState;
    var typeFilters = _createTypeFilters(privateState.predicates);
    var typePredicates = _finalizePredicates(privateState.predicates);

    var newState = _ListFilterState(
      filters: typeFilters,
      filterPredicates: typePredicates,
      predicates: privateState.predicates,
    );
    emit(newState);
  }

  /// Reduces a list of [FilterPredicate] to one [Predicate].
  ///
  /// Any predicates belonging to a disjunction group are combined by
  /// disjunction first then everything is conjuncted.
  Predicate _createFilter(
    List<FilterPredicate> predicates,
  ) {
    Map<String, List<FilterPredicate>> disjunctionGroups =
        groupBy(predicates, (p) => p.disjunction);
    Iterable<Predicate>? conjunctionPredicates =
        disjunctionGroups.remove('')?.map((p) => p.function!);
    conjunctionPredicates = conjunctionPredicates ?? [];

    Iterable<Predicate> disjunctionPredicates = disjunctionGroups.values.map(
        (disjunctionGroup) => disjunctionGroup
            .map((p) => p.function!)
            .reduce(_predicateDisjunction));

    List<Predicate> resultPredicates = conjunctionPredicates.toList()
      ..addAll(disjunctionPredicates);

    return resultPredicates.reduce(_predicateConjunction);
  }

  Map<Type, Predicate> _createTypeFilters(
    Map<Type, List<FilterPredicate>> typePredicates,
  ) {
    return typePredicates
        .map((type, predicates) => MapEntry(type, _createFilter(predicates)));
  }

  // Make predicate lists unmodifiable
  Map<Type, List<FilterPredicate>> _finalizePredicates(
    Map<Type, List<FilterPredicate>> predicates,
  ) {
    var finalPredicates = predicates.map(
      (type, predicates) =>
          MapEntry(type, List<FilterPredicate>.unmodifiable(predicates)),
    );
    return Map.unmodifiable(finalPredicates);
  }

  static Predicate _predicateConjunction(Predicate p1, Predicate p2) {
    return (o) => p1(o) && p2(o);
  }

  static Predicate _predicateDisjunction(Predicate p1, Predicate p2) {
    return (o) => p1(o) || p2(o);
  }
}

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
      [this.disjunction = '']);

  final Predicate? function;
  final Type type;
  final String name;
  final dynamic domain;
  final String disjunction;
}
