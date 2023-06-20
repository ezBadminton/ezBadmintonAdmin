import 'package:collection/collection.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/widgets/constrained_autocomplete/constrained_autocomplete.dart';
import 'package:ez_badminton_admin_app/widgets/custom_input_fields/player_search_input/cubit/partner_name_search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerNameInput extends StatelessWidget {
  const PartnerNameInput({
    super.key,
    required this.player,
    required this.competition,
    required this.playerCollection,
    required this.partnerGetter,
    required this.onPartnerChanged,
    required this.label,
    this.initialValue,
    this.disabled = false,
    this.counterText = ' ',
  });

  final Player player;
  final Competition competition;
  final List<Player> playerCollection;
  final Player? Function() partnerGetter;
  final void Function(Player?) onPartnerChanged;
  final String? initialValue;
  final bool disabled;
  final String label;
  final String? counterText;

  final String Function(Player) _displayStringFunction =
      display_strings.playerWithClub;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BlocProvider(
          create: (context) => PartnerNameSearchCubit(
            partnerGetter: partnerGetter,
            displayStringFunction: _displayStringFunction,
          ),
          child: Builder(builder: (context) {
            var cubit = context.read<PartnerNameSearchCubit>();
            if (initialValue != null && !cubit.state.focus.hasFocus) {
              cubit.partnerNameChanged(initialValue!);
            }
            return BlocBuilder<PartnerNameSearchCubit, PartnerNameSearchState>(
              buildWhen: (previous, current) =>
                  previous.textController.text != current.textController.text,
              builder: (context, state) {
                return ConstrainedAutocomplete<Player>(
                  optionsBuilder: _partnerOptionsBuilder,
                  onSelected: onPartnerChanged,
                  constraints: constraints,
                  displayStringForOption: _displayStringFunction,
                  fieldViewBuilder: (context, textEditingController, focusNode,
                          onFieldSubmitted) =>
                      TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      label: Text(label),
                      counterText: counterText,
                    ),
                    readOnly: disabled,
                  ),
                  optionsMaxHeight: 100,
                  focusNode: state.focus,
                  textEditingController: state.textController,
                );
              },
            );
          }),
        );
      },
    );
  }

  Iterable<Player> _partnerOptionsBuilder(TextEditingValue playerSearchTerm) {
    var alreadyPartnered = competition.registrations.expand(
      (team) => team.players.length == 2 ? team.players : [],
    );

    var playerOptions = playerCollection
        .whereNot((p) => alreadyPartnered.contains(p) || p == player);

    if (playerSearchTerm.text.isNotEmpty) {
      playerOptions =
          playerOptions.where((p) => _partnerSearch(p, playerSearchTerm.text));
    }

    if (playerOptions.length == 1 && playerSearchTerm.text.isNotEmpty) {
      onPartnerChanged(playerOptions.first);
    } else if (partnerGetter() != null) {
      onPartnerChanged(null);
    }

    return playerOptions;
  }

  bool _partnerSearch(Player potentialPartner, String searchTerm) {
    var cleanSearchTerm = searchTerm.toLowerCase().trim();
    return _displayStringFunction(potentialPartner)
        .toLowerCase()
        .contains(cleanSearchTerm);
  }
}
