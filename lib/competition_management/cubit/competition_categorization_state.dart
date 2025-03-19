import 'package:collection/collection.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class CompetitionCategorizationState extends CollectionQuerierState
    implements DialogState {
  CompetitionCategorizationState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.categorizationEditable = false,
    this.dialog = const CubitDialog(reason: Object()),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final bool categorizationEditable;

  @override
  final CubitDialog dialog;

  @override
  final List<List<Model>> collections;

  TournamentEvent get tournament => getCollection<TournamentEvent>().first;

  CompetitionCategorizationState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    bool? categorizationEditable,
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
      categorizationEditable:
          categorizationEditable ?? this.categorizationEditable,
      dialog: dialog ?? this.dialog,
      collections: collections ?? this.collections,
    );
  }

  static bool _debugOnlyOneTournament(List<List<Model>>? collections) {
    List<TournamentEvent>? tournaments =
        collections?.firstWhereOrNull((c) => c is List<TournamentEvent>)
            as List<TournamentEvent>?;
    if (tournaments != null && tournaments.length > 1) {
      return false;
    }
    return true;
  }
}
