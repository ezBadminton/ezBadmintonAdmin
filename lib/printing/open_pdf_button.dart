import 'dart:io';

import 'package:ez_badminton_admin_app/printing/pdf_printing_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:formz/formz.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenPdfButton<C extends PdfPrintingCubit<S>, S extends PdfPrintingState>
    extends StatelessWidget {
  const OpenPdfButton({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<C>();

    return BlocConsumer<C, S>(
      listenWhen: (previous, current) =>
          previous.openedFile.value != current.openedFile.value &&
          current.openedFile.value != null,
      listener: (context, state) {
        launchUrl(Uri.file(
          state.openedFile.value!.path,
          windows: Platform.isWindows,
        ));
      },
      builder: (context, state) {
        bool enabled = state.pdfDocument.value != null &&
            state.formStatus != FormzSubmissionStatus.inProgress;

        return ElevatedButton(
          onPressed: enabled ? cubit.pdfOpened : null,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.formStatus == FormzSubmissionStatus.inProgress)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(),
                  )
                else
                  const Icon(Icons.open_in_new, size: 20),
                const SizedBox(width: 8),
                Text(l10n.saveAndOpenPdf),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OpenPdfSaveLocationButton<C extends PdfPrintingCubit<S>,
    S extends PdfPrintingState> extends StatelessWidget {
  const OpenPdfSaveLocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    var cubit = context.read<C>();

    return BlocListener<C, S>(
      listenWhen: (previous, current) =>
          previous.openedDirectory.value != current.openedDirectory.value &&
          current.openedDirectory.value != null,
      listener: (context, state) {
        OpenFile.open(state.openedDirectory.value!.path);
      },
      child: TextButton(
        onPressed: cubit.saveLocationOpened,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder, size: 16),
            const SizedBox(width: 8),
            Text(l10n.openSaveLocation, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
