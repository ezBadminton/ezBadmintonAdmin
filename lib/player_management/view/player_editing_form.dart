import 'package:ez_badminton_admin_app/widgets/constrained_autocomplete/constrained_autocomplete.dart';
import 'package:flutter/material.dart';
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
      body: Align(
        child: SizedBox(
          width: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.personalData,
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  _NameInput(maxWidth: 220.0, labelText: '${l10n.firstName}*'),
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
                style: TextStyle(fontSize: 22),
              ),
            ],
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

class _ClubInput extends StatelessWidget {
  const _ClubInput();

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedAutocomplete<String>(
          optionsBuilder: (_) =>
              List<String>.generate(50, (index) => 'Example club $index'),
          constraints: constraints,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) =>
                  TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(label: Text(l10n.club)),
          ),
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
