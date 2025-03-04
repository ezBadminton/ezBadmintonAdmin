import 'package:model_repository/model_repository.dart';
import 'package:model_repository/src/api_endpoint_repository.dart';

class WithdrawalPreviewEndpoint
    extends ApiEndpointRepository<WithdrawalPreview> {
  WithdrawalPreviewEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(
          url: "/playerstatus/player/status/preview",
          unmarshaller: WithdrawalPreview.fromJson,
        );
}

class PlayerStatusEndpoint extends ApiEndpointRepository {
  PlayerStatusEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/playerstatus/player");
}

class AssignCourtEndpoint extends ApiEndpointRepository {
  AssignCourtEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/courts/court/assign");
}

class UnassignCourtEndpoint extends ApiEndpointRepository {
  UnassignCourtEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/courts/court/unassign");
}

class MakeDrawEndpoint extends ApiEndpointRepository {
  MakeDrawEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/draw/competition/make");
}

class SwapDrawEndpoint extends ApiEndpointRepository {
  SwapDrawEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/draw/competition/swap");
}

class RedrawEndpoint extends ApiEndpointRepository {
  RedrawEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/draw/competition/redraw");
}

class SetSeedsEndpoint extends ApiEndpointRepository {
  SetSeedsEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/draw/competition/seeds");
}

class DeleteDrawEndpoint extends ApiEndpointRepository {
  DeleteDrawEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/draw/competition");
}

class StartMatchEndpoint extends ApiEndpointRepository {
  StartMatchEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/matches/matchdata/start");
}

class CancelMatchEndpoint extends ApiEndpointRepository {
  CancelMatchEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/matches/matchdata/cancel");
}

class SetScoreEndpoint extends ApiEndpointRepository {
  SetScoreEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/matches/matchdata/score");
}

class ResetMatchEndpoint extends ApiEndpointRepository {
  ResetMatchEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/matches/matchdata/reset");
}

class RegisterTeamEndpoint extends ApiEndpointRepository {
  RegisterTeamEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/registration/competition");
}

class UpdateTeamEndpoint extends ApiEndpointRepository {
  UpdateTeamEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/registration/team");
}

class AddTieBreakerEndpoint extends ApiEndpointRepository {
  AddTieBreakerEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/tiebreakers/competition");
}

class UpdateTieBreakerEndpoint extends ApiEndpointRepository {
  UpdateTieBreakerEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/tiebreakers/tiebreaker");
}

class TournamentStartEndpoint extends ApiEndpointRepository {
  TournamentStartEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/tournaments/competition/start");
}

class TournamentStopEndpoint extends ApiEndpointRepository {
  TournamentStopEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/tournaments/competition/stop");
}

class CompetitionDeleteEndpoint extends ApiEndpointRepository {
  CompetitionDeleteEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/competitions");
}

class PlayingLevelReorderEndpoint extends ApiEndpointRepository {
  PlayingLevelReorderEndpoint({
    required super.pocketBase,
    required super.modelRepository,
  }) : super(url: "/playinglevels/reorder");
}
