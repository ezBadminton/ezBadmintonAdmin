part of 'age_group_editing_cubit.dart';

class AgeGroupEditingState extends CollectionQuerierState
    implements DialogState {
  AgeGroupEditingState({
    this.ageGroupType = const SelectionInput.pure(emptyAllowed: true),
    this.age = const NoValidationInput.pure(),
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.dialog = const CubitDialog(),
    this.collections = const [],
    this.formSubmittable = false,
    this.isDeletable = false,
  });

  final SelectionInput<AgeGroupType> ageGroupType;
  final NoValidationInput age;

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  final bool formSubmittable;
  final bool isDeletable;

  @override
  final CubitDialog dialog;

  @override
  final List<List<Model>> collections;

  AgeGroupEditingState copyWith({
    SelectionInput<AgeGroupType>? ageGroupType,
    NoValidationInput? age,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    CubitDialog? dialog,
    List<List<Model>>? collections,
    bool? formSubmittable,
    bool? isDeletable,
  }) {
    return AgeGroupEditingState(
      ageGroupType: ageGroupType ?? this.ageGroupType,
      age: age ?? this.age,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      dialog: dialog ?? this.dialog,
      collections: collections ?? this.collections,
      formSubmittable: formSubmittable ?? this.formSubmittable,
      isDeletable: isDeletable ?? this.isDeletable,
    );
  }
}
