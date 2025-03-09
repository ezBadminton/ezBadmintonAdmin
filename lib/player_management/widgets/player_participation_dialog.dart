import 'package:ez_badminton_admin_app/utils/selection_cubit/selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/map_listview/map_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:model_repository/model_repository.dart';

/// A widget that lists competitions with matches that a player withdraws
/// from or reenters into, thus changes their participation status in them.
class PlayerParticipationDialog extends StatelessWidget {
  const PlayerParticipationDialog({
    super.key,
    required this.matchList,
    required this.title,
    this.content,
  });

  final Map<Competition, List<TournamentMatch>> matchList;

  final Widget title;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => SelectionCubit<Competition>(
        items: matchList.keys.toList(),
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
  });

  final Map<Competition, List<TournamentMatch>> currentWalkovers;

  @override
  Widget build(BuildContext context) {
    return MapListView(
      itemMap: _buildMatchList(context),
      inset: 12,
      itemPadding: 15,
    );
  }

  Map<Widget, List<Widget>> _buildMatchList(BuildContext context) {
    Map<Widget, List<Widget>> matchList = currentWalkovers.map(
      (registration, matches) {
        return MapEntry(
          _CompetitionHeader(
            competition: registration,
            isReentering: matches.isNotEmpty,
          ),
          [
            for (var match in matches) _MatchInfo(match: match),
          ],
        );
      },
    );

    return matchList;
  }
}

class _CompetitionHeader extends StatelessWidget {
  const _CompetitionHeader({
    required this.competition,
    required this.isReentering,
  });

  final Competition competition;
  final bool isReentering;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var selectionCubit = context.read<SelectionCubit<Competition>>();

    return Row(
      children: [
        if (isReentering) ...[
          BlocBuilder<SelectionCubit<Competition>, Map<Competition, bool>>(
            buildWhen: (previous, current) =>
                previous[competition] != current[competition],
            builder: (context, state) {
              return Checkbox(
                value: state[competition],
                onChanged: (_) {
                  selectionCubit.itemToggled(competition);
                },
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        CompetitionLabel(
          competition: competition,
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

  final TournamentMatch match;

  @override
  Widget build(BuildContext context) {
    //var l10n = AppLocalizations.of(context)!;
    // TODO restore matchup label

    return Row(
      children: [
        Text(
          "MatchData ID: ${match.id}",
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
