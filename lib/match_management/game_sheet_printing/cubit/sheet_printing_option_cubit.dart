import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/cross_fade_drawer/cross_fade_drawer_controller.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'sheet_printing_option_state.dart';

class SheetPrintingOptionCubit
    extends CollectionQuerierCubit<SheetPrintingOptionState> {
  SheetPrintingOptionCubit({
    required CollectionRepository<Tournament> tournamentRepository,
  })  : drawerController = CrossFadeDrawerController(false),
        super(
          collectionRepositories: [
            tournamentRepository,
          ],
          SheetPrintingOptionState(),
        );

  final CrossFadeDrawerController drawerController;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>> updateEvents,
  ) {
    SheetPrintingOptionState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    emit(updatedState);
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
