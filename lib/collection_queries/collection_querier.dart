import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CollectionQuerier {
  abstract final Iterable<CollectionRepository<Model>> collectionRepositories;
}

abstract class CollectionQuerierState {
  abstract final Map<Type, List<Model>> collections;
}

abstract class CollectionQuerierCubit<State> extends Cubit<State>
    implements CollectionQuerier {
  CollectionQuerierCubit(super.initialState);
}

abstract class CollectionQuerierBloc<Event, State> extends Bloc<Event, State>
    implements CollectionQuerier {
  CollectionQuerierBloc(super.initialState);
}
