import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/constrained_autocomplete/constrained_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PartnerNameInput extends StatelessWidget {
  PartnerNameInput({
    super.key,
    required this.player,
    required this.competition,
    required this.playerCollection,
    required this.partner,
    required this.onPartnerChanged,
    required this.onPartnerNameChanged,
  }) {
    if (partner != null) {
      _controller.text = _displayStringFunction(partner!);
    }

    _focus.addListener(_completePartnerName);
  }

  final Player player;
  final Competition competition;
  final List<Player> playerCollection;
  final Player? partner;
  final void Function(Player?) onPartnerChanged;
  final void Function(String) onPartnerNameChanged;

  final _controller = TextEditingController();
  final _focus = FocusNode();

  final String Function(Player) _displayStringFunction =
      display_strings.playerWithClub;

  @override
  Widget build(BuildContext context) {
    AppLocalizations l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedAutocomplete<Player>(
          optionsBuilder: (playerSearchTerm) =>
              _partnerOptionsBuilder(context, playerSearchTerm),
          onSelected: onPartnerChanged,
          constraints: constraints,
          displayStringForOption: _displayStringFunction,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) =>
                  TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              label: Text('${l10n.partner} (${l10n.optional.toLowerCase()})'),
              counterText: ' ',
            ),
            onChanged: onPartnerNameChanged,
          ),
          optionsMaxHeight: 100,
          focusNode: _focus,
          textEditingController: _controller,
        );
      },
    );
  }

  Iterable<Player> _partnerOptionsBuilder(
    BuildContext context,
    TextEditingValue playerSearchTerm,
  ) {
    var alreadyPartnered = competition.registrations.expand(
      (team) => team.players.length == 2 ? team.players : [],
    );

    var playerOptions = playerCollection
        .whereNot((p) => alreadyPartnered.contains(p) || p == player);

    if (playerSearchTerm.text.isNotEmpty) {
      playerOptions =
          playerOptions.where((p) => _partnerSearch(p, playerSearchTerm.text));
    }

    if (playerOptions.length == 1) {
      onPartnerChanged(playerOptions.first);
    } else if (partner != null) {
      onPartnerChanged(null);
    }

    return playerOptions;
  }

  void _completePartnerName() {
    if (!_focus.hasFocus && partner != null) {
      _controller.text = _displayStringFunction(partner!);
    }
  }

  bool _partnerSearch(Player potentialPartner, String searchTerm) {
    var cleanSearchTerm = searchTerm.toLowerCase().trim();
    return _displayStringFunction(potentialPartner)
        .toLowerCase()
        .contains(cleanSearchTerm);
  }
}
