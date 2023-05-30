import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/registraion_cancellation_state.dart';

class RegistrationCancellationCubit extends CollectionQuerierCubit {
  RegistrationCancellationCubit({
    required this.competition,
    required this.player,
    required CollectionRepository<Competition> competitionRepository,
  }) : super(
          RegistrationCancellationState(),
          collectionRepositories: [competitionRepository],
        );

  final Competition competition;
  final Player player;

  void registrationCancelled() {}
}
