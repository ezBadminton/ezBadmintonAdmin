// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'lampion_plan_upload_cubit.dart';

class LampionPlanUploadState extends CollectionQuerierState {
  LampionPlanUploadState({
    this.loadingStatus = LoadingStatus.loading,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  @override
  final List<List<models.Model>> collections;

  LampionPlanUploadState copyWith({
    LoadingStatus? loadingStatus,
    List<List<models.Model>>? collections,
  }) {
    return LampionPlanUploadState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      collections: collections ?? this.collections,
    );
  }
}
