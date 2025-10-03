import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:model_repository/model_repository.dart';

part 'starting_fee_state.dart';

/// This cubit emits states containing the amounts of unpaid starting fees
/// per player and per club
class StartingFeeCubit extends CollectionQuerierCubit<StartingFeeState> {
  StartingFeeCubit({
    required ModelStore<Registration> registrationStore,
    required ModelStore<StartingFeePayment> paymentStore,
    required ModelStore<StartingFeeMassDiscount> discountStore,
    required ModelStore<Competition> competitionStore,
  }) : super(
          modelStores: [
            registrationStore,
            paymentStore,
            discountStore,
            competitionStore,
          ],
          StartingFeeState(),
        );

  factory StartingFeeCubit.fromContext(BuildContext context) {
    return StartingFeeCubit(
      registrationStore: RepositoryProvider.of(context),
      paymentStore: RepositoryProvider.of(context),
      discountStore: RepositoryProvider.of(context),
      competitionStore: RepositoryProvider.of(context),
    );
  }

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    List<CollectionUpdateEvent<Model>>? updateEvents,
  ) {
    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );

    final List<Registration> registrations = updatedState.getCollection();
    final Map<Player, List<Registration>> playerRegistrations =
        _mapPlayerRegistrations(registrations);

    final List<StartingFeePayment> payments = updatedState.getCollection();
    final Map<Player, List<StartingFeePayment>> playerPayments =
        _mapPlayerPayments(payments);

    final List<StartingFeeMassDiscount> massDiscounts =
        updatedState.getCollection();

    final Map<Player, int> playerFees = {};
    for (final player in playerRegistrations.keys) {
      final registrations = playerRegistrations[player]!;
      final payments = playerPayments[player] ?? [];
      playerFees[player] = _calculatePlayerFee(
        registrations,
        payments,
        massDiscounts,
      );
    }
    final Map<Club, int> clubFees = _mapClubFees(playerFees);

    updatedState = updatedState.copyWith(
      playerFees: playerFees,
      clubFees: clubFees,
    );

    emit(updatedState);
  }

  int _calculatePlayerFee(
    List<Registration> registrations,
    List<StartingFeePayment> payments,
    List<StartingFeeMassDiscount> massDiscounts,
  ) {
    int amountPaid = 0;
    int massDiscountUsed = 0;
    for (final payment in payments) {
      amountPaid += payment.amount;
      massDiscountUsed += payment.massDiscount;
    }

    final int numRegistrations = registrations.length;
    int applicableMassDiscount = 0;
    for (final massDiscount in massDiscounts) {
      final bool eligible = numRegistrations >= massDiscount.minRegistrations;
      final bool isMax = applicableMassDiscount < massDiscount.discountAmount;
      if (eligible && isMax) {
        applicableMassDiscount = massDiscount.discountAmount;
      }
    }
    final int netMassDiscount = applicableMassDiscount - massDiscountUsed;

    final int grossFees = registrations.fold(
      0,
      (fees, registration) => fees + registration.competition.startingFee,
    );
    final int netFees = grossFees - netMassDiscount - amountPaid;
    return netFees;
  }

  Map<Club, int> _mapClubFees(Map<Player, int> playerFees) {
    final Map<Club, int> clubFees = {};
    for (final player in playerFees.keys) {
      if (player.club == null) {
        continue;
      }
      final Club club = player.club!;
      final int playerFee = playerFees[player]!;
      int clubFee = clubFees.putIfAbsent(club, () => 0);
      clubFee += playerFee;
      clubFees[club] = clubFee;
    }
    return clubFees;
  }

  Map<Player, List<StartingFeePayment>> _mapPlayerPayments(
    List<StartingFeePayment> payments,
  ) {
    Map<Player, List<StartingFeePayment>> playerPayments = {};
    for (final payment in payments) {
      final pays = playerPayments.putIfAbsent(payment.player, () => []);
      pays.add(payment);
      playerPayments[payment.player] = pays;
    }
    return playerPayments;
  }

  Map<Player, List<Registration>> _mapPlayerRegistrations(
    List<Registration> registrations,
  ) {
    Map<Player, List<Registration>> playerRegistrations = {};
    for (final registration in registrations) {
      for (final player in registration.team.players) {
        final regs = playerRegistrations.putIfAbsent(player, () => []);
        regs.add(registration);
        playerRegistrations[player] = regs;
      }
    }
    return playerRegistrations;
  }
}
