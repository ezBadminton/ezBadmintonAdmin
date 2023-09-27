import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/bent_line/bent_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';
import 'package:tournament_mode/tournament_mode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class SingleEliminationMatchNode extends StatelessWidget {
  const SingleEliminationMatchNode({
    super.key,
    required this.match,
    required this.teamSize,
    required this.matchIndex,
    required this.isFirstRound,
    required this.isLastRound,
    required this.isEditable,
  });

  final BadmintonMatch match;
  final int teamSize;

  /// The index of the match within its round
  final int matchIndex;
  final bool isFirstRound;
  final bool isLastRound;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    double width = isEditable && isFirstRound ? 360 : 230;

    Widget matchCard = Card(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MatchParticipantNode(
            match.a,
            teamSize: teamSize,
            isEditable: isEditable && isFirstRound,
            width: width,
          ),
          SizedBox(
            width: width,
            child: const Divider(height: 0, thickness: 1),
          ),
          _MatchParticipantNode(
            match.b,
            teamSize: teamSize,
            isEditable: isFirstRound,
            width: width,
          ),
        ],
      ),
    );

    Color treeArmColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(.85);
    double treeArmThickness = 1.3;

    Widget incomingTreeArm = SizedBox(
      width: 10,
      child: Divider(
        height: 0,
        thickness: treeArmThickness,
        color: treeArmColor,
      ),
    );

    bool isEven = matchIndex.isEven;
    Widget outgoingTreeArm = Align(
      alignment: isEven ? Alignment.bottomCenter : Alignment.topCenter,
      child: FractionallySizedBox(
        heightFactor: .5,
        child: SizedBox(
          width: 10,
          child: BentLine(
            bendCorner: isEven ? Corner.topRight : Corner.bottomRight,
            bendRadius: 5.0,
            thickness: treeArmThickness,
            color: treeArmColor,
          ),
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        children: [
          if (!isFirstRound) incomingTreeArm,
          matchCard,
          if (!isLastRound) outgoingTreeArm,
        ],
      ),
    );
  }
}

class _MatchParticipantNode extends StatelessWidget {
  const _MatchParticipantNode(
    this.participant, {
    required this.teamSize,
    required this.isEditable,
    required this.width,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final bool isEditable;

  final double width;

  @override
  Widget build(BuildContext context) {
    Team? team = participant.resolvePlayer();

    if (isEditable && team != null) {
      return _EditableMatchParticipantLabel(
        participant: participant,
        teamSize: teamSize,
        width: width,
      );
    } else {
      double iconSize = IconTheme.of(context).size ?? 24;
      return _MatchParticipantLabel(
        participant: participant,
        teamSize: teamSize,
        width: width,
        leadingWidget:
            isEditable ? SizedBox(width: iconSize + 8, height: iconSize) : null,
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
    this.showClub = false,
    this.leadingWidget,
    // ignore: unused_element
    this.trailingWidget,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final Color? backgroundColor;
  final Color? textColor;

  final double width;

  final bool showClub;

  final Widget? leadingWidget;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    Widget label;
    if (leadingWidget == null && trailingWidget == null) {
      label = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _createParticipantLabel(context, participant),
      );
    } else {
      label = Row(
        children: [
          if (leadingWidget != null) leadingWidget!,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
    var l10n = AppLocalizations.of(context)!;

    TextStyle placeholderStyle = TextStyle(
      color: Theme.of(context).disabledColor,
    );

    if (participant.isBye) {
      return [
        Text(
          l10n.bye,
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
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final double width;

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
