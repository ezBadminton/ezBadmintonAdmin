import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_editing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class MatchParticipantLabel extends StatelessWidget {
  const MatchParticipantLabel(
    this.participant, {
    super.key,
    required this.teamSize,
    required this.isEditable,
    required this.width,
    this.showClub = false,
    this.alignment = CrossAxisAlignment.start,
    this.byeLabel,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final bool isEditable;

  final double width;

  final bool showClub;

  final CrossAxisAlignment alignment;

  final String? byeLabel;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    Team? team = participant.resolvePlayer();
    String byeLabel = this.byeLabel ?? l10n.bye;

    if (isEditable && team != null) {
      return _EditableMatchParticipantLabel(
        participant: participant,
        teamSize: teamSize,
        width: width,
        alignment: alignment,
        byeLabel: byeLabel,
      );
    } else {
      double iconSize = IconTheme.of(context).size ?? 24;
      return _MatchParticipantLabel(
        participant: participant,
        teamSize: teamSize,
        width: width,
        leadingWidget:
            isEditable ? SizedBox(width: iconSize + 8, height: iconSize) : null,
        showClub: showClub,
        alignment: alignment,
        byeLabel: byeLabel,
      );
    }
  }
}

class _MatchParticipantLabel extends StatelessWidget {
  const _MatchParticipantLabel({
    required this.participant,
    required this.teamSize,
    this.backgroundColor,
    this.textColor,
    required this.width,
    required this.showClub,
    this.leadingWidget,
    // ignore: unused_element
    this.trailingWidget,
    required this.alignment,
    required this.byeLabel,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final Color? backgroundColor;
  final Color? textColor;

  final double width;

  final bool showClub;

  final Widget? leadingWidget;
  final Widget? trailingWidget;

  final CrossAxisAlignment alignment;

  final String byeLabel;

  @override
  Widget build(BuildContext context) {
    Widget label;
    if (leadingWidget == null && trailingWidget == null) {
      label = Column(
        crossAxisAlignment: alignment,
        children: _createParticipantLabel(context, participant),
      );
    } else {
      label = Row(
        children: [
          if (leadingWidget != null) leadingWidget!,
          Expanded(
            child: Column(
              crossAxisAlignment: alignment,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _createParticipantLabel(context, participant),
            ),
          ),
          if (trailingWidget != null) trailingWidget!,
        ],
      );
    }

    return SizedBox(
      width: width,
      child: Container(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: label,
        ),
      ),
    );
  }

  List<Text> _createParticipantLabel(
    BuildContext context,
    MatchParticipant<Team> participant,
  ) {
    TextStyle placeholderStyle = TextStyle(
      color: Theme.of(context).disabledColor,
    );

    if (participant.isBye) {
      return [
        Text(
          byeLabel,
          style: placeholderStyle,
        ),
        ...List.generate(teamSize - 1, (index) => const Text('')),
      ];
    }

    Team? team = participant.resolvePlayer();

    if (team == null) {
      return List.generate(teamSize, (index) => const Text(''));
    }

    return [
      for (Player player in team.players)
        Text(
          showClub
              ? display_strings.playerWithClub(player)
              : display_strings.playerName(player),
          style: TextStyle(
            color: textColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
    ];
  }
}

class _EditableMatchParticipantLabel extends StatelessWidget {
  const _EditableMatchParticipantLabel({
    required this.participant,
    required this.teamSize,
    required this.width,
    required this.alignment,
    required this.byeLabel,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final double width;

  final CrossAxisAlignment alignment;

  final String byeLabel;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    Team team = participant.resolvePlayer()!;

    Widget dragIndicator = const Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: Icon(
        Icons.drag_indicator,
        color: Colors.black38,
      ),
    );

    Widget draggingIndicator = const Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: Icon(
        Icons.unfold_more,
        color: Colors.black38,
      ),
    );

    return LocalHero(
      key: ValueKey<String>('local_hero${team.id}'),
      tag: team.id,
      enabled: true,
      flightShuttleBuilder: (context, animation, child) =>
          _MatchParticipantLabel(
        participant: participant,
        teamSize: teamSize,
        leadingWidget: dragIndicator,
        width: width,
        showClub: true,
        alignment: alignment,
        byeLabel: byeLabel,
      ),
      child: DragTarget<Team>(
        onWillAccept: (droppedTeam) {
          return droppedTeam != team;
        },
        onAccept: (droppedTeam) {
          var cubit = context.read<DrawEditingCubit>();
          cubit.swapDrawMembers(team, droppedTeam);
        },
        builder: (context, candidateData, rejectedData) => Draggable<Team>(
          data: team,
          feedback: _teamNames(team),
          childWhenDragging: _MatchParticipantLabel(
            participant: participant,
            teamSize: teamSize,
            leadingWidget: draggingIndicator,
            textColor: Theme.of(context).disabledColor,
            width: width,
            showClub: true,
            alignment: alignment,
            byeLabel: byeLabel,
          ),
          child: _MatchParticipantLabel(
            participant: participant,
            teamSize: teamSize,
            backgroundColor: candidateData.isEmpty
                ? Theme.of(context).cardColor
                : Theme.of(context).primaryColor.withOpacity(.2),
            leadingWidget: Tooltip(
              message: l10n.reorder,
              waitDuration: const Duration(milliseconds: 500),
              child: dragIndicator,
            ),
            width: width,
            showClub: true,
            alignment: alignment,
            byeLabel: byeLabel,
          ),
        ),
      ),
    );
  }

  Text _teamNames(Team team) {
    StringBuffer names = StringBuffer();
    for (Player p in team.players) {
      names.writeln(display_strings.playerWithClub(p));
    }

    String teamNames = names.toString().trimRight();

    return Text(teamNames);
  }
}
