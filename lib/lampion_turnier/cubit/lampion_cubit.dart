import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';

class LampionCubit extends Cubit<FormzSubmissionStatus> {
  LampionCubit({
    required this.importEndpoint,
    required this.pbProvider,
  }) : super(FormzSubmissionStatus.initial);

  final LampionImportEndpoint importEndpoint;
  final PocketBaseProvider pbProvider;

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

    Future.delayed(
      const Duration(seconds: 1),
      () => pbProvider.reconnect(),
    );

    if (!isClosed) {
      emit(FormzSubmissionStatus.success);
    }
  }
}
