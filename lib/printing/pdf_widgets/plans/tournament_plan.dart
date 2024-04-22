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

  final double _pageMargin = 0.65;
  final pw.EdgeInsets _planPadding = const pw.EdgeInsets.all(1);
  final pw.EdgeInsets _pagePadding =
      const pw.EdgeInsets.all(0.7 * PdfPageFormat.cm);

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

  /// Lays out the plan onto DIN A4 PDF pages. If the plan is bigger than one
  /// page, the overflow is continued on the next page(s).
  ///
  /// When printed the pages can be glued at the edges to stitch the whole plan
  /// together.
  ///
  /// When [bigPage] is true, only one big page is returned that is formatted
  /// specifically to contain the plan thus uses no printer paper format.
  List<pw.Page> generatePdfPages({bool bigPage = false}) {
    if (bigPage) {
      return [_generateBigPage()];
    }

    PdfPoint planSize = layoutSize().translate(
      _planPadding.horizontal,
      _planPadding.vertical,
    );

    PdfPageFormat format = _getPageFormat(planSize);

    PdfPoint planPageSize = format.availableDimension.translate(
      -_pagePadding.horizontal,
      -_pagePadding.vertical,
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
          padding: _pagePadding,
          child: pw.ConstrainedBox(
            constraints: pw.BoxConstraints.tight(planPageSize),
            child: pw.FittedBox(
              fit: pw.BoxFit.none,
              alignment: offset,
              child: pw.SizedBox.fromSize(
                size: planSize,
                child: pw.Padding(
                  padding: _planPadding,
                  child: this,
                ),
              ),
            ),
          ),
        );

        pw.Widget pageLabel = pw.Positioned(
          right: 0,
          bottom: 0,
          child: TournamentPlanPageLabel(
            l10n: l10n,
            tournament: tournament,
            numRows: numRows,
            numColumns: numColumns,
            row: row,
            column: column,
          ),
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

  pw.Page _generateBigPage() {
    double pageMargin = 0.65;
    pw.EdgeInsets planPadding = const pw.EdgeInsets.only(
      left: 1,
      right: 1,
      top: 1,
      bottom: 24,
    );
    PdfPoint planSize = layoutSize().translate(
      planPadding.horizontal,
      planPadding.vertical,
    );

    PdfPageFormat format = PdfPageFormat(
      planSize.x + 2 * pageMargin * PdfPageFormat.cm,
      planSize.y + 2 * pageMargin * PdfPageFormat.cm,
      marginAll: pageMargin * PdfPageFormat.cm,
    );

    pw.Widget plan = pw.Padding(
      padding: planPadding,
      child: this,
    );

    pw.Widget pageLabel = pw.Positioned(
      right: 0,
      bottom: 0,
      child: TournamentPlanPageLabel.withoutPageNumber(
        l10n: l10n,
        tournament: tournament,
      ),
    );

    pw.Page page = pw.Page(
      pageFormat: format,
      build: (pw.Context context) => pw.DefaultTextStyle(
        style: pw.TextStyle(
          fontNormal: PdfFonts().interNormal,
          fontBold: PdfFonts().interBold,
        ),
        child: pw.Stack(
          children: [
            plan,
            pageLabel,
          ],
        ),
      ),
    );

    return page;
  }

  PdfPageFormat _getPageFormat(PdfPoint planSize) {
    PdfPageFormat landscape = PdfPageFormat.a4.landscape.copyWith(
      marginTop: _pageMargin * PdfPageFormat.cm,
      marginBottom: _pageMargin * PdfPageFormat.cm,
      marginLeft: _pageMargin * PdfPageFormat.cm,
      marginRight: _pageMargin * PdfPageFormat.cm,
    );

    PdfPoint landscapeSize = landscape.availableDimension.translate(
      -_pagePadding.horizontal,
      -_pagePadding.vertical,
    );

    PdfPageFormat portrait = PdfPageFormat.a4.copyWith(
      marginTop: _pageMargin * PdfPageFormat.cm,
      marginBottom: _pageMargin * PdfPageFormat.cm,
      marginLeft: _pageMargin * PdfPageFormat.cm,
      marginRight: _pageMargin * PdfPageFormat.cm,
    );

    PdfPoint portraitSize = portrait.availableDimension.translate(
      -_pagePadding.horizontal,
      -_pagePadding.vertical,
    );

    int landscapeNumPages = (planSize.x / landscapeSize.x).ceil() *
        (planSize.y / landscapeSize.y).ceil();

    int portraitNumPages = (planSize.x / portraitSize.x).ceil() *
        (planSize.y / portraitSize.y).ceil();

    if (landscapeNumPages <= portraitNumPages) {
      return landscape;
    } else {
      return portrait;
    }
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

class TournamentPlanPageLabel extends pw.StatelessWidget {
  TournamentPlanPageLabel({
    required this.l10n,
    required this.tournament,
    required int this.numRows,
    required int this.numColumns,
    required int this.row,
    required int this.column,
  }) : _showPageNumber = true;

  TournamentPlanPageLabel.withoutPageNumber({
    required this.l10n,
    required this.tournament,
  })  : numRows = null,
        numColumns = null,
        row = null,
        column = null,
        _showPageNumber = false;

  final BadmintonTournamentMode tournament;

  final AppLocalizations l10n;

  final int? numRows;
  final int? numColumns;

  final int? row;
  final int? column;

  final bool _showPageNumber;

  @override
  pw.Widget build(pw.Context context) {
    pw.TextStyle textStyle = const pw.TextStyle(fontSize: 10);

    pw.Widget competitionLabel = CompetitionLabel(
      competition: tournament.competition,
      l10n: l10n,
      textStyle: textStyle,
    );

    pw.Widget? pageNumLabel;
    if (_showPageNumber) {
      int pageNumber = numColumns! * row! + column!;

      pageNumLabel = pw.Text(
        l10n.pageNofM('${numColumns}x$numRows', pageNumber + 1),
        style: textStyle,
      );
    }

    return pw.Row(children: [
      competitionLabel,
      if (_showPageNumber) ...[
        pw.SizedBox(width: 1.2 * PdfPageFormat.cm),
        pageNumLabel!,
      ],
      pw.SizedBox(width: 0.85 * PdfPageFormat.cm),
    ]);
  }
}
