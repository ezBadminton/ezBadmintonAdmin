import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_filter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class HasFunction extends CustomMatcher {
  HasFunction(matcher)
      : super(
          'FilterPredicate with a predicate function that is',
          'Predicate function',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).function;
}

class HasDomain extends CustomMatcher {
  HasDomain(matcher)
      : super(
          'FilterPredicate with a domain of',
          'Predicate domain',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).domain;
}

class HasDisjunction extends CustomMatcher {
  HasDisjunction(matcher)
      : super(
          'FilterPredicate with a disjunction of',
          'Predicate disjunction',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).disjunction;
}

class HasInputType extends CustomMatcher {
  HasInputType(matcher)
      : super(
          'FilterPredicate with input type of',
          'Predicate input type',
          matcher,
        );
  @override
  featureValueOf(actual) => (actual as FilterPredicate).type;
}

class HasFilterResult extends CustomMatcher {
  HasFilterResult(matcher, {required this.items})
      : super(
          'FilterPredicate that filters to',
          'filtered items',
          matcher,
        );

  final List<Object> items;

  @override
  featureValueOf(actual) =>
      items.where((item) => (actual as FilterPredicate).function!(item));
}
