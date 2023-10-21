import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/assets/badminton_icons_icons.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_match.dart';
import 'package:ez_badminton_admin_app/badminton_tournament_ops/cubit/tournament_progress_cubit.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_adding_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_renaming_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/match_assignment_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_court_view_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_cubit.dart';
import 'package:ez_badminton_admin_app/home/cubit/tab_navigation_state.dart';
import 'package:ez_badminton_admin_app/widgets/badminton_court/badminton_court.dart';
import 'package:ez_badminton_admin_app/widgets/competition_label/competition_label.dart';
import 'package:ez_badminton_admin_app/widgets/match_label/match_label.dart';
import 'package:ez_badminton_admin_app/widgets/running_match_info/running_match_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class CourtSlot extends StatelessWidget {
  const CourtSlot({
    super.key,
    required this.row,
    required this.column,
  });

  final int row;
  final int column;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 134 / 61,
        child: BlocBuilder<GymnasiumSelectionCubit, GymnasiumSelectionState>(
          builder: (context, state) {
            Court? courtInSlot = state.courtsOfGym.firstWhereOrNull(
              (c) => c.positionX == column && c.positionY == row,
            );

            if (courtInSlot == null) {
              return _EmptyCourtSlot(
                row: row,
                column: column,
              );
            } else {
              return _FilledCourtSlot(courtInSlot: courtInSlot);
            }
          },
        ),
      ),
    );
  }
}

class _FilledCourtSlot extends StatelessWidget {
  const _FilledCourtSlot({
    required this.courtInSlot,
  });

  final Court courtInSlot;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CourtRenamingCubit(
            court: courtInSlot,
            courtRepository: context.read<CollectionRepository<Court>>(),
          ),
        ),
        BlocProvider(
          create: (context) => CourtDeletionCubit(
            court: courtInSlot,
            courtRepository: context.read<CollectionRepository<Court>>(),
          ),
        ),
      ],
      child: BadmintonCourt(
        lineWidthScale: 2,
        lineColor: Colors.green.shade200,
        netColor: Colors.black12,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _CourtLabel(courtInSlot: courtInSlot),
            _CourtOptions(courtInSlot: courtInSlot),
          ],
        ),
      ),
    );
  }
}

class _CourtOptions extends StatelessWidget {
  const _CourtOptions({
    required this.courtInSlot,
  });

