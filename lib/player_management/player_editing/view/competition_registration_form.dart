import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/competition_registration_state.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/player_filter/player_filter.dart';
import 'package:ez_badminton_admin_app/widgets/constrained_autocomplete/constrained_autocomplete.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/age_group_input.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/competition_type_input.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/gender_category_input.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/playing_level_input.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

class CompetitionRegistrationForm extends StatelessWidget {
  const CompetitionRegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      buildWhen: (previous, current) =>
          previous.registrationFormShown != current.registrationFormShown,
      builder: (context, state) {
        return Column(
          children: <Widget>[
            if (!state.registrationFormShown) ...[
              for (var registration in state.registrations)
                _CompetitionDisplayCard(registration),
              if (state.registrations.isNotEmpty) const SizedBox(height: 25),
              const _RegistrationAddButton(),
            ] else ...const [
              _CompetitionForm(),
              _RegistrationCancelButton()
            ]
          ],
        );
      },
    );
  }
}

class _RegistrationCancelButton extends StatelessWidget {
  const _RegistrationCancelButton();

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<PlayerEditingCubit>();
    return OutlinedButton(
      onPressed: cubit.registrationCancelled,
      child: Builder(builder: (context) {
        return Text(
          l10n.cancel,
          style: DefaultTextStyle.of(context).style.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(.6)),
        );
      }),
    );
  }
}

class _RegistrationAddButton extends StatelessWidget {
  const _RegistrationAddButton();

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<PlayerEditingCubit>();
    var l10n = AppLocalizations.of(context)!;
    return ElevatedButton(
      onPressed: cubit.registrationAdded,
      child: Text(l10n.addRegistration),
    );
  }
}

