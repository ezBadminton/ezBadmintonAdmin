import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:pdf/widgets.dart' as pw;

mixin PdfPrintingCubit<S extends PdfPrintingState> on Cubit<S> {
  void pdfOpened();

  void saveLocationOpened();

  Future<Directory> getSaveLocationDir();

  /// Returns a file name that does not exist in the [saveDir] yet.
  ///
  /// The [indexedNameGetter] has to return the file name containing an index
  /// number. For example `file001.pdf`.
  String getPdfFileName(
    String Function(int fileIndex) indexedNameGetter,
    Directory saveDir,
  ) {
    List<String> existingSheetFileNames =
        saveDir.listSync().map((e) => p.basename(e.path)).toList();

    int index = existingSheetFileNames.length;
    String fileName = indexedNameGetter(index);

    while (existingSheetFileNames.contains(fileName)) {
      index += 1;
      fileName = indexedNameGetter(index);
    }

    return fileName;
  }
}

abstract class PdfPrintingState {
  FormzSubmissionStatus get formStatus;

  SelectionInput<pw.Document> get pdfDocument;
  SelectionInput<File> get openedFile;

  SelectionInput<Directory> get openedDirectory;
}
