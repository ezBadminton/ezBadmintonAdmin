import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/partner_registration_state.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class PartnerRegistrationCubit
    extends CollectionFetcherCubit<PartnerRegistrationState> {
  PartnerRegistrationCubit({
    required this.registration,
    required CollectionRepository<Player> playerRepository,
    required CollectionRepository<Team> teamReposiotry,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          PartnerRegistrationState(
            partner: SelectionInput.pure(value: registration.partner),
          ),
          collectionRepositories: [
            playerRepository,
            teamReposiotry,
            competitionRepository,
          ],
        ) {
    loadPlayerData();
  }

  final CompetitionRegistration registration;

  void loadPlayerData() {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    fetchCollectionsAndUpdateState(
      [
        collectionFetcher<Player>(),
        collectionFetcher<Competition>(),
      ],
      onSuccess: (updatedState) {
        updatedState = updatedState.copyWith(
          loadingStatus: LoadingStatus.done,
        );
        emit(updatedState);
      },
      onFailure: () =>
          emit(state.copyWith(loadingStatus: LoadingStatus.failed)),
    );
  }

  void partnerInputVisibilityChanged(bool showPartnerInput) {
    var newState = state.copyWith(showPartnerInput: showPartnerInput);
    emit(newState);
  }

  void partnerChanged(Player? partner) {
    var newState = state.copyWith(
      partner: SelectionInput.dirty(emptyAllowed: true, value: partner),
    );
    emit(newState);
  }

  void partnerSubmitted() {
    if (state.partner.value == null) {
      return;
    }
  }
}
