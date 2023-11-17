import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_delete_state.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_status_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/player_editing_page.dart';
import 'package:ez_badminton_admin_app/player_management/widgets/player_withdrawal_info.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/view/registration_display_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class PlayerExpansionPanelBody extends StatelessWidget {
  const PlayerExpansionPanelBody({
    super.key,
    required this.player,
    required this.registrations,
  });

  final Player player;
  final List<CompetitionRegistration> registrations;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.05),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlayerRegistrations(registrations: registrations),
                      const SizedBox(width: 50),
                      _PlayerStatus(player: player),
                      const SizedBox(width: 50),
                      _PlayerNotes(player: player),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PlayerEditButton(player: player),
                      _PlayerDeleteMenu(player: player),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerDeleteMenu extends StatelessWidget {
  _PlayerDeleteMenu({
    required this.player,
  }) : super(key: ValueKey('${player.id}-delete-menu'));

  final Player player;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerDeleteCubit(
        player: player,
        playerRepository: context.read<CollectionRepository<Player>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        teamRepository: context.read<CollectionRepository<Team>>(),
      ),
      child: const _PlayerDeleteButton(),
    );
  }
}

class _PlayerDeleteButton extends StatelessWidget {
  const _PlayerDeleteButton();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    PlayerDeleteCubit cubit = context.read<PlayerDeleteCubit>();
    return DialogListener<PlayerDeleteCubit, PlayerDeleteState, bool>(
      builder: (context, state, reason) => ConfirmDialog(
        title: Text(l10n.reallyDeletePlayer),
        confirmButtonLabel: l10n.confirm,
        cancelButtonLabel: l10n.cancel,
      ),
      child: BlocBuilder<PlayerDeleteCubit, PlayerDeleteState>(
        buildWhen: (previous, current) =>
            previous.formStatus != current.formStatus,
        builder: (context, state) {
          return PopupMenuButton<VoidCallback>(
            onSelected: (callback) => callback(),
            tooltip: '',
            itemBuilder: (context) => [
              PopupMenuItem(
                value: () {
                  cubit.playerDeleted();
                },
                child: Text(
                  l10n.deletePlayer,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayerEditButton extends StatelessWidget {
  const _PlayerEditButton({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(PlayerEditingPage.route(player));
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Theme.of(context).primaryColorLight.withOpacity(.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit, size: 22),
            const SizedBox(width: 10),
            Text(l10n.editSubject(l10n.playerAndRegistrations)),
          ],
        ),
      ),
    );
  }
}

class _PlayerRegistrations extends StatelessWidget {
  const _PlayerRegistrations({
    required this.registrations,
  });

  final List<CompetitionRegistration> registrations;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Expanded(
      flex: 6,
      child: _PlayerDetailsSection(
        title: l10n.registrations,
        child: registrations.isEmpty
            ? Text(
                '- ${l10n.none} -',
                style: TextStyle(color: Theme.of(context).disabledColor),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final r in registrations)
                    RegistrationDisplayCard(
                      r,
                      showPartnerInput: true,
                    ),
                ],
              ),
      ),
    );
  }
}

class _PlayerStatus extends StatelessWidget {
  _PlayerStatus({
    required this.player,
  }) : super(key: ValueKey('${player.id}-status-menu'));

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var progressCubit = context.read<TournamentProgressCubit>();

    return BlocProvider(
      create: (context) => PlayerStatusCubit(
        player: player,
        tournamentProgressGetter: () => progressCubit.state,
        playerRepository: context.read<CollectionRepository<Player>>(),
        matchDataRepository: context.read<CollectionRepository<MatchData>>(),
      ),
      child: Expanded(
        flex: 2,
        child: _PlayerDetailsSection(
          title: l10n.status,
          child: Align(
            alignment: AlignmentDirectional.center,
            child: _PlayerStatusSwitcher(player: player),
          ),
        ),
      ),
    );
  }
}

class _PlayerStatusSwitcher extends StatelessWidget {
  const _PlayerStatusSwitcher({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayerStatusCubit>();
    return DialogListener<PlayerStatusCubit, PlayerStatusState, bool>(
      builder: (context, state, withdrawnMatches) {
        return ConfirmDialog(
          title: Text(l10n.playerWithdrawal),
          content: PlayerWithdrawalInfo(
            player: player,
            withdrawnMatches: withdrawnMatches as List<BadmintonMatch>,
          ),
          confirmButtonLabel: l10n.confirm,
          cancelButtonLabel: l10n.cancel,
        );
      },
      child: BlocBuilder<PlayerStatusCubit, PlayerStatusState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state.player.status == PlayerStatus.notAttending)
                Tooltip(
                  message: l10n.confirmAttendance,
                  preferBelow: false,
                  child: InkWell(
                    onTap: () {
                      cubit.statusChanged(PlayerStatus.attending);
                    },
                    customBorder: const CircleBorder(),
                    child: _statusIcon(context, state),
                  ),
                )
              else
                _statusIcon(context, state),
              const SizedBox(height: 5),
              PopupMenuButton<PlayerStatus>(
                tooltip: l10n.changeStatus,
                onSelected: cubit.statusChanged,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.playerStatus(player.status.name),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Icon(Icons.arrow_drop_down_sharp),
                    ],
                  ),
                ),
                itemBuilder: (context) => PlayerStatus.values
                    .map(
                      (s) => PopupMenuItem<PlayerStatus>(
                        value: s,
                        child: Text(l10n.playerStatus(s.name)),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusIcon(BuildContext context, PlayerStatusState state) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: player.status == PlayerStatus.attending
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).highlightColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 40,
          height: 40,
          child: state.formStatus == FormzSubmissionStatus.inProgress
              ? const CircularProgressIndicator()
              : Icon(
                  playerStatusIcons[player.status],
                  size: 40,
                ),
        ),
      ),
    );
  }
}

class _PlayerNotes extends StatelessWidget {
  const _PlayerNotes({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Expanded(
      flex: 5,
      child: _PlayerDetailsSection(
        title: l10n.notes,
        child: player.notes == null
            ? Text(
                '- ${l10n.none} -',
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              )
            : SelectableText(
                player.notes!,
              ),
      ),
    );
  }
}

class _PlayerDetailsSection extends StatelessWidget {
  const _PlayerDetailsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 7.0),
          child: Divider(height: 1),
        ),
        child,
      ],
    );
  }
}
