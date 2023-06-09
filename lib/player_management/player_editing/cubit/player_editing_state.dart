part of 'player_editing_cubit.dart';

@immutable
class PlayerEditingState extends CollectionFetcherState
    with FormzMixin, CollectionGetter {
  PlayerEditingState({
    this.collections = const {},
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    Player? player,
    this.registrations = const ListInput.pure(),
    this.firstName = const NonEmptyInput.pure(),
    this.lastName = const NonEmptyInput.pure(),
    this.clubName = const NoValidationInput.pure(),
    this.notes = const NoValidationInput.pure(),
    this.dateOfBirth = const DateInput.pure(emptyAllowed: true),
    this.playingLevel = const SelectionInput.pure(emptyAllowed: true),
    this.registrationFormShown = false,
  }) : player = player ?? Player.newPlayer();

  @override
  final Map<Type, List<Model>> collections;

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;
  final Player player;
  final ListInput<CompetitionRegistration> registrations;
  final NonEmptyInput firstName;
  final NonEmptyInput lastName;
  final NoValidationInput clubName;
  final NoValidationInput notes;
  final DateInput dateOfBirth;
  final SelectionInput<PlayingLevel> playingLevel;

  final bool registrationFormShown;

  @override
  List<FormzInput> get inputs => [
        firstName,
        lastName,
        clubName,
        notes,
        dateOfBirth,
        playingLevel,
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
        dateOfBirth: DateInput.pure(
          dateParser: dateParser,
          emptyAllowed: true,
        ),
        playingLevel: SelectionInput.pure(
          emptyAllowed: true,
          value: player.playingLevel,
        ),
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
    DateInput? dateOfBirth,
    SelectionInput<PlayingLevel>? playingLevel,
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
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        playingLevel: playingLevel ?? this.playingLevel,
        registrationFormShown:
            registrationFormShown ?? this.registrationFormShown,
      );

  @override
  PlayerEditingState copyWithCollection({
    required Type modelType,
    required List<Model> collection,
  }) {
    var newCollections = Map.of(collections);
    newCollections.remove(modelType);
    newCollections.putIfAbsent(modelType, () => collection);
    return copyWith(collections: Map.unmodifiable(newCollections));
  }
}
