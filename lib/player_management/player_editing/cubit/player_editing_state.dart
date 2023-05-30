part of 'player_editing_cubit.dart';

@immutable
class PlayerEditingState extends CollectionFetcherState
    with FormzMixin, CollectionGetter {
  const PlayerEditingState({
    required this.collections,
    required this.loadingStatus,
    required this.formStatus,
    required this.player,
    required this.registrations,
    required this.firstName,
    required this.lastName,
    required this.clubName,
    required this.eMail,
    required this.dateOfBirth,
    required this.playingLevel,
    required this.registrationFormShown,
  });

  PlayerEditingState.fromPlayer({
    this.collections = const {},
    this.loadingStatus = LoadingStatus.loading,
    this.registrations = const [],
    required context,
    required this.player,
    this.formStatus = FormzSubmissionStatus.initial,
  })  : firstName = NonEmptyInput.pure(player.firstName),
        lastName = NonEmptyInput.pure(player.lastName),
        clubName = NoValidationInput.pure(player.club?.name ?? ''),
        eMail = EMailInput.pure(emptyAllowed: true, value: player.eMail ?? ''),
        dateOfBirth = player.dateOfBirth != null
            ? DateInput.pure(
                context: context,
                emptyAllowed: true,
                value: MaterialLocalizations.of(context)
                    .formatCompactDate(player.dateOfBirth!),
              )
            : DateInput.pure(context: context, emptyAllowed: true),
        playingLevel = SelectionInput.pure(
          emptyAllowed: true,
          value: player.playingLevel,
        ),
        registrationFormShown = false;

  @override
  final Map<Type, List<Model>> collections;

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;
  final Player player;
  final List<Competition> registrations;
  final NonEmptyInput firstName;
  final NonEmptyInput lastName;
  final NoValidationInput clubName;
  final EMailInput eMail;
  final DateInput dateOfBirth;
  final SelectionInput<PlayingLevel> playingLevel;

  final bool registrationFormShown;

  @override
  List<FormzInput> get inputs => [
        firstName,
        lastName,
        clubName,
        eMail,
        dateOfBirth,
        playingLevel,
      ];

  PlayerEditingState copyWith({
    Map<Type, List<Model>>? collections,
    LoadingStatus? loadingStatus,
    Player? player,
    List<Competition>? registrations,
    FormzSubmissionStatus? formStatus,
    NonEmptyInput? firstName,
    NonEmptyInput? lastName,
    NoValidationInput? clubName,
    EMailInput? eMail,
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
        eMail: eMail ?? this.eMail,
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
