import 'package:ez_badminton_admin_app/widgets/custom_input_fields/clearable_dropdown_button.dart';
import 'package:ez_badminton_admin_app/widgets/dialogs/cubit/selection_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DropdownSelectionDialog<T> extends StatelessWidget {
  const DropdownSelectionDialog({
    required this.options,
    required this.displayStringFunction,
    this.title,
    this.content,
    required this.confirmButtonLabelFunction,
    required this.cancelButtonLabel,
    super.key,
  });

  final List<T> options;
  final String Function(T) displayStringFunction;

  final Widget? title;
  final Widget? content;

  final String Function(T currentSelection) confirmButtonLabelFunction;
  final String cancelButtonLabel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectionCubit(options.first),
      child: _DialogBody<T>(
        options: options,
        displayStringFunction: displayStringFunction,
        title: title,
        content: content,
        confirmButtonLabelFunction: confirmButtonLabelFunction,
        cancelButtonLabel: cancelButtonLabel,
      ),
    );
  }
}

class _DialogBody<T> extends StatelessWidget {
  const _DialogBody({
    required this.options,
    required this.displayStringFunction,
    required this.title,
    required this.content,
    required this.confirmButtonLabelFunction,
    required this.cancelButtonLabel,
  });

  final List<T> options;
  final String Function(T) displayStringFunction;

  final Widget? title;
  final Widget? content;

  final String Function(T currentSelection) confirmButtonLabelFunction;
  final String cancelButtonLabel;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<SelectionCubit<T>>();
    return BlocBuilder<SelectionCubit<T>, T>(
      builder: (context, selection) {
        return AlertDialog(
          title: title,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (content != null) ...[
                content!,
                const SizedBox(height: 10),
              ],
              ClearableDropdownButton<T>(
                value: selection,
                onChanged: (value) => cubit.selectionChanged(value as T),
                items: options
                    .map(
                      (option) => DropdownMenuItem<T>(
                        value: option,
                        child: Text(displayStringFunction(option)),
                      ),
                    )
                    .toList(),
                label: Text(l10n.selection),
                showClearButton: false,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, selection),
              child: Text(confirmButtonLabelFunction(selection)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(cancelButtonLabel),
            ),
          ],
        );
      },
    );
  }
}
