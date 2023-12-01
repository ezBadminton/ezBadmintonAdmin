import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/draw_management/cubit/draw_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_bracket_explorer/cubit/interactive_view_blocker_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_hero/local_hero.dart';
import 'package:provider/provider.dart';
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
    this.width,
    this.showClub = false,
    this.useFullName = true,
    this.placeholderLabel,
    this.alignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
    this.byeLabel,
    this.textStyle,
    this.lastNameTextStyle,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final bool isEditable;

  final double? width;

  final bool showClub;

  final bool useFullName;

  final Widget? placeholderLabel;

  final CrossAxisAlignment alignment;

  final EdgeInsets padding;

  final Widget? byeLabel;

  final TextStyle? textStyle;
  final TextStyle? lastNameTextStyle;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    Team? team = participant.resolvePlayer();
    Widget byeLabel = this.byeLabel ??
        Text(
          l10n.bye,
          style: TextStyle(color: Theme.of(context).disabledColor),
        );

    if (isEditable && team != null) {
      return _EditableMatchParticipantLabel(
        participant: participant,
        teamSize: teamSize,
        width: width,
        alignment: alignment,
        padding: padding,
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
        useFullName: useFullName,
        placeholderLabel: placeholderLabel,
        alignment: alignment,
        padding: padding,
        byeLabel: byeLabel,
        textStyle: textStyle,
        lastNameTextStyle: lastNameTextStyle,
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
    required this.useFullName,
    this.leadingWidget,
    // ignore: unused_element
    this.trailingWidget,
    this.placeholderLabel,
    required this.alignment,
    required this.padding,
    required this.byeLabel,
    required this.textStyle,
    required this.lastNameTextStyle,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final Color? backgroundColor;
  final Color? textColor;

  final double? width;

  final bool showClub;

  final bool useFullName;

  final Widget? leadingWidget;
  final Widget? trailingWidget;

  final Widget? placeholderLabel;

  final CrossAxisAlignment alignment;

  final EdgeInsets padding;

  final Widget byeLabel;

  final TextStyle? textStyle;
  final TextStyle? lastNameTextStyle;

  @override
  Widget build(BuildContext context) {
    Widget label;
    if (leadingWidget == null && trailingWidget == null) {
      label = Column(
        mainAxisSize: MainAxisSize.min,
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
              mainAxisSize: MainAxisSize.min,
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
          padding: padding,
          child: label,
        ),
      ),
    );
  }

  List<Widget> _createParticipantLabel(
    BuildContext context,
    MatchParticipant<Team> participant,
  ) {
    if (participant.isBye) {
      return [
        byeLabel,
        ...List.generate(teamSize - 1, (index) => const Text('')),
      ];
    }

    Team? team = participant.resolvePlayer();

    if (team == null) {
      return List.generate(
        teamSize,
        (index) => (index == 0 && placeholderLabel != null)
            ? placeholderLabel!
            : const Text(''),
      );
    }

    return team.players
        .map(
          (p) => _getPlayerName(
            p,
            textColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        )
        .toList();
  }

  RichText _getPlayerName(Player player, Color textColor) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: textStyle ?? TextStyle(color: textColor),
        children: [
          if (useFullName) TextSpan(text: '${player.firstName} '),
          TextSpan(
            text: player.lastName,
            style: lastNameTextStyle,
          ),
          if (showClub && player.club != null)
            TextSpan(text: ' (${player.club!.name})'),
        ],
      ),
    );
  }
}

class _EditableMatchParticipantLabel extends StatelessWidget {
  const _EditableMatchParticipantLabel({
    required this.participant,
    required this.teamSize,
    required this.width,
    required this.alignment,
    required this.padding,
    required this.byeLabel,
  });

  final MatchParticipant<Team> participant;
  final int teamSize;

  final double? width;

  final CrossAxisAlignment alignment;
  final EdgeInsets padding;

  final Widget byeLabel;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    Team team = participant.resolvePlayer()!;
    InteractiveViewBlockerCubit? blockerCubit;
    try {
      blockerCubit = context.read<InteractiveViewBlockerCubit>();
    } finally {}

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
        useFullName: true,
        alignment: alignment,
        padding: padding,
        byeLabel: byeLabel,
        textStyle: null,
        lastNameTextStyle: null,
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
          onDragStarted: blockerCubit?.removeEdgePanningBlock,
          onDragEnd: (_) => blockerCubit?.addEdgePanningBlock(),
          data: team,
          feedback: _teamNames(team),
          maxSimultaneousDrags: 1,
          dragAnchorStrategy: (draggable, context, position) =>
              const Offset(0, 0),
          childWhenDragging: _MatchParticipantLabel(
            participant: participant,
            teamSize: teamSize,
            leadingWidget: draggingIndicator,
            textColor: Theme.of(context).disabledColor,
            width: width,
            showClub: true,
            useFullName: true,
            alignment: alignment,
            padding: padding,
            byeLabel: byeLabel,
            textStyle: null,
            lastNameTextStyle: null,
          ),
          child: _MatchParticipantLabel(
            participant: participant,
            teamSize: teamSize,
            backgroundColor: candidateData.isEmpty
                ? Theme.of(context).cardColor
                : Theme.of(context).primaryColor.withOpacity(.2),
            leadingWidget: Tooltip(
              message: l10n.reorder,
              triggerMode: TooltipTriggerMode.manual,
              waitDuration: const Duration(milliseconds: 500),
              child: dragIndicator,
            ),
            width: width,
            showClub: true,
            useFullName: true,
            alignment: alignment,
            padding: padding,
            byeLabel: byeLabel,
            textStyle: null,
            lastNameTextStyle: null,
          ),
        ),
      ),
    );
  }

  Widget _teamNames(Team team) {
    StringBuffer names = StringBuffer();
    for (Player p in team.players) {
      names.writeln(display_strings.playerWithClub(p));
    }

    String teamNames = names.toString().trimRight();

    return Transform.translate(
      offset: const Offset(-10, -5),
      child: FractionalTranslation(
        translation: const Offset(-1, 0),
        child: Text(teamNames),
      ),
    );
  }
}
