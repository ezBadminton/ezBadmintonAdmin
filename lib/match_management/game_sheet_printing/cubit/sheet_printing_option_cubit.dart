import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'sheet_printing_option_state.dart';

class SheetPrintingOptionCubit
    extends CollectionFetcherCubit<SheetPrintingOptionState> {
  SheetPrintingOptionCubit({
    required CollectionRepository<Tournament> tournamentRepository,
  })  : drawerController = CrossFadeDrawerController(false),
        super(
          collectionRepositories: [
            tournamentRepository,
          ],
          SheetPrintingOptionState(),
        ) {
    loadCollections();
    subscribeToCollectionUpdates(
      tournamentRepository,
      (_) => loadCollections(),
    );
  }

  final CrossFadeDrawerController drawerController;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Tournament>(),
      ],
      onSuccess: (updatedState) {
        emit(updatedState.copyWith(loadingStatus: LoadingStatus.done));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void dontReprintGameSheetsChanged(bool dontReprintGameSheets) {
    _updateTournament(state._tournament.copyWith(
      dontReprintGameSheets: dontReprintGameSheets,
    ));
  }

  void printQrCodesChanged(bool printQrCodes) {
    _updateTournament(state._tournament.copyWith(
      printQrCodes: printQrCodes,
    ));
  }

  void _updateTournament(Tournament tournament) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Tournament? updatedTournamet = await querier.updateModel(tournament);
    if (updatedTournamet == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }
}