class _CompetitionDisplayCard extends StatelessWidget {
  const _CompetitionDisplayCard(this.competition);

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var divider = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(
        Icons.circle,
        size: 7,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
      ),
    );
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
                tooltip: l10n.deleteRegistration,
                icon: const Icon(Icons.close, size: 22),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(
                    display_strings.playingLevelList(competition.playingLevels),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                divider,
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    display_strings.ageGroupList(l10n, competition.ageGroups),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                divider,
                Text(
                  display_strings.competitionCategory(
                    l10n,
                    competition.type,
                    competition.genderCategory,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionForm extends StatelessWidget {
  const _CompetitionForm();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompetitionRegistrationCubit(
        playerRepository: context.read<CollectionRepository<Player>>(),
        competitionRepository:
            context.read<CollectionRepository<Competition>>(),
        playingLevelRepository:
            context.read<CollectionRepository<PlayingLevel>>(),
        ageGroupRepository: context.read<CollectionRepository<AgeGroup>>(),
      ),
      child: const _CompetitionFormFields(),
    );
  }
}

class _CompetitionFormFields extends StatelessWidget {
  const _CompetitionFormFields();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompetitionRegistrationCubit,
        CompetitionRegistrationState>(
      listenWhen: (previous, current) => current.competition.value != null,
      listener: (context, state) {
        var editingCubit = context.read<PlayerEditingCubit>();
        editingCubit.registrationSubmitted(state.competition.value!);
      },
      buildWhen: (previous, current) =>
          previous.formStep != current.formStep ||
          previous.loadingStatus != current.loadingStatus,
      builder: (context, state) {
        var registrationCubit = context.read<CompetitionRegistrationCubit>();
        var scrollController = context.read<ScrollController>();
        return LoadingScreen(
          loadingStatusGetter: () => state.loadingStatus,
          onRetry: registrationCubit.loadPlayerData,
          builder: (_) {
            _scrollAfterBuild(scrollController);
            return Stepper(
              currentStep: state.formStep,
              onStepContinue: registrationCubit.formSubmitted,
              onStepCancel: registrationCubit.formStepBack,
              stepIconBuilder: (stepIndex, stepState) {
                if (stepIndex < state.formStep) {
                  return const Icon(size: 16, Icons.check);
                } else {
                  return const Icon(size: 16, Icons.more_horiz);
                }
              },
              margin: const EdgeInsets.fromLTRB(60.0, 0, 25.0, 0),
              controlsBuilder: _formControlsBuilder,
              steps: [
                if (registrationCubit
                    .getParameterOptions<PlayingLevel>()
                    .isNotEmpty)
                  _PlayingLevelStep(context, state),
                if (registrationCubit
                    .getParameterOptions<AgeGroup>()
                    .isNotEmpty)
                  _AgeGroupStep(context, state),
                _CompetitionStep(context, state),
                _FinalStep(context, state),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _scrollAfterBuild(ScrollController controller) async {
    await Future.delayed(Duration.zero);
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _formControlsBuilder(BuildContext context, ControlsDetails details) {
    var cubit = context.read<CompetitionRegistrationCubit>();
    var l10n = AppLocalizations.of(context)!;
    Widget backButton = const SizedBox();
    Widget submitButton = const SizedBox();

    if (details.stepIndex > 0) {
      backButton = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: OutlinedButton(
          onPressed: details.onStepCancel,
          child: Builder(builder: (context) {
            var buttonTextStyle = DefaultTextStyle.of(context).style;
            return Text(
              MaterialLocalizations.of(context).backButtonTooltip.toUpperCase(),
              style: buttonTextStyle.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(.6)),
            );
          }),
        ),
      );
    }

    if (details.stepIndex == cubit.lastFormStep) {
      submitButton = Padding(
        padding: const EdgeInsets.only(left: 15),
        child: ElevatedButton(
          onPressed: details.onStepContinue,
          child: Text(l10n.register.toUpperCase()),
        ),
      );
    }

    return Row(
      children: [backButton, submitButton],
    );
  }
}

class _CompetitionStep extends Step {
  const _CompetitionStep._({
    required super.title,
    super.subtitle,
    required super.content,
  });

  factory _CompetitionStep(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var l10n = AppLocalizations.of(context)!;
    return _CompetitionStep._(
      title: Text(l10n.competition),
      subtitle: createSubtitle(context, state),
      content: const Row(
        children: [
          _GenderCategoryInput(),
          SizedBox(width: 10),
          _CompetitionTypeInput(),
        ],
      ),
    );
  }

  static Widget? createSubtitle(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    var formStep =
        registrationCubit.getFormStepFromParameterType<CompetitionType>();
    var l10n = AppLocalizations.of(context)!;
    if (formStep > state.formStep) {
      return null;
    } else if (formStep == state.formStep) {
      return Text(l10n.pleaseFillIn);
    } else {
      var competitionType = state.getCompetitionParameter<CompetitionType>()!;
      var genderCategory = state.getCompetitionParameter<GenderCategory>()!;
      return Text(display_strings.competitionCategory(
        l10n,
        competitionType,
        genderCategory,
      ));
    }
  }
}

class _CompetitionTypeInput extends StatelessWidget {
  const _CompetitionTypeInput();

  @override
  Widget build(BuildContext context) {
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return Expanded(
      child: BlocBuilder<CompetitionRegistrationCubit,
          CompetitionRegistrationState>(
        buildWhen: (previous, current) =>
            previous.competitionType != current.competitionType ||
            previous.genderCategory != current.genderCategory ||
            previous.formStep != current.formStep,
        builder: (context, state) {
          return CompetitionTypeInput(
            onChanged: (competitionType) =>
                registrationCubit.competitionParameterChanged(competitionType),
            currentValue: state.getCompetitionParameter<CompetitionType>(),
            competitionTypeOptions: registrationCubit
                .getParameterOptions<CompetitionType>(inSelection: true),
            showClearButton: false,
          );
        },
      ),
    );
  }
}

class _GenderCategoryInput extends StatelessWidget {
  const _GenderCategoryInput();

  @override
  Widget build(BuildContext context) {
    var registrationCubit = context.read<CompetitionRegistrationCubit>();

    return Expanded(
      child: BlocBuilder<CompetitionRegistrationCubit,
          CompetitionRegistrationState>(
        buildWhen: (previous, current) =>
            previous.genderCategory != current.genderCategory ||
            previous.competitionType != current.competitionType ||
            previous.formStep != current.formStep,
        builder: (context, state) {
          var options = registrationCubit.getParameterOptions<GenderCategory>(
            inSelection: true,
          );
          return GenderCategoryInput(
            onChanged: (genderCategory) =>
                registrationCubit.competitionParameterChanged(genderCategory),
            currentValue: state.getCompetitionParameter<GenderCategory>(),
            genderCategoryOptions: options,
            showClearButton: false,
          );
        },
      ),
    );
  }
}

class _AgeGroupStep extends Step {
  const _AgeGroupStep._({
    required super.title,
    super.subtitle,
    required super.content,
  });

  factory _AgeGroupStep(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var l10n = AppLocalizations.of(context)!;
    return _AgeGroupStep._(
      title: Text(l10n.ageGroup),
      subtitle: createSubtitle(context, state),
      content: const _AgeGroupInput(),
    );
  }

  static Widget? createSubtitle(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    var formStep = registrationCubit.getFormStepFromParameterType<AgeGroup>();
    var l10n = AppLocalizations.of(context)!;
    if (formStep > state.formStep) {
      return null;
    } else if (formStep == state.formStep) {
      return Text(l10n.pleaseFillIn);
    } else {
      var ageGroup = state.getCompetitionParameter<AgeGroup>()!;
      return Text(display_strings.ageGroup(l10n, ageGroup));
    }
  }
}

class _AgeGroupInput extends StatelessWidget {
  const _AgeGroupInput();

  @override
  Widget build(BuildContext context) {
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return BlocBuilder<CompetitionRegistrationCubit,
        CompetitionRegistrationState>(
      buildWhen: (previous, current) =>
          previous.ageGroup != current.ageGroup ||
          previous.formStep != current.formStep,
      builder: (context, state) {
        return AgeGroupInput(
          onChanged: (ageGroup) =>
              registrationCubit.competitionParameterChanged(ageGroup),
          currentValue: state.getCompetitionParameter<AgeGroup>(),
          ageGroupOptions: registrationCubit.getParameterOptions<AgeGroup>(
            inSelection: true,
          ),
          showClearButton: false,
        );
      },
    );
  }
}

class _PlayingLevelStep extends Step {
  const _PlayingLevelStep._({
    required super.title,
    super.subtitle,
    required super.content,
  });

  factory _PlayingLevelStep(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var l10n = AppLocalizations.of(context)!;
    return _PlayingLevelStep._(
      title: Text(l10n.playingLevel),
      subtitle: createSubtitle(context, state),
      content: const _PlayingLevelInput(),
    );
  }

  static Widget? createSubtitle(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    var formStep =
        registrationCubit.getFormStepFromParameterType<PlayingLevel>();
    var l10n = AppLocalizations.of(context)!;
    if (formStep > state.formStep) {
      return null;
    } else if (formStep == state.formStep) {
      return Text(l10n.pleaseFillIn);
    } else {
      return Text(state.getCompetitionParameter<PlayingLevel>()!.name);
    }
  }
}

class _PlayingLevelInput extends StatelessWidget {
  const _PlayingLevelInput();

  @override
  Widget build(BuildContext context) {
    var registrationCubit = context.read<CompetitionRegistrationCubit>();
    return BlocBuilder<CompetitionRegistrationCubit,
        CompetitionRegistrationState>(
      buildWhen: (previous, current) =>
          previous.playingLevel != current.playingLevel ||
          previous.formStep != current.formStep,
      builder: (context, state) {
        return PlayingLevelInput(
          onChanged: (playingLevel) =>
              registrationCubit.competitionParameterChanged(playingLevel),
          currentValue: state.getCompetitionParameter<PlayingLevel>(),
          playingLevelOptions: registrationCubit
              .getParameterOptions<PlayingLevel>(inSelection: true),
          showClearButton: false,
        );
      },
    );
  }
}

class _FinalStep extends Step {
  const _FinalStep._({
    required super.title,
    super.subtitle,
    required super.content,
  });

  factory _FinalStep(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var l10n = AppLocalizations.of(context)!;
    return _FinalStep._(
      title: Text(l10n.registerPartner),
      subtitle: createSubtitle(context, state),
      content: createContent(state),
    );
  }

  static Widget createContent(CompetitionRegistrationState state) {
    if (state.competitionType.value == CompetitionType.singles) {
      return const SizedBox();
    } else {
      return _PartnerNameInput();
    }
  }

  static Widget? createSubtitle(
    BuildContext context,
    CompetitionRegistrationState state,
  ) {
    var l10n = AppLocalizations.of(context)!;
    if (state.competitionType.value == CompetitionType.singles) {
      return Text(l10n.competitionType('singles'));
    }
    return Text(l10n.optional);
  }
}

class _PartnerNameInput extends StatelessWidget {
  _PartnerNameInput({
    String initialValue = '',
  }) {
    _controller.text = initialValue;
  }

  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    var cubit = context.read<CompetitionRegistrationCubit>();

    _focus.addListener(() {
      if (!_focus.hasFocus && cubit.state.partner.value != null) {
        _controller.text =
            display_strings.playerWithClub(cubit.state.partner.value!);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) => BlocBuilder<
          CompetitionRegistrationCubit, CompetitionRegistrationState>(
        buildWhen: (previous, current) =>
            previous.partnerName != current.partnerName ||
            previous.formStep != current.formStep,
        builder: (context, state) {
          return ConstrainedAutocomplete<Player>(
            optionsBuilder: (playerSearchTerm) =>
                _partnerOptionsBuilder(context, playerSearchTerm),
            onSelected: cubit.partnerChanged,
            constraints: constraints,
            displayStringForOption: display_strings.playerWithClub,
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) =>
                    TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                label: Text('${l10n.partner} (${l10n.optional.toLowerCase()})'),
                counterText: ' ',
              ),
              onChanged: cubit.partnerNameChanged,
            ),
            optionsMaxHeight: 100,
            focusNode: _focus,
            textEditingController: _controller,
          );
        },
      ),
    );
  }

  Iterable<Player> _partnerOptionsBuilder(
    BuildContext context,
    TextEditingValue playerSearchTerm,
  ) {
    var cubit = context.read<CompetitionRegistrationCubit>();
    var selected = cubit.getSelectedCompetitions().first;
    var players = cubit.state.getCollection<Player>();
    var participants = selected.registrations.expand((team) => team.players);

    var playerOptions = players.where((p) => !participants.contains(p));

    if (playerSearchTerm.text.isNotEmpty) {
      playerOptions = playerOptions.where(
        (p) => SearchPredicateProducer.searchTermMatchesPlayer(
          playerSearchTerm.text,
          p,
        ),
      );
    }

    if (playerOptions.length == 1) {
      cubit.partnerChanged(playerOptions.first);
    } else {
      cubit.partnerChanged(null);
    }

    return playerOptions;
  }
}