  final Court courtInSlot;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: AlignmentDirectional.topEnd,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _RenameButton(courtInSlot: courtInSlot),
                  const SizedBox(width: 10),
                  const _DeleteButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var deletionCubit = context.read<CourtDeletionCubit>();
    return BlocBuilder<CourtDeletionCubit, CourtDeletionState>(
      builder: (context, state) {
        return PopupMenuButton<VoidCallback>(
          onSelected: (callback) => callback(),
          tooltip: '',
          splashRadius: 19,
          enabled: state.formStatus != FormzSubmissionStatus.inProgress,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: deletionCubit.courtDeleted,
              child: Text(
                l10n.deleteSubject(l10n.court(1)),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RenameButton extends StatelessWidget {
  const _RenameButton({
    required this.courtInSlot,
  });

  final Court courtInSlot;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var renameCubit = context.read<CourtRenamingCubit>();
    var viewCubit = context.read<GymnasiumCourtViewCubit>();
    return BlocBuilder<CourtRenamingCubit, CourtRenamingState>(
      builder: (context, state) {
        return IconButton(
          onPressed: state.isFormOpen
              ? null
              : () {
                  renameCubit.formOpened();
                  viewCubit
                      .getViewController(courtInSlot.gymnasium)
                      .focusCourtSlot(
                        courtInSlot.positionY,
                        courtInSlot.positionX,
                      );
                },
          icon: const Icon(Icons.edit),
          tooltip: l10n.rename,
          splashRadius: 19,
        );
      },
    );
  }
}

class _CourtLabel extends StatelessWidget {
  const _CourtLabel({
    required this.courtInSlot,
  });

  final Court courtInSlot;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TournamentProgressCubit, TournamentProgressState>(
      builder: (context, progressState) {
        BadmintonMatch? matchOnCourt =
            progressState.occupiedCourts[courtInSlot];
        bool hasMatch = matchOnCourt != null;

        return BlocBuilder<TabNavigationCubit, TabNavigationState>(
          buildWhen: (previous, current) => current.selectedIndex == 2,
          builder: (context, state) {
            return Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CourtNameCard(
                      courtInSlot: courtInSlot,
                      fontSize: hasMatch ? 28 : 34,
                      alignment: hasMatch
                          ? AlignmentDirectional.topStart
                          : AlignmentDirectional.center,
                    ),
                    if (hasMatch) _MatchOnCourtCard(match: matchOnCourt),
                    if (state.tabChangeReason is MatchData && !hasMatch)
                      _MatchAssignmentButton(
                        matchData: state.tabChangeReason as MatchData,
                        court: courtInSlot,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CourtNameCard extends StatelessWidget {
  const _CourtNameCard({
    required this.courtInSlot,
    this.fontSize = 34,
    this.alignment = AlignmentDirectional.center,
  });

  final Court courtInSlot;

  final double fontSize;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Colors.black54,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 19.0,
          ),
          child: BlocBuilder<CourtRenamingCubit, CourtRenamingState>(
            buildWhen: (previous, current) =>
                previous.isFormOpen != current.isFormOpen,
            builder: (context, state) {
              if (state.isFormOpen) {
                return _RenamingForm(initialValue: state.name.value);
              } else {
                return Text(
                  courtInSlot.name,
                  style: TextStyle(fontSize: fontSize),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _RenamingForm extends StatelessWidget {
  _RenamingForm({
    required String initialValue,
  }) {
    _controller.text = initialValue;
    _focusNode.requestFocus();
  }

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CourtRenamingCubit>();
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CourtRenamingCubit, CourtRenamingState>(
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 190,
              child: TextField(
                style: const TextStyle(
                  fontSize: 21,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(courtNameMaxLength),
                ],
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                onChanged: cubit.nameChanged,
                onSubmitted: (_) => cubit.formSubmitted(),
                enabled: state.formStatus != FormzSubmissionStatus.inProgress,
              ),
            ),
            ElevatedButton(
              onPressed: cubit.formSubmitted,
              child: Text(l10n.done),
            ),
          ],
        );
      },
    );
  }
}

class _MatchAssignmentButton extends StatelessWidget {
  const _MatchAssignmentButton({
    required this.matchData,
    required this.court,
  });

  final MatchData matchData;
  final Court court;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => MatchAssignmentCubit(
        court: court,
        courtRepository: context.read<CollectionRepository<Court>>(),
        matchDataRepository: context.read<CollectionRepository<MatchData>>(),
      ),
      child: BlocConsumer<MatchAssignmentCubit, MatchAssignmentState>(
        listenWhen: (previous, current) =>
            previous.formStatus != FormzSubmissionStatus.success &&
            current.formStatus == FormzSubmissionStatus.success,
        listener: (context, state) {
          var cubit = context.read<TabNavigationCubit>();

          // Go back to match page
          cubit.tabChanged(4);
        },
        builder: (context, state) {
          var cubit = context.read<MatchAssignmentCubit>();

          return ElevatedButton(
            onPressed: () => cubit.assignMatch(matchData),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(BadmintonIcons.badminton_shuttlecock),
                  const SizedBox(width: 10),
                  Text(
                    l10n.playMatchHere,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MatchOnCourtCard extends StatelessWidget {
  const _MatchOnCourtCard({
    required this.match,
  });

  final BadmintonMatch match;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Colors.black38,
        ),
      ),
      color: Theme.of(context).colorScheme.surface.withOpacity(.7),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            CompetitionLabel(
              competition: match.competition,
              textStyle: const TextStyle(fontSize: 12),
              dividerPadding: 7,
            ),
            const SizedBox(height: 2),
            RunningMatchInfo(match: match),
            MatchLabel(
              match: match,
              orientation: Axis.horizontal,
              participantWidth: 183,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCourtSlot extends StatelessWidget {
  const _EmptyCourtSlot({
    required this.row,
    required this.column,
  });

  final int row;
  final int column;

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CourtAddingCubit>();
    return BadmintonCourt(
      lineColor: Colors.black26,
      netColor: Colors.black12,
      child: Center(
        child: SizedBox.square(
          dimension: 60,
          child: ElevatedButton(
            onPressed: () => cubit.courtAdded(row, column),
            style: const ButtonStyle(
              shape: MaterialStatePropertyAll(CircleBorder()),
              elevation: MaterialStatePropertyAll(6),
              padding: MaterialStatePropertyAll(EdgeInsets.zero),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
