import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/utils/selection_cubit/selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/map_listview/map_listview.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

/// A widget that lists competitions with matches that a player withdraws
/// from or reenters into, thus changes their participation status in them.
class PlayerParticipationDialog extends StatelessWidget {
  const PlayerParticipationDialog({
    super.key,
    required this.matchList,
    required this.changableParticipations,
    required this.title,
    this.content,
  });

  final Map<CompetitionRegistration, List<BadmintonMatch>> matchList;
  final List<CompetitionRegistration> changableParticipations;

  final Widget title;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => SelectionCubit<Competition>(
        items: changableParticipations.map((p) => p.competition).toList(),
      ),
      child: Builder(builder: (context) {
        var selectionCubit = context.read<SelectionCubit<Competition>>();

        return AlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (content != null) ...[
                  content!,
                  const SizedBox(height: 30),
                ],
                _PlayerParticipationMenu(
                  currentWalkovers: matchList,
                  reenteringRegistrations: changableParticipations,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                selectionCubit.state.values.toList(),
              ),
              child: Text(l10n.confirm),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(l10n.cancel),
            ),
          ],
        );
      }),
    );
  }
}

class _PlayerParticipationMenu extends StatelessWidget {
  const _PlayerParticipationMenu({
    required this.currentWalkovers,
    required this.reenteringRegistrations,
  });

  final Map<CompetitionRegistration, List<BadmintonMatch>> currentWalkovers;
  final List<CompetitionRegistration> reenteringRegistrations;

  @override
  Widget build(BuildContext context) {
    return MapListView(
      itemMap: _buildMatchList(context),
      inset: 12,
      itemPadding: 15,
    );
  }

  Map<Widget, List<Widget>> _buildMatchList(BuildContext context) {
    Iterable<Team> reenteringTeams = reenteringRegistrations.map((r) => r.team);

    Map<Widget, List<Widget>> matchList = currentWalkovers.map(
      (registration, matches) {
        return MapEntry(
          _CompetitionHeader(
            registration: registration,
            isReentering: reenteringTeams.contains(registration.team),
          ),
          [
            for (BadmintonMatch match in matches) _MatchInfo(match: match),
          ],
        );
      },
    );

    return matchList;
  }
}

class _CompetitionHeader extends StatelessWidget {
  const _CompetitionHeader({
    required this.registration,
    required this.isReentering,
  });

  final CompetitionRegistration registration;
  final bool isReentering;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var selectionCubit = context.read<SelectionCubit<Competition>>();

    Competition registeredCompetition = registration.competition;

    return Row(
      children: [
        if (isReentering) ...[
          BlocBuilder<SelectionCubit<Competition>, Map<Competition, bool>>(
            buildWhen: (previous, current) =>
                previous[registeredCompetition] !=
                current[registeredCompetition],
            builder: (context, state) {
              return Checkbox(
                value: state[registeredCompetition],
                onChanged: (_) {
                  selectionCubit.itemToggled(registeredCompetition);
                },
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        CompetitionLabel(
          competition: registeredCompetition,
          textStyle: const TextStyle(fontSize: 18),
        ),
        if (!isReentering) ...[
          const SizedBox(width: 15),
          Text(
            l10n.playerCannotReenter,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ]
      ],
    );
  }
}

class _MatchInfo extends StatelessWidget {
  const _MatchInfo({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Text(
          display_strings.matchRoundName(l10n, match) ?? '',
          style: const TextStyle(fontSize: 14),
        ),
        MatchupLabel(
          match: match,
          orientation: Axis.horizontal,
          textStyle: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          useFullName: true,
          participantWidth: 270,
        ),
      ],
    );
  }
}
