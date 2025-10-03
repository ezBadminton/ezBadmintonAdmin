// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'mass_discount_editing_cubit.dart';

class MassDiscountEditingState extends CollectionQuerierState {
  MassDiscountEditingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.minRegistrations = 2,
    this.discountAmount = 0,
    this.discountLevels = const [],
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final FormzSubmissionStatus formStatus;
  final int minRegistrations;
  final int discountAmount;

  final List<StartingFeeMassDiscount> discountLevels;

  @override
  List<List<Model>> collections;

  TournamentEvent get tournament => getCollection<TournamentEvent>().first;

  MassDiscountEditingState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    int? minRegistrations,
    int? discountAmount,
    List<StartingFeeMassDiscount>? discountLevels,
    List<List<Model>>? collections,
  }) {
    return MassDiscountEditingState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      minRegistrations: minRegistrations ?? this.minRegistrations,
      discountAmount: discountAmount ?? this.discountAmount,
      discountLevels: discountLevels ?? this.discountLevels,
      collections: collections ?? this.collections,
    );
  }
}
