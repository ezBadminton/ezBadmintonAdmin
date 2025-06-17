import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';

class LampionCubit extends Cubit<FormzSubmissionStatus> {
  LampionCubit({
    required this.importEndpoint,
  }) : super(FormzSubmissionStatus.initial);

  final LampionImportEndpoint importEndpoint;

  void importLampionTournament() async {
    if (state == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(FormzSubmissionStatus.inProgress);

    try {
      await importEndpoint.post();
    } catch (_) {
      emit(FormzSubmissionStatus.failure);
    }

    importEndpoint.modelRepository!.reloadModels();

    if (!isClosed) {
      emit(FormzSubmissionStatus.success);
    }
  }
}
