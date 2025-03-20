import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/expansion_radio_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/toggleable_tween_animation/toggleable_tween_animation_builder.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/player_management/cubit/player_list_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/comparators/team_comparator.dart';
import 'package:ez_badminton_admin_app/player_management/player_sorter/cubit/unique_competition_filter_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/widgets/player_expansion_panel_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class PlayerExpansionPanel extends StatefulWidget {
  const PlayerExpansionPanel(
    this.player,
    this.listState,
    this.index, {
    super.key,
  });

  final int index;
  final Player player;
  final PlayerListState listState;

  @override
  State<PlayerExpansionPanel> createState() => _PlayerExpansionPanelState();
}

class _PlayerExpansionPanelState extends State<PlayerExpansionPanel> {
  late final ExpansionTileController _controller;
  late ExpansionRadioCubit radioCubit;

  @override
  void initState() {
    super.initState();
    _controller = ExpansionTileController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    radioCubit = context.read<ExpansionRadioCubit>();
    var state = radioCubit.state;
    if (state.selected == widget.player) {
      radioCubit.expand(_controller, widget.player);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    radioCubit.dispose(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpansionRadioCubit, ExpansionRadioState>(
      buildWhen: (previous, current) =>
          (previous.selected == widget.player) !=
          (current.selected == widget.player),
      builder: (context, state) {
        return ExpansionTile(
          title: _PlayerExpansionPanelTitle(player: widget.player),
          trailing: const SizedBox.shrink(),
          initiallyExpanded: radioCubit.state.selected == widget.player,
          showTrailingIcon: false,
          tilePadding: EdgeInsets.zero,
          expansionAnimationStyle: AnimationStyle(
            duration: const Duration(milliseconds: 120),
          ),
          textColor: Colors.black,
          controller: _controller,
          onExpansionChanged: (value) {
            if (value) {
              radioCubit.expand(_controller, widget.player);
            } else {
              radioCubit.collapse();
            }
          },
          children: [
            PlayerExpansionPanelBody(
              player: widget.player,
              registrations:
                  widget.listState.competitionRegistrations[widget.player] ??
                      [],
            ),
          ],
        );
      },
    );
  }
}

class _PlayerExpansionPanelTitle extends StatelessWidget {
  const _PlayerExpansionPanelTitle({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    var listCubit = context.read<PlayerListCubit>();
    var listState = listCubit.state;

    var radioCubit = context.read<ExpansionRadioCubit>();
    bool isExpanded = radioCubit.state.selected == player;

    var l10n = AppLocalizations.of(context)!;
    bool needsPartner = _playerNeedsPartner(
      listState.competitionRegistrations[player] ?? [],
    );
    return ToggleableTweenAnimationBuilder(
      animationRunning: isExpanded,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.linear,
      duration: Duration(milliseconds: 120),
      builder: (context, value, child) {
        var textStyle = DefaultTextStyle.of(context);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10 * value + 9),
          child: DefaultTextStyle(
            style: textStyle.style.copyWith(
              fontWeight: FontWeight.lerp(
                FontWeight.normal,
                FontWeight.w600,
                value,
              ),
            ),
            child: child!,
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Row(
            children: [
              const SizedBox(width: 20),
              SizedBox(
                width: 190,
                child: Text(
                  display_strings.playerName(player),
                  overflow: TextOverflow.fade,
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              SizedBox(
                width: 190,
                child: Text(
                  player.club?.name ?? '-',
                  overflow: TextOverflow.fade,
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              SizedBox(
                width: 100,
                child: _RegistrationList(
                  registrations:
                      listState.competitionRegistrations[player] ?? [],
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
              SizedBox(
                child: SizedBox(
                  width: 45,
                  child: Tooltip(
                    message: _statusTooltip(l10n, player, needsPartner),
                    child: Row(
                      children: [
                        Icon(
                          playerStatusIcons[player.status],
                          size: 21,
                          color: Colors.grey[600],
                        ),
                        if (needsPartner)
                          const Icon(
                            partnerMissingIcon,
                            size: 21,
                          )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          _TeamDivider(player: player),
        ],
      ),
    );
  }

  static String _statusTooltip(
    AppLocalizations l10n,
    Player player,
    bool needsPartner,
  ) {
    String statusTooltip = l10n.playerStatus(player.status.name);
    if (needsPartner) {
      statusTooltip += '\n${l10n.partnerNeeded}';
    }
    return statusTooltip;
  }

  static bool _playerNeedsPartner(
    Iterable<Registration> registrations,
  ) {
    for (Registration registration in registrations) {
      if (registration.team.players.length <
          registration.competition.teamSize) {
        return true;
      }
    }
    return false;
  }
}

class _RegistrationList extends StatelessWidget {
  const _RegistrationList({
    required this.registrations,
  });

  final List<Registration> registrations;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<UniqueCompetitionFilterCubit>();
    String separator = ', ';

    return BlocBuilder<PlayerListCubit, PlayerListState>(
      builder: (context, listState) {
        UniqueCompetitionFilterState? state =
            listState.sortingComparator is TeamComparator ? cubit.state : null;
        Competition? uniqueFiltered = state?.competition.value;
        Registration? uniqueFilteredRegistration = registrations
            .firstWhereOrNull((r) => r.competition == uniqueFiltered);

        List<Registration> sortedRegistrations = List.of(registrations);

        // Styles for the competitions that are uniquely filtered or not
        TextStyle uniqueStyle = Theme.of(context).textTheme.bodyMedium!;
        TextStyle nonUniqueStyle = uniqueStyle;

        TextSpan? seedText;

        if (uniqueFilteredRegistration != null) {
          sortedRegistrations
            ..remove(uniqueFilteredRegistration)
            ..insert(0, uniqueFilteredRegistration);

          nonUniqueStyle = uniqueStyle.copyWith(
            color: Theme.of(context).disabledColor,
          );

          if (uniqueFilteredRegistration.seed != null) {
            SeedingMode seedingMode = uniqueFilteredRegistration
                    .competition.tournamentModeSettings?.seedingMode ??
                SeedingMode.tiered;
            String seedLabel = display_strings.seedLabel(
              uniqueFilteredRegistration.seed!,
              seedingMode,
            );

            seedText = TextSpan(
              text: ':$seedLabel',
              style: uniqueStyle,
            );
          }
        }

        List<TextSpan> abbreviationTexts = [
          for (Registration r in sortedRegistrations) ...[
            TextSpan(
              text: _competitionAbbreviation(r.competition, l10n),
              style:
                  sortedRegistrations.first == r ? uniqueStyle : nonUniqueStyle,
            ),
            if (sortedRegistrations.first == r && seedText != null) seedText,
            if (sortedRegistrations.last != r)
              TextSpan(
                text: separator,
                style: uniqueStyle,
              ),
          ]
        ];

        return RichText(text: TextSpan(children: abbreviationTexts));
      },
    );
  }

  static String _competitionAbbreviation(
    Competition competition,
    AppLocalizations l10n,
  ) {
    String competitionAbbreviation =
        l10n.competitionTypeAbbreviated(competition.type.name);
    if (competition.genderCategory == GenderCategory.male ||
        competition.genderCategory == GenderCategory.female) {
      String genderPrefix = competition.genderCategory == GenderCategory.female
          ? l10n.womenAbbreviated
          : l10n.menAbbreviated;
      competitionAbbreviation = '$genderPrefix$competitionAbbreviation';
    }
    return competitionAbbreviation;
  }
}

class _TeamDivider extends StatelessWidget {
  const _TeamDivider({
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerListCubit, PlayerListState>(
      builder: (context, state) {
        if (state.sortingComparator is! TeamComparator) {
          return const SizedBox();
        }
        var cubit = context.read<UniqueCompetitionFilterCubit>();
        Competition uniqueFiltered = cubit.state.competition.value!;
        List<Team> teams = uniqueFiltered.registrations;

        Team team = teams.firstWhere((t) => t.players.contains(player));

        bool isLastTeamMember = state.filteredPlayers.reversed
                .firstWhere((p) => team.players.contains(p)) ==
            player;

        if (isLastTeamMember &&
            state.filteredPlayers.last != player &&
            uniqueFiltered.teamSize > 1) {
          return Divider(
            height: 0,
            thickness: 1.5,
            color: Theme.of(context).disabledColor,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
