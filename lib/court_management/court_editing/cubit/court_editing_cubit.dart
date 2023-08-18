import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'court_editing_state.dart';

class CourtEditingCubit extends CollectionFetcherCubit<CourtEditingState> {
  CourtEditingCubit({
    required CollectionRepository<Court> courtRepository,
    required CollectionRepository<Gymnasium> gymnasiumRepository,
    required this.l10n,
  }) : super(
          collectionRepositories: [
            courtRepository,
            gymnasiumRepository,
          ],
          CourtEditingState(),
        ) {
    subscribeToCollectionUpdates(
      gymnasiumRepository,
      _onGymnasiumCollectionUpdate,
    );
    subscribeToCollectionUpdates(courtRepository, (_) => loadCollections());
    loadCollections();
  }

  final AppLocalizations l10n;

  void loadCollections() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Court>(),
      ],
      onSuccess: (updatedState) {
        List<Court> courtCollection = updatedState.getCollection<Court>();
        List<Court> courtsOfGym = _getCourtsOfGym(
          courtCollection,
          state.gymnasium.value,
        );

        emit(updatedState.copyWith(
          courts: courtsOfGym,
          loadingStatus: LoadingStatus.done,
        ));
      },
      onFailure: () {
        emit(state.copyWith(loadingStatus: LoadingStatus.failed));
      },
    );
  }

  void gymnasiumToggled(Gymnasium gymnasium) {
    if (state.gymnasium.value == gymnasium) {
      _unselectGymnasium();
    } else {
      _selectGymnasium(gymnasium);
    }
  }

  void courtAdded(int row, int column) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    assert(state.gymnasium.value != null);
    Gymnasium gym = state.gymnasium.value!;
    assert(row <= gym.rows && column <= gym.columns);

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    Court newCourt = Court.newCourt(
      name: l10n.courtN(column + row * gym.columns + 1),
      gymnasium: gym,
      x: column,
      y: row,
    );

    Court? createdCourt = await querier.createModel(newCourt);
    if (createdCourt == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  void _selectGymnasium(Gymnasium gymnasium) {
    List<Court> courtsOfGym = _getCourtsOfGym(
      state.getCollection<Court>(),
      gymnasium,
    );
    emit(state.copyWith(
      gymnasium: SelectionInput.pure(
        emptyAllowed: true,
        value: gymnasium,
      ),
      courts: courtsOfGym,
    ));
  }

  void _unselectGymnasium() {
    emit(state.copyWith(
      gymnasium: const SelectionInput.pure(
        emptyAllowed: true,
        value: null,
      ),
      courts: [],
    ));
  }

  static List<Court> _getCourtsOfGym(
    List<Court> courtCollection,
    Gymnasium? gymnasium,
  ) {
    List<Court> courtsOfGym =
        courtCollection.where((c) => c.gymnasium == gymnasium).toList();
    return courtsOfGym;
  }

  void _onGymnasiumCollectionUpdate(CollectionUpdateEvent<Gymnasium> event) {
    Gymnasium updatedGymnasium = event.model;
    if (state.gymnasium.value != updatedGymnasium) {
      return;
    }

    switch (event.updateType) {
      case UpdateType.update:
        _selectGymnasium(updatedGymnasium);
        break;
      case UpdateType.delete:
        _unselectGymnasium();
        break;
      default:
        break;
    }
  }
}
