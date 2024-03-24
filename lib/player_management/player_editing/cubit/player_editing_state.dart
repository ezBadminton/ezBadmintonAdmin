part of 'player_editing_cubit.dart';

@immutable
class PlayerEditingState extends CollectionQuerierState with FormzMixin {
  PlayerEditingState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    Player? player,
    this.registrations = const ListInput.pure(),
    this.firstName = const NonEmptyInput.pure(),
    this.lastName = const NonEmptyInput.pure(),
    this.clubName = const NoValidationInput.pure(),
    this.notes = const NoValidationInput.pure(),
    this.registrationFormShown = false,
    this.collections = const [],
  }) : player = player ?? Player.newPlayer();

  @override
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
  final List<List<Model>> collections;

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
  }) =>
      copyWith(
        player: player,
        firstName: NonEmptyInput.pure(player.firstName),
        lastName: NonEmptyInput.pure(player.lastName),
        clubName: NoValidationInput.pure(player.club?.name ?? ''),
        notes: NoValidationInput.pure(player.notes ?? ''),
      );

  PlayerEditingState copyWith({
    LoadingStatus? loadingStatus,
    Player? player,
    ListInput<CompetitionRegistration>? registrations,
    FormzSubmissionStatus? formStatus,
    NonEmptyInput? firstName,
    NonEmptyInput? lastName,
    NoValidationInput? clubName,
    NoValidationInput? notes,
    bool? registrationFormShown,
    List<List<Model>>? collections,
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
