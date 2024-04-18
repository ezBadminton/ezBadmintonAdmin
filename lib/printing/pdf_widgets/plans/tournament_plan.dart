import 'dart:ui';
import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';

import 'package:ez_badminton_admin_app/badminton_tournament_ops/badminton_tournament_modes.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/competition_label.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class TournamentPlan<T extends BadmintonTournamentMode>
    extends pw.StatelessWidget {
  TournamentPlan({
    required this.tournament,
    required this.l10n,
  }) {
    _widgets = layoutPlan(tournament);
  }

  final T tournament;

  final AppLocalizations l10n;

  late final List<TournamentPlanWidget> _widgets;

  List<TournamentPlanWidget> layoutPlan(T tournament);

  /// Returns the boundary size of the plan widget.
  PdfPoint layoutSize() {
    if (_widgets.isEmpty) {
      return PdfPoint.zero;
    }

    Rect boundingBox = _widgets.map((w) => w.boundingBox).reduce(
          (value, element) => value.expandToInclude(element),
        );
    Size size = boundingBox.size;

    return PdfPoint(size.width, size.height);
  }

  List<pw.Page> generatePdfPages() {
    double pageMargin = 0.65;
    pw.EdgeInsets planPadding = const pw.EdgeInsets.all(1);
    pw.EdgeInsets pagePadding = const pw.EdgeInsets.all(0.7 * PdfPageFormat.cm);

    PdfPoint planSize = layoutSize().translate(
      planPadding.horizontal,
      planPadding.vertical,
    );

    PdfPageFormat format = PdfPageFormat.a4.landscape.copyWith(
      marginTop: pageMargin * PdfPageFormat.cm,
      marginBottom: pageMargin * PdfPageFormat.cm,
      marginLeft: pageMargin * PdfPageFormat.cm,
      marginRight: pageMargin * PdfPageFormat.cm,
    );

    PdfPoint planPageSize = format.availableDimension.translate(
      -pagePadding.horizontal,
      -pagePadding.vertical,
    );

    int numColumns = (planSize.x / planPageSize.x).ceil();
    int numRows = (planSize.y / planPageSize.y).ceil();

    PdfPoint relativeOffset = PdfPoint(
      planPageSize.x / (planSize.x - planPageSize.x),
      planPageSize.y / (planSize.y - planPageSize.y),
    );

    List<pw.Page> pages = [];

    for (int row = 0; row < numRows; row += 1) {
      for (int column = 0; column < numColumns; column += 1) {
        pw.FractionalOffset offset = pw.FractionalOffset(
          column * relativeOffset.x,
          row * relativeOffset.y,
        );

        pw.Widget planPart = pw.Padding(
          padding: pagePadding,
          child: pw.ConstrainedBox(
            constraints: pw.BoxConstraints.tight(planPageSize),
            child: pw.FittedBox(
              fit: pw.BoxFit.none,
              alignment: offset,
              child: pw.SizedBox.fromSize(
                size: planSize,
                child: pw.Padding(
                  padding: planPadding,
                  child: this,
                ),
              ),
            ),
          ),
        );

        pw.Widget pageLabel = pw.Positioned(
          right: 0,
          bottom: 0,
          child: _buildPageLabel(numRows, numColumns, row, column),
        );

        pw.Page page = pw.Page(
          pageFormat: format,
          build: (pw.Context context) => pw.DefaultTextStyle(
            style: pw.TextStyle(
              fontNormal: PdfFonts().interNormal,
              fontBold: PdfFonts().interBold,
            ),
            child: pw.Stack(
              overflow: pw.Overflow.visible,
              children: [
                planPart,
                pageLabel,
              ],
            ),
          ),
        );

        pages.add(page);
      }
    }

    return pages;
  }

  pw.Widget _buildPageLabel(
    int numRows,
    int numColumns,
    int row,
    int column,
  ) {
    pw.TextStyle textStyle = const pw.TextStyle(fontSize: 10);

    int pageNumber = numColumns * row + column;

    return pw.Row(children: [
      CompetitionLabel(
        competition: tournament.competition,
        l10n: l10n,
        textStyle: textStyle,
      ),
      pw.SizedBox(width: 1.2 * PdfPageFormat.cm),
      pw.Text(
        l10n.pageNofM('${numColumns}x$numRows', pageNumber + 1),
        style: textStyle,
      ),
      pw.SizedBox(width: 0.85 * PdfPageFormat.cm),
    ]);
  }

  @override
  pw.Widget build(pw.Context context) {
    return pw.Stack(
      overflow: pw.Overflow.visible,
      children: _widgets.reversed.toList(),
    );
  }
}

class TournamentPlanWidget extends pw.Positioned {
  TournamentPlanWidget({
    required this.boundingBox,
    required super.child,
  }) : super(left: boundingBox.left, top: boundingBox.top);

  final Rect boundingBox;
}
