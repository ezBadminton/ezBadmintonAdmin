import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class CompetitionCategorizationState extends CollectionQuerierState
    implements DialogState {
  CompetitionCategorizationState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(reason: Object()),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  @override
  final List<List<Model>> collections;

  Tournament get tournament => getCollection<Tournament>().first;

  CompetitionCategorizationState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
    List<List<Model>>? collections,
  }) {
    assert(
      _debugOnlyOneTournament(collections),
      'There are more than one Tournament objects',
    );
    return CompetitionCategorizationState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
      collections: collections ?? this.collections,
    );
  }

  static bool _debugOnlyOneTournament(List<List<Model>>? collections) {
    List<Tournament>? tournaments = collections
        ?.firstWhereOrNull((c) => c is List<Tournament>) as List<Tournament>?;
    if (tournaments != null && tournaments.length > 1) {
      return false;
    }
    return true;
  }
}
