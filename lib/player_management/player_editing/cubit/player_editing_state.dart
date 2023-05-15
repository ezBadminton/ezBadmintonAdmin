part of 'player_editing_cubit.dart';

@immutable
class PlayerEditingState {
  const PlayerEditingState({
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
    this.player = Player.newPlayer,
    this.playingLevels = const [],
    this.clubs = const [],
  })  : firstName = NonEmptyInput.pure(player.firstName),
        lastName = NonEmptyInput.pure(player.lastName),
        clubName = NonEmptyInput.pure(player.club.name),
        eMail = EMailInput.pure(player.eMail),
        dateOfBirth = player.dateOfBirth.year > 1900
            ? DateInput.pure(
                context: context,
                value: MaterialLocalizations.of(context)
                    .formatCompactDate(player.dateOfBirth),
              )
            : DateInput.pure(context: context),
        playingLevel = SelectionInput.pure(
            player.playingLevel == PlayingLevel.unrated
                ? null
                : player.playingLevel);

  final Player player;
  final NonEmptyInput firstName;
  final NonEmptyInput lastName;
  final NonEmptyInput clubName;
  final EMailInput eMail;
  final DateInput dateOfBirth;
  final SelectionInput<PlayingLevel> playingLevel;

  final List<PlayingLevel> playingLevels;
  final List<Club> clubs;

  PlayerEditingState copyWith({
    NonEmptyInput? firstName,
    NonEmptyInput? lastName,
    NonEmptyInput? clubName,
    EMailInput? eMail,
    DateInput? dateOfBirth,
    SelectionInput<PlayingLevel>? playingLevel,
    List<PlayingLevel>? playingLevels,
    List<Club>? clubs,
  }) =>
      PlayerEditingState(
        player: player,
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
