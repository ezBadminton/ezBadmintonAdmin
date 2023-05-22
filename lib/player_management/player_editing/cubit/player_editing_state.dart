part of 'player_editing_cubit.dart';

@immutable
class PlayerEditingState with FormzMixin {
  const PlayerEditingState({
    required this.loadingStatus,
    required this.formStatus,
    required this.player,
    required this.firstName,
    required this.lastName,
    required this.clubName,
    required this.eMail,
    required this.dateOfBirth,
    required this.playingLevel,
    required this.playingLevels,
    required this.clubs,
  });

  PlayerEditingState.fromPlayer({
    required context,
    required this.player,
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.playingLevels = const [],
    this.clubs = const [],
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
        );

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;
  final Player player;
  final NonEmptyInput firstName;
  final NonEmptyInput lastName;
  final NoValidationInput clubName;
  final EMailInput eMail;
  final DateInput dateOfBirth;
  final SelectionInput<PlayingLevel> playingLevel;

  final List<PlayingLevel> playingLevels;
  final List<Club> clubs;

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
    Player? player,
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    NonEmptyInput? firstName,
    NonEmptyInput? lastName,
    NoValidationInput? clubName,
    EMailInput? eMail,
    DateInput? dateOfBirth,
    SelectionInput<PlayingLevel>? playingLevel,
    List<PlayingLevel>? playingLevels,
    List<Club>? clubs,
  }) =>
      PlayerEditingState(
        player: player ?? this.player,
        loadingStatus: loadingStatus ?? this.loadingStatus,
        formStatus: formStatus ?? this.formStatus,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        clubName: clubName ?? this.clubName,
        eMail: eMail ?? this.eMail,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        playingLevel: playingLevel ?? this.playingLevel,
        playingLevels: playingLevels ?? this.playingLevels,
        clubs: clubs ?? this.clubs,
      );
}
