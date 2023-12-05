import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/view/result_input_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:ez_badminton_admin_app/widgets/match_info/match_info.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/bracket_section_subtree.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/match_participant_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tournament_mode/tournament_mode.dart';

class MatchLabel extends StatelessWidget {
  const MatchLabel({
    super.key,
    required this.match,
    this.infoStyle = const TextStyle(fontSize: 12),
    this.opponentStyle = const TextStyle(fontSize: 16),
  });

  final BadmintonMatch match;

  final TextStyle infoStyle;
  final TextStyle opponentStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompetitionLabel(
          competition: match.competition,
          textStyle: infoStyle,
          dividerPadding: 6,
        ),
        const SizedBox(height: 5),
        RunningMatchInfo(match: match, textStyle: infoStyle),
        const SizedBox(height: 5),
        MatchupLabel(
          match: match,
          orientation: Axis.horizontal,
          textStyle: opponentStyle,
        ),
        const SizedBox(height: 5),
        Text(match.court!.name, style: infoStyle),
      ],
    );
  }
}

class MatchupLabel extends StatelessWidget {
  const MatchupLabel({
    super.key,
    required this.match,
    this.orientation = Axis.vertical,
    this.participantWidth = 185,
    this.useFullName = false,
    this.boldLastName = false,
    this.textStyle,
  });

  final BadmintonMatch match;

  final Axis orientation;

  final double participantWidth;

  final bool useFullName;

  final bool boldLastName;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    TextStyle? lastNameTextStyle =
        boldLastName ? const TextStyle(fontWeight: FontWeight.bold) : null;

    List<Widget> widgets = [
      MatchParticipantLabel(
        match.a,
        teamSize: match.competition.teamSize,
        isEditable: false,
        width: participantWidth,
        alignment: orientation == Axis.vertical
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.end,
        padding: orientation == Axis.vertical
            ? const EdgeInsets.only(bottom: 8)
            : const EdgeInsets.only(right: 8),
        placeholderLabel: Text(
          l10n.qualificationPending,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        useFullName: useFullName,
        textStyle: textStyle,
        lastNameTextStyle: lastNameTextStyle,
      ),
      Text(
        '- ${l10n.versusAbbreviated} -',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).disabledColor,
        ),
      ),
      MatchParticipantLabel(
        match.b,
        teamSize: match.competition.teamSize,
        isEditable: false,
        width: participantWidth,
        alignment: orientation == Axis.vertical
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        padding: orientation == Axis.vertical
            ? const EdgeInsets.only(top: 8)
            : const EdgeInsets.only(left: 8),
        placeholderLabel: Text(
          l10n.qualificationPending,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        useFullName: useFullName,
        textStyle: textStyle,
        lastNameTextStyle: lastNameTextStyle,
      ),
    ];

    if (orientation == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: widgets,
      );
    }
  }
}

class MatchupCard extends StatelessWidget {
  const MatchupCard({
    super.key,
    required this.match,
    this.isEditable = false,
    this.width,
    this.placeholderLabels = const {},
    this.showResult = false,
  });

  final BadmintonMatch match;
  final bool isEditable;
  final double? width;
  final Map<MatchParticipant, String> placeholderLabels;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    MatchParticipant? winner = showResult ? match.getWinner() : null;

    Widget matchupCard = Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: IntrinsicHeight(
        child: SizedBox(
          width: width,
          child: Row(
            children: [
              _WalkoverInfo(match: match),
              _ScoreEditButton(match: match),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: showResult
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    MatchParticipantLabel(
                      match.a,
                      teamSize: match.competition.teamSize,
                      isEditable: isEditable,
                      placeholderLabel: placeholderLabels.containsKey(match.a)
                          ? Text(placeholderLabels[match.a]!)
                          : null,
                      textStyle: winner == match.a
                          ? TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : null,
                      alignment: showResult
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                    ),
                    const Divider(height: 0, thickness: 1),
                    MatchParticipantLabel(
                      match.b,
                      teamSize: match.competition.teamSize,
                      isEditable: isEditable,
                      placeholderLabel: placeholderLabels.containsKey(match.b)
                          ? Text(placeholderLabels[match.b]!)
                          : null,
                      textStyle: winner == match.b
                          ? TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : null,
                      alignment: showResult
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                    ),
                  ],
                ),
              ),
              if (showResult) _Scoreline(match: match),
            ],
          ),
        ),
      ),
    );

    return BracketSectionSubtree(
      tournamentDataObject: match,
      child: matchupCard,
    );
  }
}

