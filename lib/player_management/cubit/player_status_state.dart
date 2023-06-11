import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class PlayerStatusState {
  PlayerStatusState({
    required this.player,
    this.loadingStatus = LoadingStatus.done,
  });

  final Player player;
  final LoadingStatus loadingStatus;

  PlayerStatusState copyWith({
    Player? player,
    LoadingStatus? loadingStatus,
  }) =>
      PlayerStatusState(
        player: player ?? this.player,
        loadingStatus: loadingStatus ?? this.loadingStatus,
      );
}
