import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/court_management/court_list/utils/numbered_string.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/cubit/court_numbering_dialog_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_numbering/models/court_numbering_type.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'court_numbering_state.dart';

class CourtNumberingCubit extends CollectionQuerierCubit<CourtNumberingState>
    with DialogCubit {
  CourtNumberingCubit({
    required CollectionRepository<Gymnasium> gymnasiumRepository,
    required CollectionRepository<Court> courtRepository,
    required this.l10n,
  }) : super(
          collectionRepositories: [
            gymnasiumRepository,
            courtRepository,
          ],
          CourtNumberingState(),
        );

  final AppLocalizations l10n;

  /// Renames courts with numbered names based on user input settings
  void courtsNumbered(Gymnasium gymnasium) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    CourtNumberingDialogState? numberingSettings =
        await requestDialogChoice<CourtNumberingDialogState>();
    if (numberingSettings == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.canceled));
      return;
    }

    List<Court> courts = querier.getCollection<Court>();

    List<Gymnasium> gymnasiums = querier.getCollection<Gymnasium>();

    Map<Court, String> numberedCourts = _numberCourts(
      courts,
      gymnasium,
      gymnasiums,
      numberingSettings,
    );

    FormzSubmissionStatus courtsSubmitted =
        await _submitRenames(numberedCourts);

    emit(state.copyWith(formStatus: courtsSubmitted));
  }

  Map<Court, String> _numberCourts(
    List<Court> courts,
    Gymnasium gymnasium,
    List<Gymnasium> gymnasiums,
    CourtNumberingDialogState numberingSettings,
  ) {
    switch (numberingSettings.numberingType) {
      case CourtNumberingType.gymOnly:
        gymnasiums = [gymnasium];
        courts = courts.where((c) => c.gymnasium == gymnasium).toList();
        break;
      case CourtNumberingType.global:
        gymnasiums = gymnasiums.sortedBy((g) => NumberedString(g.name));
        break;
    }

    // Sorted gyms and sorted court lists
    Map<Gymnasium, List<Court>> courtsOfGyms = {
      for (Gymnasium gym in gymnasiums)
        gym: courts.where((c) => c.gymnasium == gym).sortedBy<num>(
              (court) => _indexCourt(
                gym,
                court,
                numberingSettings.numberingDirection,
              ),
            ),
    };

    Map<Court, String> numberedCourtNames = _getNumberedCourtNames(
      courtsOfGyms,
      numberingSettings.countingType,
      numberingSettings.numberingDirection,
    );

    return numberedCourtNames;
  }

  int _indexCourt(
    Gymnasium gymnasium,
    Court court,
    Axis countingDirection,
  ) {
    switch (countingDirection) {
      case Axis.horizontal:
        return court.positionX + court.positionY * gymnasium.columns;
      case Axis.vertical:
        return court.positionY + court.positionX * gymnasium.rows;
    }
  }

  Map<Court, String> _getNumberedCourtNames(
    Map<Gymnasium, List<Court>> courtsOfGyms,
    CourtCountingType countingType,
    Axis countingDirection,
  ) {
    Map<Court, String> courtNames = {};
    int gymOffset = 0;
    for (Gymnasium gym in courtsOfGyms.keys) {
      for (Court court in courtsOfGyms[gym]!) {
        int courtNumber;

        switch (countingType) {
          case CourtCountingType.countAll:
            courtNumber =
                _indexCourt(gym, court, countingDirection) + gymOffset + 1;
            break;
          case CourtCountingType.skipUnused:
            courtNumber = courtsOfGyms[gym]!.indexOf(court) + gymOffset + 1;
            break;
        }

        courtNames.putIfAbsent(court, () => l10n.courtN(courtNumber));
      }

      switch (countingType) {
        case CourtCountingType.countAll:
          gymOffset += gym.rows * gym.columns;
          break;
        case CourtCountingType.skipUnused:
          gymOffset += courtsOfGyms[gym]!.length;
          break;
      }
    }

    return courtNames;
  }

  Future<FormzSubmissionStatus> _submitRenames(
    Map<Court, String> courtNames,
  ) async {
    Iterable<Future<Court?>> courtUpdates = courtNames.entries.map((rename) {
      Court renamedCourt = rename.key.copyWith(name: rename.value);
      return querier.updateModel(renamedCourt);
    });

    List<Court?> updatedCourts = await Future.wait(courtUpdates);
    if (updatedCourts.contains(null)) {
      return FormzSubmissionStatus.failure;
    }

    return FormzSubmissionStatus.success;
  }

  @override
  void onCollectionUpdate(List<List<Model>> collections,
      List<CollectionUpdateEvent<Model>> updateEvents) {}
}
