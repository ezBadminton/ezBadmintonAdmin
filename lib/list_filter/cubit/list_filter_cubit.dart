import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import "package:collection/collection.dart";

part 'list_filter_state.dart';

typedef Predicate = bool Function(Object o);

class ListFilterCubit extends Cubit<ListFilterState> {
  ListFilterCubit() : super(_ListFilterState());

  /// Add a predicate to this filter
  void addPredicate(FilterPredicate predicate) {
    if (_isPresent(predicate) || predicate.function == null) return;
    _removeByDomain(predicate, emit: false);

    var privateState = state as _ListFilterState;
    privateState.predicates.putIfAbsent(predicate.type, () => []);
    privateState.predicates[predicate.type]!.add(predicate);
    _emit();
  }

  void removePredicate(FilterPredicate predicate) {
    if (predicate.function == null && predicate.domain != null) {
      _removeByDomain(predicate);
    } else {
      _remove(predicate);
    }
  }

  bool _remove(FilterPredicate predicate, {bool emit = true}) {
    var privateState = state as _ListFilterState;
    if (!privateState.predicates.containsKey(predicate.type)) {
      return false;
    }
    List<FilterPredicate> predicates = privateState.predicates[predicate.type]!;
    if (predicates.contains(predicate)) {
      predicates.remove(predicate);
      if (predicates.isEmpty) {
        privateState.predicates.remove(predicate.type);
      }
      if (emit) {
        _emit();
      }
      return true;
    }
    return false;
  }

  /// Checks if other [FilterPredicate]s have the same domain as
  /// [predicate]. If so, removes the existing one.
  void _removeByDomain(FilterPredicate predicate, {bool emit = true}) {
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

  bool _isPresent(FilterPredicate predicate) {
    var privateState = state as _ListFilterState;
    if (!privateState.predicates.containsKey(predicate.type)) {
      return false;
    }
    return privateState.predicates[predicate.type]!
        .map((p) => p.name)
        .contains(predicate.name);
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

class FilterPredicate extends Equatable {
  /// A predicate describing a single condition of a filter.
  ///
  /// The [function] is the predicate function taking in an object of a
  /// set [type].
  /// The predicate has a describing [name] aswell as a [domain].
  /// A filter can only contain one predicate of a given domain at a
  /// time. It gets overwritten by new entries with the same domain.
  /// All filters (of a type) with a matching [disjunction] string get combined
  /// in a disjunction before being conjoined with the other predicates
  /// of the filter.
  const FilterPredicate(this.function, this.type, this.name, this.domain,
      [this.disjunction = '']);

  final Predicate? function;
  final Type type;
  final String name;
  final dynamic domain;
  final String disjunction;

  @override
  List<Object?> get props => [name];
}
