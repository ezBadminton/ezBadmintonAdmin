import 'dart:io';

import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:pdf/widgets.dart' as pw;

mixin PdfPrintingCubit<S extends PdfPrintingState> on Cubit<S> {
  void pdfOpened();
}

abstract class PdfPrintingState {
  FormzSubmissionStatus get formStatus;

  SelectionInput<pw.Document> get pdfDocument;
  SelectionInput<File> get openedFile;
}
