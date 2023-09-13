import 'package:ez_badminton_admin_app/court_management/gymnasium_editing/cubit/gymnasium_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/dialog_listener/dialog_listener.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/gym_floor_plan/gym_floor_plan.dart';
import 'package:ez_badminton_admin_app/widgets/help_tooltip_icon/help_tooltip_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';

class GymnasiumEditingForm extends StatelessWidget {
  const GymnasiumEditingForm({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return DialogListener<GymnasiumEditingCubit, GymnasiumEditingState, bool>(
      builder: (context, state, reason) => ConfirmDialog(
        title: Text(l10n.reduceHall),
        content: Text(l10n.reduceHallWarning),
        confirmButtonLabel: l10n.confirm,
        cancelButtonLabel: l10n.cancel,
      ),
      child: SizedBox(
        width: 960,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              l10n.description,
              style: const TextStyle(fontSize: 22),
            ),
            const Divider(height: 25, indent: 100, endIndent: 100),
            const _DescriptionForm(),
            const SizedBox(height: 30),
            const _GymFloorPlanTitle(),
            const Divider(height: 25, indent: 100, endIndent: 100),
            const SizedBox(height: 20),
            const _FloorPlanForm(),
          ],
        ),
      ),
    );
  }
}

class _GymFloorPlanTitle extends StatelessWidget {
  const _GymFloorPlanTitle();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.gymFloorPlan,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(width: 8),
        BlocBuilder<GymnasiumEditingCubit, GymnasiumEditingState>(
          builder: (context, state) {
            return HelpTooltipIcon(
              helpText: l10n.gymFloorPlanHelpMessage(
                state.columns.value,
                state.rows.value,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DescriptionForm extends StatelessWidget {
  const _DescriptionForm();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GymnasiumEditingCubit>();
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NameInput(
            labelText: '${l10n.name}*',
            onChanged: cubit.nameChanged,
            formInputGetter: (state) => state.name,
            initialValue: cubit.state.name.value,
          ),
          const SizedBox(width: 25),
          _DirectionsInput(
            labelText: l10n.directions,
            onChanged: cubit.directionsChanged,
            formInputGetter: (state) => state.directions,
            initialValue: cubit.state.directions.value,
          ),
        ],
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  _NameInput({
    required this.labelText,
    required this.onChanged,
    required this.formInputGetter,
    required String initialValue,
  }) {
    _controller.text = initialValue;
  }

  final String labelText;
  final FormzInput Function(GymnasiumEditingState state) formInputGetter;
  final void Function(String value) onChanged;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<GymnasiumEditingCubit, GymnasiumEditingState>(
      buildWhen: (previous, current) =>
          formInputGetter(previous) != formInputGetter(current) ||
          previous.formStatus != current.formStatus,
      builder: (context, state) {
        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: labelText,
            errorText: (state.formStatus == FormzSubmissionStatus.failure &&
                    formInputGetter(state).isNotValid)
                ? l10n.pleaseFillIn
                : null,
            counterText: ' ',
          ),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _DirectionsInput extends StatelessWidget {
  _DirectionsInput({
    required this.labelText,
    required this.onChanged,
    required this.formInputGetter,
    required String initialValue,
  }) {
    _controller.text = initialValue;
  }

  final String labelText;
  final FormzInput Function(GymnasiumEditingState state) formInputGetter;
  final void Function(String value) onChanged;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BlocBuilder<GymnasiumEditingCubit, GymnasiumEditingState>(
      buildWhen: (previous, current) =>
          formInputGetter(previous) != formInputGetter(current) ||
          previous.formStatus != current.formStatus,
      builder: (context, state) {
        return TextField(
          keyboardType: TextInputType.multiline,
          minLines: 3,
          maxLines: 5,
          controller: _controller,
          decoration: InputDecoration(
            labelText: labelText,
            errorText: (state.formStatus == FormzSubmissionStatus.failure &&
                    formInputGetter(state).isNotValid)
                ? l10n.pleaseFillIn
                : null,
            counterText: ' ',
          ),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _FloorPlanForm extends StatelessWidget {
  const _FloorPlanForm();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GymnasiumEditingCubit, GymnasiumEditingState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _RowInput(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ColumnInput(),
                SizedBox(
                  height: 400,
                  width: 800,
                  child: GymFloorPlan(
                    rows: state.rows.value,
                    columns: state.columns.value,
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),
            const SizedBox(width: 80),
          ],
        );
      },
    );
  }
}

class _RowInput extends StatelessWidget {
  const _RowInput();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GymnasiumEditingCubit>();
    return BlocBuilder<GymnasiumEditingCubit, GymnasiumEditingState>(
      builder: (context, state) {
        return SizedBox(
          width: 80,
          height: 200,
          child: Material(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadiusDirectional.horizontal(
              start: Radius.circular(20),
            ),
            elevation: 8,
            child: DefaultTextStyle(
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              child: Theme(
                data: ThemeData(
                  iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => cubit.rowsChanged(state.rows.value + 1),
                      icon: const Icon(Icons.add),
                      splashRadius: 25,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${state.rows.value}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Text(l10n.row(state.rows.value)),
                    const SizedBox(height: 12),
                    IconButton(
                      onPressed: () => cubit.rowsChanged(state.rows.value - 1),
                      icon: const Icon(Icons.remove),
                      splashRadius: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColumnInput extends StatelessWidget {
  const _ColumnInput();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<GymnasiumEditingCubit>();
    return BlocBuilder<GymnasiumEditingCubit, GymnasiumEditingState>(
      builder: (context, state) {
        return SizedBox(
          width: 220,
          height: 70,
          child: Material(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadiusDirectional.vertical(
              top: Radius.circular(20),
            ),
            elevation: 8,
            child: DefaultTextStyle(
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              child: Theme(
                data: ThemeData(
                  iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () =>
                          cubit.columnsChanged(state.columns.value - 1),
                      icon: const Icon(Icons.remove),
                      splashRadius: 25,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.columns.value}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Text(l10n.column(state.columns.value)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () =>
                          cubit.columnsChanged(state.columns.value + 1),
                      icon: const Icon(Icons.add),
                      splashRadius: 25,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