class _Scoreline extends StatelessWidget {
  const _Scoreline({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    int maxSets = match.competition.tournamentModeSettings!.winningSets * 2 - 1;

    Color dividerColor = match.isWalkover
        ? Theme.of(context).disabledColor.withOpacity(.3)
        : Theme.of(context).primaryColor.withOpacity(.55);

    List<(int, int)?> scores;

    if (match.isBye || (match.getWinner()?.isBye ?? false)) {
      scores = List.generate(maxSets, (index) => null);
    } else {
      scores = List.generate(
        maxSets,
        (index) {
          MatchSet? set = match.score?.elementAtOrNull(index);

          return set == null ? null : (set.team1Points, set.team2Points);
        },
      );
    }

    List<Widget> scoreColumns = scores.map(
      (score) {
        bool? winner1 = score == null ? null : score.$1 > score.$2;
        bool? winner2 = score == null ? null : score.$2 > score.$1;
        Widget score1 = _buildScoreNumber(
          context,
          score?.$1,
          winner1,
          match.hasWinner,
        );
        Widget score2 = _buildScoreNumber(
          context,
          score?.$2,
          winner2,
          match.hasWinner,
        );

        return _ScoreContainer(
          isWalkover: match.isWalkover,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Center(child: score1),
              ),
              Divider(
                height: 0,
                thickness: 1,
                color: dividerColor,
              ),
              Expanded(
                child: Center(child: score2),
              ),
            ],
          ),
        );
      },
    ).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (Widget column in scoreColumns) ...[
          if (scoreColumns.first != column)
            VerticalDivider(
              width: 2,
              thickness: 2,
              color: dividerColor,
            ),
          column,
        ],
      ],
    );
  }

  Widget _buildScoreNumber(
    BuildContext context,
    int? score,
    bool? isWinner,
    bool isMatchComplete,
  ) {
    if (score == null) {
      if (isMatchComplete) {
        return Text(
          '⟋',
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).disabledColor,
          ),
        );
      } else {
        return const SizedBox();
      }
    }

    return Text(
      '$score',
      style: TextStyle(
        fontSize: 17,
        fontWeight: isWinner! ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _ScoreContainer extends StatelessWidget {
  const _ScoreContainer({
    required this.isWalkover,
    required this.child,
  });

  final bool isWalkover;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isWalkover
        ? Theme.of(context).disabledColor.withOpacity(.13)
        : Theme.of(context).primaryColorLight;

    return Container(
      width: 40,
      color: backgroundColor,
      child: child,
    );
  }
}

class _ScoreEditButton extends StatelessWidget {
  const _ScoreEditButton({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TournamentProgressCubit, TournamentProgressState>(
      builder: (context, state) {
        bool isEditable = state.editableMatches.contains(match);

        if (!isEditable) {
          return const SizedBox();
        }

        return Tooltip(
          message: l10n.editResult,
          child: SizedBox(
            width: 36,
            child: SizedBox.expand(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ResultInputDialog(match: match),
                  );
                },
                child: const Icon(Icons.edit),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WalkoverInfo extends StatelessWidget {
  const _WalkoverInfo({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    if (!match.isWalkover) {
      return const SizedBox();
    }

    var l10n = AppLocalizations.of(context)!;

    return Container(
      width: 30,
      color: Theme.of(context).disabledColor.withOpacity(.13),
      child: SizedBox.expand(
        child: HelpTooltipIcon(
          helpText: l10n.walkover,
          icon: Icons.info_outline,
        ),
      ),
    );
  }
}
