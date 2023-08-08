import 'package:ez_badminton_admin_app/predicate_filter/cubit/predicate_consumer_state.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/filter_predicate.dart';
import 'package:ez_badminton_admin_app/predicate_filter/predicate/predicate_producer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PredicateConsumerCubit<S extends PredicateConsumerState>
    extends Cubit<S> {
  PredicateConsumerCubit(super.initialState);

  P getPredicateProducer<P extends PredicateProducer>();

  void onPredicateRemoved(FilterPredicate predicate);
}
