import 'package:authentication_repository/authentication_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:model_repository/model_repository.dart';

part 'infoscreen_control_qr_state.dart';

class InfoscreenControlQrCubit
    extends CollectionQuerierCubit<InfoscreenControlQrState> {
  InfoscreenControlQrCubit({
    required ModelStore<InfoscreenUser> infoscreenUserStore,
    required this.authRepository,
  })  : hostAddress = Uri.parse(authRepository.pocketBase.baseURL),
        super(
          modelStores: [infoscreenUserStore],
          InfoscreenControlQrState(),
        );
  final AuthenticationRepository<InfoscreenAuthCollectionName> authRepository;
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
        controllerURL: "http://${hostAddress.host}?token=${user.initToken}",
      );
    }

    emit(updatedState);
  }
}
