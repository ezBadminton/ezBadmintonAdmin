import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/l10n/l10n.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';
import 'package:sealed_currencies/sealed_currencies.dart';

part 'starting_fee_currency_state.dart';

class StartingFeeCurrencyCubit
    extends CollectionQuerierCubit<StartingFeeCurrencyState> {
  StartingFeeCurrencyCubit({
    required ModelStore<TournamentEvent> tournamentStore,
    required this.l10n,
  }) : super(
          modelStores: [tournamentStore],
          StartingFeeCurrencyState(),
        );

  final AppLocalizations l10n;

  void feeCurrencyChanged(FiatCurrency currency) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));
    final updatedTournamentEvent = state.tournamentEvent.copyWith(
      feeCurrency: currency.code,
    );
    try {
      await querier.updateModel(updatedTournamentEvent);
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  FiatCurrency _getInitialCurrency() {
    final FiatCurrency initialCurrency;
    switch (l10n.localeName) {
      case 'en':
        initialCurrency = FiatGbp();
      default:
        initialCurrency = FiatEur();
    }
    return initialCurrency;
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    var updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );
    final currencyCode = updatedState.tournamentEvent.feeCurrency;
    final currency = FiatCurrency.maybeFromCode(currencyCode);
    if (currency != null) {
      updatedState = updatedState.copyWith(currency: currency);
    }
    emit(updatedState);

    if (currency == null) {
      feeCurrencyChanged(_getInitialCurrency());
    }
  }
}
