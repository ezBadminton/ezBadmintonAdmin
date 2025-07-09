import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:model_repository/model_repository.dart';

part 'infoscreen_control_qr_state.dart';

class InfoscreenControlQrCubit
    extends CollectionQuerierCubit<InfoscreenControlQrState> {
  InfoscreenControlQrCubit({
    required ModelStore<InfoscreenUser> infoscreenUserStore,
  })  : hostAddress = Uri.parse("https://ezbadresults.tgcamberg1848.de"),
        super(
          modelStores: [infoscreenUserStore],
          InfoscreenControlQrState(),
        );
  final Uri hostAddress;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    var updatedState = state.copyWith(
      loadingStatus: LoadingStatus.done,
      collections: collections,
    );

    InfoscreenUser? user =
        updatedState.getCollection<InfoscreenUser>().firstOrNull;

    if (user != null) {
      updatedState = updatedState.copyWith(
        controllerURL: "https://${hostAddress.host}?token=${user.initToken}",
      );
    }

    emit(updatedState);
  }
}
