// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'infoscreen_control_qr_cubit.dart';

class InfoscreenControlQrState extends CollectionQuerierState {
  InfoscreenControlQrState({
    this.collections = const [],
    this.loadingStatus = LoadingStatus.loading,
    this.controllerURL = 'loading',
  });

  @override
  final List<List<Model>> collections;

  @override
  final LoadingStatus loadingStatus;

  final String controllerURL;

  InfoscreenControlQrState copyWith({
    List<List<Model>>? collections,
    LoadingStatus? loadingStatus,
    String? controllerURL,
  }) {
    return InfoscreenControlQrState(
      collections: collections ?? this.collections,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      controllerURL: controllerURL ?? this.controllerURL,
    );
  }
}
