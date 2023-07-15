import 'package:ez_badminton_admin_app/widgets/confirm_dialog/confirm_dialog.dart';
import 'package:ez_badminton_admin_app/widgets/confirm_dialog/cubit_mixin/dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A widget listening to state emissions from the [C] cubit and opening a
/// dialog when the `dialog` member of the state [S] changes.
///
/// See also:
///  * [DialogCubit]. The cubit that the dialog listener can listen to.
///  * [ConfirmDialog]. A simple widget fit for use in the [builder].
class DialogListener<C extends DialogCubit<S>, S extends DialogState>
    extends StatelessWidget {
  const DialogListener({
    super.key,
    required this.builder,
    this.child,
  });

  /// The dialog builder. It is used via [showDialog] when the listener
  /// is triggered to show the dialog.
  ///
  /// Receives the current state [S] and an [Object] potentially holding info
  /// about why the dialog was opened.
  ///
  /// After the dialog widget received a user input it has to
  /// pop off the navigator with a bool representing the input decision
  /// (e.g. `Navigator.pop(context, true);`).
  /// The bool is automatically passed to the cubit that requested the dialog.
  final Widget Function(BuildContext context, S state, Object reason) builder;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<C, S>(
      listenWhen: (previous, current) =>
          previous.dialog != current.dialog &&
          current.dialog.decisionCompleter != null,
      listener: (context, state) async {
        bool? decision = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          useRootNavigator: false,
          builder: (context) => builder(
            context,
            state,
            state.dialog.reason,
          ),
        );
        state.dialog.decisionCompleter!.complete(
          decision,
        );
      },
      child: child,
    );
  }
}
