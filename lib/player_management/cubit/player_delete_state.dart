// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection_repository/collection_repository.dart';
import 'package:formz/formz.dart';

import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class PlayerDeleteState extends CollectionFetcherState<PlayerDeleteState> {
  PlayerDeleteState({
    required this.player,
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.showConfirmDialog = false,
    super.collections = const {},
  });

  final Player player;
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;
  final bool showConfirmDialog;

  PlayerDeleteState copyWith({
    Player? player,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    bool? showConfirmDialog,
    Map<Type, List<Model>>? collections,
  }) {
    return PlayerDeleteState(
      player: player ?? this.player,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      showConfirmDialog: showConfirmDialog ?? this.showConfirmDialog,
      collections: collections ?? this.collections,
    );
  }
}
