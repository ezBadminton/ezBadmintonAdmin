// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'starting_fee_editing_cubit.dart';

class StartingFeeEditingState {
  const StartingFeeEditingState({
    this.amount = 0,
    this.formStatus = FormzSubmissionStatus.initial,
    required this.competitions,
  });

  final int amount;

  final FormzSubmissionStatus formStatus;

  // The competitions to edit the starting fee for
  final List<Competition> competitions;

  StartingFeeEditingState copyWith({
    int? amount,
    FormzSubmissionStatus? formStatus,
    List<Competition>? competitions,
  }) {
    return StartingFeeEditingState(
      amount: amount ?? this.amount,
      formStatus: formStatus ?? this.formStatus,
      competitions: competitions ?? this.competitions,
    );
  }
}
