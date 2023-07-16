import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/confirm_dialog/cubit_mixin/dialog_cubit.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class CompetitionCategorizationState
    extends CollectionFetcherState<CompetitionCategorizationState>
    implements DialogState {
  CompetitionCategorizationState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(reason: Object()),
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  @override
  final CubitDialog dialog;

  Tournament get tournament => getCollection<Tournament>().first;

  CompetitionCategorizationState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
    Map<Type, List<Model>>? collections,
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

  static bool _debugOnlyOneTournament(Map<Type, List<Model>>? collections) {
    if (collections != null && collections[Tournament]!.length > 1) {
      return false;
    }
    return true;
  }
}
