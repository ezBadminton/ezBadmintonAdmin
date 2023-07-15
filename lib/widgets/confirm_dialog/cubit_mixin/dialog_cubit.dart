import 'dart:async';

import 'package:ez_badminton_admin_app/widgets/confirm_dialog/dialog_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CubitDialog {
  const CubitDialog({
    this.decisionCompleter,
    Object? reason,
  }) : reason = reason ?? const Object();

  final Completer<bool?>? decisionCompleter;
  final Object reason;
}

abstract class DialogState {
  CubitDialog get dialog;
}

mixin DialogCubit<S extends DialogState> on Cubit<S> {
  /// Wait for a boolean dialog decision.
  ///
  /// This requires there to be a [DialogListener] that opens a dialog
  /// for resolving the `Future<bool?>`.
  ///
  /// Example:
  ///
  /// ```dart
  /// BlocProvider<ExampleDialogCubit, ExampleDialogState> {
  ///   create: (_) => ExampleDialogCubit(),
  ///   child: Builder(
  ///     builder: (context) => DialogListener<ExampleDialogCubit, ExampleDialogState, ExampleDialogReason>(
  ///       builder: (
  ///         BuildContext context,
  ///         ExampleDialogState state,
  ///         ExampleDialogReason? reason,
  ///       ) => AlertDialog(/*build dialog with decision buttons*/),
  ///     ),
  ///   ),
  /// }
  /// ```
  ///
  /// With this widget tree you could have a method in the `ExampleDialogCubit`
  /// that can await user input by calling [requestDialogConfirmation].
  ///
  /// The [reason] parameter can be used to pass an object holding information
  /// about why the dialog popped up to the dialog builder. When omitted a
  /// plain [Object] is passed.
  Future<bool?> requestDialogConfirmation({
    Object reason = const Object(),
  }) async {
    CubitDialog dialog = CubitDialog(
      decisionCompleter: Completer<bool>(),
      reason: reason,
    );
    // Have to assume copyWith exists and has dialog parameter
    S newState = (state as dynamic).copyWith(dialog: dialog);
    emit(newState);
    return await dialog.decisionCompleter!.future;
  }
}
