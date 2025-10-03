// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'starting_fee_currency_cubit.dart';

class StartingFeeCurrencyState extends CollectionQuerierState {
  const StartingFeeCurrencyState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.currency = const FiatEur(),
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;

  final FormzSubmissionStatus formStatus;

  @override
  final List<List<Model>> collections;

  final FiatCurrency currency;

  TournamentEvent get tournamentEvent => getCollection<TournamentEvent>().first;

  StartingFeeCurrencyState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    List<List<Model>>? collections,
    FiatCurrency? currency,
  }) {
    return StartingFeeCurrencyState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      collections: collections ?? this.collections,
      currency: currency ?? this.currency,
    );
  }
}
