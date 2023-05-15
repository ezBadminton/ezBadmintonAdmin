import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/player_management/player_editing/cubit/player_editing_cubit.dart';
import 'package:ez_badminton_admin_app/widgets/constrained_autocomplete/constrained_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayerEditingForm extends StatelessWidget {
  const PlayerEditingForm({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PlayerEditingForm());
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addPlayer)),
      body: BlocProvider(
        create: (context) => PlayerEditingCubit(
          context: context,
          playerRepository: context.read<CollectionRepository<Player>>(),
          playingLevelRepository:
              context.read<CollectionRepository<PlayingLevel>>(),
          clubRepository: context.read<CollectionRepository<Club>>(),
          competitionRepository:
              context.read<CollectionRepository<Competition>>(),
          teamRepository: context.read<CollectionRepository<Team>>(),
        ),
        child: Align(
          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.personalData,
                  style: const TextStyle(fontSize: 22),
                ),
                const Divider(height: 25, indent: 20, endIndent: 20),
                Row(
                  children: [
                    _NameInput(
                        maxWidth: 220.0, labelText: '${l10n.firstName}*'),
                    const SizedBox(width: 25),
                    _NameInput(maxWidth: 220.0, labelText: '${l10n.lastName}*'),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: const [
                    _DateOfBirthInput(),
                    SizedBox(width: 25),
                    _EMailInput(),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: const [
                    _ClubInput(),
                    SizedBox(width: 25),
                    _PlayingLevelInput(),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  l10n.registeredCompetitions,
                  style: const TextStyle(fontSize: 22),
                ),
                const Divider(height: 25, indent: 20, endIndent: 20),
                const _CompetitionInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EMailInput extends StatelessWidget {
  const _EMailInput();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: TextField(
        decoration: InputDecoration(label: Text(l10n.eMail)),
      ),
    );
  }
}

class _DateOfBirthInput extends StatelessWidget {
  const _DateOfBirthInput();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: TextField(
        decoration: InputDecoration(
          label: Text(l10n.birthday),
          hintText: MaterialLocalizations.of(context)
              .dateHelpText, // DateFormat.yMd()
          suffixIcon: IconButton(
            onPressed: () => showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ),
      ),
    );
  }
}

class _PlayingLevelInput extends StatelessWidget {
  const _PlayingLevelInput();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: DropdownButtonFormField(
        value: null,
        onChanged: (value) {},
        items: const [DropdownMenuItem(child: Text('- Keine -'))],
        decoration: InputDecoration(label: Text(l10n.playingLevel)),
      ),
    );
  }
}

class _CompetitionInput extends StatelessWidget {
  const _CompetitionInput();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            hint: const Text('Disziplin wählen'),
            value: null,
            onChanged: (value) {},
            items: const [
              DropdownMenuItem(
                value: 'null',
                child: Text('Disziplin 1'),
              )
            ],
            decoration: InputDecoration(label: Text(l10n.competition)),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}

class _ClubInput extends StatelessWidget {
  const _ClubInput();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) =>
            BlocBuilder<PlayerEditingCubit, PlayerEditingState>(
          buildWhen: (previous, current) =>
              previous.clubSuggestionCompleter !=
              current.clubSuggestionCompleter,
          builder: (context, state) {
            return ConstrainedAutocomplete<String>(
              optionsBuilder: (_) {
                if (state.clubSuggestionCompleter.isCompleted) {
                  context.read<PlayerEditingCubit>().clubSuggestionBootstrap();
                }
                return state.clubSuggestionCompleter.future;
              },
              constraints: constraints,
              fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) =>
                  TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(label: Text(l10n.club)),
                onChanged: context.read<PlayerEditingCubit>().clubNameChanged,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({
    required this.maxWidth,
    required this.labelText,
  });

  final double maxWidth;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextField(
        decoration: InputDecoration(labelText: labelText),
      ),
    );
  }
}
