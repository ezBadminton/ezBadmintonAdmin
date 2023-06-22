// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection_repository/collection_repository.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class TournamentEditingState
    extends CollectionFetcherState<TournamentEditingState> {
  TournamentEditingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  Tournament? get tournament => getCollection<Tournament>().firstOrNull;

  TournamentEditingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    Map<Type, List<Model>>? collections,
  }) {
    assert(
      _debugOnlyOneTournament(collections),
      'There are more than one Tournament objects',
    );
    return TournamentEditingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      collections: collections ?? this.collections,
    );
  }

  static bool _debugOnlyOneTournament(Map<Type, List<Model>>? collections) {
    if (collections != null && collections[Tournament]!.length > 1) {
      return false;
    }
    return true;
  }
}
