import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';

class PartnerRegistrationState extends CollectionFetcherState
    with CollectionGetter {
  PartnerRegistrationState({
    this.loadingStatus = LoadingStatus.loading,
    this.showPartnerInput = false,
    this.partner = const SelectionInput.pure(),
    this.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final bool showPartnerInput;
  final SelectionInput<Player> partner;
  @override
  final Map<Type, List<Model>> collections;

  PartnerRegistrationState copyWith({
    LoadingStatus? loadingStatus,
    bool? showPartnerInput,
    SelectionInput<Player>? partner,
    Map<Type, List<Model>>? collections,
  }) =>
      PartnerRegistrationState(
        loadingStatus: loadingStatus ?? this.loadingStatus,
        showPartnerInput: showPartnerInput ?? this.showPartnerInput,
        partner: partner ?? this.partner,
        collections: collections ?? this.collections,
      );

  @override
  PartnerRegistrationState copyWithCollection({
    required Type modelType,
    required List<Model> collection,
  }) {
    var newCollections = Map.of(collections);
    newCollections.remove(modelType);
    newCollections.putIfAbsent(modelType, () => collection);
    return copyWith(collections: Map.unmodifiable(newCollections));
  }
}
