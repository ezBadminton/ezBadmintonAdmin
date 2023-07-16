import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class CubitDialog<T> {
  const CubitDialog({
    this.decisionCompleter,
    Object? reason,
  }) : reason = reason ?? const Object();

  final Completer<T?>? decisionCompleter;
  final Object reason;
}

abstract class DialogState {
  CubitDialog get dialog;
}

mixin DialogCubit<S extends DialogState> on Cubit<S> {
  /// Wait for a dialog decision yielding a [T] object or null.
  ///
  /// This requires there to be a `DialogListener<DialogCubit, DialogState, T>`
  /// that opens a dialog for resolving the `Future<T?>`.
  ///
  /// Example:
  ///
  /// ```dart
  /// BlocProvider<ExampleDialogCubit, ExampleDialogState> {
  ///   create: (_) => ExampleDialogCubit(),
  ///   child: Builder(
  ///     builder: (context) => DialogListener<ExampleDialogCubit, ExampleDialogState, bool>(
  ///       builder: (
  ///         BuildContext context,
  ///         ExampleDialogState state,
  ///         ExampleDialogReason? reason,
  ///       ) => AlertDialog(/*build dialog with decision buttons that return bool*/),
  ///     ),
  ///   ),
  /// }
  /// ```
  ///
  /// With this widget tree you could have a method in the `ExampleDialogCubit`
  /// that can await user input by calling [requestDialogChoice].
  ///
  /// The [reason] parameter can be used to pass an object holding information
  /// about why the dialog popped up to the dialog builder. When omitted a
  /// plain [Object] is passed.
  Future<T?> requestDialogChoice<T>({
    Object reason = const Object(),
  }) async {
    CubitDialog dialog = CubitDialog<T>(
      decisionCompleter: Completer<T?>(),
      reason: reason,
    );
    // Have to assume copyWith exists and has dialog parameter
    S newState = (state as dynamic).copyWith(dialog: dialog);
    emit(newState);
    return await dialog.decisionCompleter!.future;
  }
}
