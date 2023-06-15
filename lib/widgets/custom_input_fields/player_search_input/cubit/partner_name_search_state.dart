part of 'partner_name_search_cubit.dart';

class PartnerNameSearchState extends Equatable {
  PartnerNameSearchState()
      : textController = TextEditingController(),
        focus = FocusNode();

  final TextEditingController textController;
  final FocusNode focus;

  @override
  List<Object?> get props => [textController.text, focus.hasFocus];
}
