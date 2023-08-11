part of 'player_editing_cubit.dart';

@immutable
class PlayerEditingState extends CollectionFetcherState<PlayerEditingState>
    with FormzMixin {
  PlayerEditingState({
    super.collections = const {},
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    Player? player,
    this.registrations = const ListInput.pure(),
    this.firstName = const NonEmptyInput.pure(),
    this.lastName = const NonEmptyInput.pure(),
    this.clubName = const NoValidationInput.pure(),
    this.notes = const NoValidationInput.pure(),
    this.registrationFormShown = false,
  }) : player = player ?? Player.newPlayer();

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;
  final Player player;
  final ListInput<CompetitionRegistration> registrations;
  final NonEmptyInput firstName;
  final NonEmptyInput lastName;
  final NoValidationInput clubName;
  final NoValidationInput notes;

  final bool registrationFormShown;

  @override
  List<FormzInput> get inputs => [
        firstName,
        lastName,
        clubName,
        notes,
        registrations,
      ];

  PlayerEditingState copyWithPlayer({
    required Player player,
    required DateTime? Function(String) dateParser,
  }) =>
      copyWith(
        player: player,
        firstName: NonEmptyInput.pure(player.firstName),
        lastName: NonEmptyInput.pure(player.lastName),
        clubName: NoValidationInput.pure(player.club?.name ?? ''),
        notes: NoValidationInput.pure(player.notes ?? ''),
      );

  PlayerEditingState copyWith({
    Map<Type, List<Model>>? collections,
    LoadingStatus? loadingStatus,
    Player? player,
    ListInput<CompetitionRegistration>? registrations,
    FormzSubmissionStatus? formStatus,
    NonEmptyInput? firstName,
    NonEmptyInput? lastName,
    NoValidationInput? clubName,
    NoValidationInput? notes,
    bool? registrationFormShown,
  }) =>
      PlayerEditingState(
        collections: collections ?? this.collections,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        player: player ?? this.player,
        registrations: registrations ?? this.registrations,
        formStatus: formStatus ?? this.formStatus,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        clubName: clubName ?? this.clubName,
        notes: notes ?? this.notes,
        registrationFormShown:
            registrationFormShown ?? this.registrationFormShown,
      );
}
