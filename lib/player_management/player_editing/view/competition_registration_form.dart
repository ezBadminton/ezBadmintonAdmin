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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetitionRegistrationForm extends StatelessWidget {
  const CompetitionRegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
      buildWhen: (previous, current) =>
          previous.registrations != current.registrations,
      builder: (context, state) {
        var scrollController = context.read<ScrollController>();
        _scrollAfterBuild(scrollController);
        return Column(
          children: <Widget>[
            for (int i = 0; i < state.registrations.length; i++)
              _CompetitionForm(registrationIndex: i),
            if (state.registrations.isEmpty ||
                state.registrations.last.competition.value != null)
              const _RegistrationSubmitButton()
            else
              const _RegistrationCancelButton(),
          ],
        );
      },
    );
  }

  Future<void> _scrollAfterBuild(ScrollController controller) async {
    await Future.delayed(Duration.zero);
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
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

class _RegistrationSubmitButton extends StatelessWidget {
  const _RegistrationSubmitButton();

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

class _CompetitionForm extends StatelessWidget {
  const _CompetitionForm({required this.registrationIndex});

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    var editingCubit = context.read<PlayerEditingCubit>();
    return BlocProvider(
      create: (context) => CompetitionRegistrationCubit(
        editingCubit.state.registrations[registrationIndex],
        registrationIndex: registrationIndex,
        playerListCollections: editingCubit.collections,
      ),
      child: _CompetitionFormFields(
        registrationIndex: registrationIndex,
      ),
    );
  }
}

class _CompetitionFormFields extends StatelessWidget {
  const _CompetitionFormFields({
    required this.registrationIndex,
  });

  final int registrationIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompetitionRegistrationCubit,
        CompetitionRegistrationState>(
      buildWhen: (previous, current) => previous.formStep != current.formStep,
      builder: (context, state) {
        var registrationCubit = context.read<CompetitionRegistrationCubit>();
        var l10n = AppLocalizations.of(context)!;
        return Stepper(
          currentStep: state.formStep,
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
            if (registrationCubit.getParameterOptions<AgeGroup>().isNotEmpty)
              _AgeGroupStep(context, state),
            _CompetitionStep(context, state),
            Step(
              title: Text(l10n.partner),
              subtitle: Text(l10n.optional),
              content: _PartnerNameInput(),
            ),
          ],
        );
      },
    );
  }

  Widget _formControlsBuilder(BuildContext context, ControlsDetails details) {
    Widget cancelButton;

    if (details.stepIndex == 0) {
      cancelButton = const SizedBox();
    } else {
      cancelButton = Padding(
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
    return Align(
      alignment: Alignment.centerLeft,
      child: cancelButton,
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
      var genderPrefix = l10n.genderCategory(genderCategory.name);
      var competitionSuffix = l10n.competitionSuffix(competitionType.name);
      return Text(genderPrefix + competitionSuffix);
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
      return Text(
        '${l10n.ageGroupAbbreviated(ageGroup.type.name)}${ageGroup.age}',
      );
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
        _controller.text = _playerDisplayString(cubit.state.partner.value!);
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
            displayStringForOption: _playerDisplayString,
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) =>
                    TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                label: Text(l10n.partner),
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

  String _playerDisplayString(Player player) {
    var name = '${player.firstName} ${player.lastName}';
    var club = player.club == null ? '' : ' (${player.club!.name})';
    return name + club;
  }

  Iterable<Player> _partnerOptionsBuilder(
    BuildContext context,
    TextEditingValue playerSearchTerm,
  ) {
    var cubit = context.read<CompetitionRegistrationCubit>();
    var selected = cubit.getSelectedCompetitions().first;
    var players = cubit.getCollection<Player>();
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
