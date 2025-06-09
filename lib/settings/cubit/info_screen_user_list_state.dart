// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'info_screen_user_list_cubit.dart';

class InfoScreenUserListState extends CollectionQuerierState {
  InfoScreenUserListState({
    this.collections = const [],
    this.loadingStatus = LoadingStatus.loading,
    this.submissionStatus = FormzSubmissionStatus.initial,
  });

  @override
  final List<List<Model>> collections;

  @override
  final LoadingStatus loadingStatus;

  final FormzSubmissionStatus submissionStatus;

  InfoScreenUserListState copyWith({
    List<List<Model>>? collections,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? submissionStatus,
  }) {
    return InfoScreenUserListState(
      collections: collections ?? this.collections,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}
