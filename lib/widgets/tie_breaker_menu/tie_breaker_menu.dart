import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_implicit_animated_list.dart';
import 'package:ez_badminton_admin_app/widgets/implicit_animated_list/reorderable_item_gap.dart';
import 'package:ez_badminton_admin_app/widgets/tie_breaker_menu/cubit/tie_breaker_cubit.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class _TieBreakerDialog extends StatelessWidget {
  const _TieBreakerDialog({
    required this.tie,
  });

  final List<Team> tie;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    var cubit = context.read<TieBreakerCubit>();

    Widget dialogContent = SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.breakTieInfo),
          const SizedBox(height: 10),
          const Divider(
            height: 35,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Flexible(child: _TieBreakerList(tie: tie)),
        ],
      ),
    );

    String dialogTitle =
        cubit.existingTieBreaker == null ? l10n.breakTie : l10n.editTieBreaker;

    return BlocListener<TieBreakerCubit, TieBreakerState>(
      listenWhen: (previous, current) =>
          previous.formStatus != FormzSubmissionStatus.success &&
          current.formStatus == FormzSubmissionStatus.success,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: AlertDialog(
        title: Text(dialogTitle),
        content: dialogContent,
        actions: [
          Row(
            children: [
              if (cubit.existingTieBreaker != null)
                TextButton(
                  onPressed: cubit.existingTieBreakerDeleted,
                  child: Text(
                    l10n.deleteTieBreaker,
                    style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(.7),
                    ),
                  ),
                ),
              const Expanded(child: SizedBox()),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 15),
              TextButton(
                onPressed: cubit.tieBreakerSubmitted,
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TieBreakerMenu extends StatelessWidget {
  const TieBreakerMenu({
    super.key,
    required this.competition,
    required this.tie,
  });

  final Competition competition;

  final List<Team> tie;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TieBreakerCubit>(
      create: (context) => TieBreakerCubit(
        competition: competition,
        tie: tie,
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        tieBreakerRepository: context.read<CollectionRepository<TieBreaker>>(),
      ),
      child: _TieBreakerDialog(tie: tie),
    );
  }
}

class _TieBreakerList extends StatelessWidget {
  const _TieBreakerList({
    required this.tie,
  });

  final List<Team> tie;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<TieBreakerCubit>();

    return SizedBox(
      width: 500,
      child: BlocBuilder<TieBreakerCubit, TieBreakerState>(
        builder: (context, state) {
          return ReorderableImplicitAnimatedList(
            elements: state.tie,
            onReorder: cubit.tieReordered,
            itemBuilder: _itemBuilder,
            itemDragBuilder: _itemDragBuilder,
            itemPlaceholderBuilder: _itemPlaceholderBuilder,
            itemReorderBuilder: _itemReorderBuilder,
            duration: const Duration(milliseconds: 100),
            shrinkWrap: true,
            draggingEnabled:
                state.formStatus != FormzSubmissionStatus.inProgress &&
                    state.formStatus != FormzSubmissionStatus.success,
          );
        },
      ),
    );
  }

  Widget _itemBuilder(
    BuildContext context,
    Team team,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
    int? hoveringIndex,
  ) {
    Widget listItem = _TeamItem(
      team: team,
      hoveringIndex: hoveringIndex,
      draggableWrapper: draggableWrapper,
    );

    return listItem;
  }

  Widget _itemPlaceholderBuilder(
    BuildContext context,
    Team team,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
    int? hoveringIndex,
  ) {
    Widget listItem = _TeamItem(
      team: team,
      hoveringIndex: hoveringIndex,
      draggableWrapper: draggableWrapper,
      leadingIcon: Icons.unfold_more,
      textStyle: TextStyle(color: Theme.of(context).disabledColor),
    );

    return listItem;
  }

  Widget _itemDragBuilder(
    BuildContext context,
    Team team,
  ) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: team.players
            .map(
              (player) => Text(
                display_strings.playerName(player),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _itemReorderBuilder(
    BuildContext context,
    Team team,
    Animation<double> animation,
    DraggableWrapper draggableWrapper,
    int indexDelta,
  ) {
    return SlideTransition(
      position: animation.drive(Tween<Offset>(
        begin: Offset(0, -indexDelta.toDouble()),
        end: Offset.zero,
      )),
      child: _TeamItem(
        team: team,
        draggableWrapper: draggableWrapper,
      ),
    );
  }
}

class _TeamItem extends StatelessWidget {
  const _TeamItem({
    required this.team,
    this.hoveringIndex,
    required this.draggableWrapper,
    this.leadingIcon = Icons.drag_indicator,
    this.textStyle,
  });

  final Team team;

  final int? hoveringIndex;

  final DraggableWrapper draggableWrapper;

  final IconData leadingIcon;

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<TieBreakerCubit>();

    int index = cubit.state.tie.indexOf(team);

    Widget playerNames = buildPlayerNames();

    Widget draggableTeam = draggableWrapper(
      context,
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            leadingIcon,
            color: Theme.of(context).disabledColor,
          ),
          SizedBox(
            width: 10,
            height: 20,
            // Put invisible container into the gap to make the area draggable
            child: Container(color: Colors.transparent),
          ),
          playerNames,
        ],
      ),
    );

    Widget listItem = Column(
      children: [
        if (index != 0)
          const Divider(
            height: 1,
            thickness: 1,
          ),
        ReorderableItemGap(
          elementIndex: index,
          top: true,
          hoveringIndex: hoveringIndex,
        ),
        draggableTeam,
        ReorderableItemGap(
          elementIndex: index,
          top: false,
          hoveringIndex: hoveringIndex,
        ),
      ],
    );

    return listItem;
  }

  Widget buildPlayerNames() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: team.players
          .map(
            (player) => Text(
              display_strings.playerName(player),
              style: textStyle,
            ),
          )
          .toList(),
    );
  }
}

class TieBreakerButton extends StatelessWidget {
  const TieBreakerButton({
    super.key,
    required this.competition,
    required this.tie,
    required this.tieRankLabel,
    required this.buttonLabel,
  });

  final Competition competition;
  final List<Team> tie;

  final String tieRankLabel;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return TieBreakerMenu(
                competition: competition,
                tie: tie,
              );
            },
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tieRankLabel,
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              buttonLabel,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
