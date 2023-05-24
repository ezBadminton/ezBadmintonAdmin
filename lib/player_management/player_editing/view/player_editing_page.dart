import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/layout/fab_location.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_form.dart';
import 'package:ez_badminton_admin_app/widgets/progress_indicator_icon/progress_indicator_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class PlayerEditingPage extends StatelessWidget {
  const PlayerEditingPage({
    super.key,
    required this.players,
    required this.playingLevels,
    required this.ageGroups,
    required this.clubs,
    required this.competitions,
    required this.teams,
  });

  final List<Player> players;
  final List<PlayingLevel> playingLevels;
  final List<AgeGroup> ageGroups;
  final List<Club> clubs;
  final List<Competition> competitions;
  final List<Team> teams;

  static Route<Player?> route({
    required List<Player> players,
    required List<PlayingLevel> playingLevels,
    required List<AgeGroup> ageGroups,
    required List<Club> clubs,
    required List<Competition> competitions,
    required List<Team> teams,
  }) {
    return MaterialPageRoute<Player?>(
        builder: (_) => PlayerEditingPage(
              players: players,
              playingLevels: playingLevels,
              ageGroups: ageGroups,
              clubs: clubs,
              competitions: competitions,
              teams: teams,
            ));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => PlayerEditingCubit(
        context: context,
        playingLevels: playingLevels,
        ageGroups: ageGroups,
        clubs: clubs,
        competitions: competitions,
        teams: teams,
        players: players,
        playerRepository: context.read<CollectionRepository<Player>>(),
        clubRepository: context.read<CollectionRepository<Club>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        teamRepository: context.read<CollectionRepository<Team>>(),
      ),
      child: BlocConsumer<PlayerEditingCubit, PlayerEditingState>(
        listenWhen: (previous, current) =>
            current.formStatus == FormzSubmissionStatus.success,
        listener: (context, state) {
          Navigator.of(context).pop(state.player);
        },
        buildWhen: (previous, current) =>
            previous.isPure != current.isPure ||
            previous.formStatus != current.formStatus,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.addPlayer)),
            floatingActionButton: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 80, 40),
              child: FloatingActionButton.extended(
                onPressed: context.read<PlayerEditingCubit>().formSubmitted,
                label: Text(l10n.save),
                icon: state.formStatus == FormzSubmissionStatus.inProgress
                    ? const ProgressIndicatorIcon()
                    : const Icon(Icons.save),
              ),
            ),
            floatingActionButtonAnimator:
                FabTranslationAnimator(speedFactor: 2.5),
            floatingActionButtonLocation: state.isPure
                ? const EndOffscreenFabLocation()
                : FloatingActionButtonLocation.endFloat,
            body: const Align(
              child: SizedBox(
                width: 600,
                child: PlayerEditingForm(),
              ),
            ),
          );
        },
      ),
    );
  }
}
