import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';
import 'package:model_repository/model_repository.dart';

part 'mass_discount_editing_state.dart';

class MassDiscountEditingCubit
    extends CollectionQuerierCubit<MassDiscountEditingState> {
  MassDiscountEditingCubit({
    required ModelStore<TournamentEvent> tournamentStore,
    required ModelStore<StartingFeeMassDiscount> discountStore,
    required this.massDiscountEndpoint,
  }) : super(
          modelStores: [
            tournamentStore,
            discountStore,
          ],
          MassDiscountEditingState(),
        );

  final StartingFeeMassDiscountEndpoint massDiscountEndpoint;

  void minRegistrationsChanged(int minRegistrations) {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(minRegistrations: minRegistrations));
  }

  void discountAmountChanged(int amount) {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(discountAmount: amount));
  }

  void discountSubmitted() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    if (state.minRegistrations < 2 || state.discountAmount < 1) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await massDiscountEndpoint.post(body: {
        "minRegistrations": state.minRegistrations,
        "amount": state.discountAmount,
      });
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }
    emit(state.copyWith(
      formStatus: FormzSubmissionStatus.success,
      discountAmount: 0,
    ));
  }

  void discountRemoved(StartingFeeMassDiscount discount) async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }
    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    try {
      await querier.deleteModel(discount);
    } catch (_) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
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

    List<StartingFeeMassDiscount> discountLevels = updatedState
        .tournament.startingFeeMassDiscounts
        .sortedBy<num>((discount) => discount.minRegistrations)
        .toList();

    updatedState = updatedState.copyWith(discountLevels: discountLevels);

    emit(updatedState);
  }
}
