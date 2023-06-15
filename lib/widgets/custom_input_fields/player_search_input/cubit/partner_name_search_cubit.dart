import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'partner_name_search_state.dart';

class PartnerNameSearchCubit extends Cubit<PartnerNameSearchState> {
  PartnerNameSearchCubit({
    required Player? Function() partnerGetter,
    required String Function(Player) displayStringFunction,
  })  : _partnerGetter = partnerGetter,
        _displayStringFunction = displayStringFunction,
        super(
          PartnerNameSearchState(),
        ) {
    state.focus.addListener(_completePartnerName);
    if (_partnerGetter() != null) {
      partnerNameChanged(_displayStringFunction(_partnerGetter()!));
    }
  }

  final Player? Function() _partnerGetter;
  final String Function(Player) _displayStringFunction;

  void partnerNameChanged(String partnerName) {
    state.textController.text = partnerName;
  }

  // If the partner name has only partially been entered but still uniquely
  // identifies a player then the textfield autofills the rest of the name upon
  // losing focus.
  void _completePartnerName() {
    if (!state.focus.hasFocus && _partnerGetter() != null) {
      partnerNameChanged(_displayStringFunction(_partnerGetter()!));
    }
  }

  @override
  Future<void> close() async {
    state.focus.removeListener(_completePartnerName);
    return super.close();
  }
}
