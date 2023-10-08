import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/player_management/models/competition_registration.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

class PartnerRegistrationState
    extends CollectionFetcherState<PartnerRegistrationState> {
  PartnerRegistrationState({
    required this.registration,
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.showPartnerInput = false,
    this.partner = const SelectionInput.pure(),
    super.collections = const {},
  });

  final CompetitionRegistration registration;

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;
  final bool showPartnerInput;
  final SelectionInput<Player> partner;

  PartnerRegistrationState copyWith({
    CompetitionRegistration? registration,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    bool? showPartnerInput,
    SelectionInput<Player>? partner,
    Map<Type, List<Model>>? collections,
  }) =>
      PartnerRegistrationState(
        registration: registration ?? this.registration,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        formStatus: formStatus ?? this.formStatus,
        showPartnerInput: showPartnerInput ?? this.showPartnerInput,
        partner: partner ?? this.partner,
        collections: collections ?? this.collections,
      );
}
