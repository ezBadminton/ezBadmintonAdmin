import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_deletion_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_adding_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/court_editing/cubit/court_renaming_cubit.dart';
import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_selection_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/badminton_court/badminton_court.dart';
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
    return BlocBuilder<GymnasiumSelectionCubit, GymnasiumSelectionState>(
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
      child: Stack(
        children: [
          RotatedBox(
            quarterTurns: 1,
            child: BadmintonCourt(
              lineWidthScale: 1.5,
              lineColor: Colors.green.shade200,
              netColor: Colors.black12,
            ),
          ),
          _CourtNameCard(courtInSlot: courtInSlot),
          _CourtOptions(courtInSlot: courtInSlot),
        ],
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
    return const Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(
          alignment: AlignmentDirectional.topEnd,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _RenameButton(),
                  SizedBox(width: 10),
                  _DeleteButton(),
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
          splashRadius: 25,
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
  const _RenameButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var renameCubit = context.read<CourtRenamingCubit>();
    return BlocBuilder<CourtRenamingCubit, CourtRenamingState>(
      builder: (context, state) {
        return IconButton(
          onPressed: state.isFormOpen ? null : renameCubit.formOpened,
          icon: const Icon(Icons.edit),
          tooltip: l10n.rename,
          splashRadius: 25,
        );
      },
    );
  }
}

class _CourtNameCard extends StatelessWidget {
  const _CourtNameCard({
    required this.courtInSlot,
  });

  final Court courtInSlot;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Center(
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
              vertical: 5.0,
              horizontal: 25.0,
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
                    style: const TextStyle(
                      fontSize: 45,
                    ),
                  );
                }
              },
            ),
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
              width: 250,
              child: TextField(
                style: const TextStyle(
                  fontSize: 28,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(courtNameMaxLength),
                ],
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  labelStyle: const TextStyle(
                    fontSize: 18,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        RotatedBox(
          quarterTurns: 1,
          child: BadmintonCourt(
            lineColor: Colors.black26,
            netColor: Colors.black12,
          ),
        ),
        SizedBox.square(
          dimension: 70,
          child: ElevatedButton(
            onPressed: () => cubit.courtAdded(row, column),
            style: const ButtonStyle(
              shape: MaterialStatePropertyAll(CircleBorder()),
              elevation: MaterialStatePropertyAll(6),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
