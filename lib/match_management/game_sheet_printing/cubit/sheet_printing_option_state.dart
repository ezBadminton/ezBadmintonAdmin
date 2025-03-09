part of 'sheet_printing_option_cubit.dart';

class SheetPrintingOptionState extends CollectionQuerierState {
  SheetPrintingOptionState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.collections = const [],
  });

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  @override
  final List<List<Model>> collections;

  TournamentEvent get _tournament => getCollection<TournamentEvent>().first;

  bool get dontReprintGameSheets => _tournament.dontReprintGameSheets;
  bool get printQrCodes => _tournament.printQrCodes;

  SheetPrintingOptionState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    List<List<Model>>? collections,
  }) {
    return SheetPrintingOptionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      collections: collections ?? this.collections,
    );
  }
}
