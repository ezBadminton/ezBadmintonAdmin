part of 'sheet_printing_option_cubit.dart';

class SheetPrintingOptionState
    extends CollectionFetcherState<SheetPrintingOptionState> {
  SheetPrintingOptionState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    super.collections = const {},
  });

  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  Tournament get _tournament => collections[Tournament]!.first as Tournament;

  bool get dontReprintGameSheets => _tournament.dontReprintGameSheets;
  bool get printQrCodes => _tournament.printQrCodes;

  SheetPrintingOptionState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    Map<Type, List<Model>>? collections,
  }) {
    return SheetPrintingOptionState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      collections: collections ?? this.collections,
    );
  }
}
