import 'package:ez_badminton_admin_app/widgets/dialog_listener/cubit_mixin/dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'confirmation_state.dart';

class ConfirmationCubit extends Cubit<ConfirmationState>
    with DialogCubit<ConfirmationState> {
  ConfirmationCubit() : super(ConfirmationState());

  void executeWithConfirmation(
    VoidCallback callback, {
    Object reason = const Object(),
  }) async {
    bool confirmation = (await requestDialogChoice<bool>(reason: reason))!;

    if (confirmation) {
      callback.call();
    }
  }
}
