import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/printing/pdf_printing_cubit.dart';
import 'package:ez_badminton_admin_app/printing/pdf_widgets/certificate.dart';
import 'package:ez_badminton_admin_app/widgets/tournament_brackets/utils.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:model_repository/model_repository.dart' as models;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:ez_badminton_admin_app/l10n/l10n.dart';

part 'certificate_printing_state.dart';

/// The number of top places that get a certificate printed (e.g. 3 for
/// "1st, 2nd and 3rd place").
const int numCertifiedPlaces = 3;

/// The page format used for certificates: A4 with a narrower margin than
/// the `pdf` package's A4 default (which is 2cm all around), so the
/// printable area (and thus the space available for field positions) is
/// bigger. Kept in sync with [models.certificateMarginCm], which
/// [models.CertificateTemplateField.xCm]/[models.CertificateTemplateField.yCm]
/// are measured relative to.
final PdfPageFormat certificatePageFormat = PdfPageFormat.a4.copyWith(
  marginLeft: models.certificateMarginCm * PdfPageFormat.cm,
  marginRight: models.certificateMarginCm * PdfPageFormat.cm,
  marginTop: models.certificateMarginCm * PdfPageFormat.cm,
  marginBottom: models.certificateMarginCm * PdfPageFormat.cm,
);

class CertificatePrintingCubit extends Cubit<CertificatePrintingState>
    with PdfPrintingCubit {
  CertificatePrintingCubit({
    required this.l10n,
    required models.ModelStore<models.CertificateTemplate> templateStore,
  })  : _templateStore = templateStore,
        super(const CertificatePrintingState());

  final AppLocalizations l10n;

  final models.ModelStore<models.CertificateTemplate> _templateStore;

  void competitionsChanged(List<models.TournamentPlan> tournaments) {
    emit(state.copyWith(tournaments: tournaments));
    _generatePdf();
  }

  @override
  void pdfOpened() {
    _saveAndOpenPdf();
  }

  @override
  void saveLocationOpened() async {
    Directory saveLocation = await getSaveLocationDir();

    emit(state.copyWith(
      openedDirectory: SelectionInput.dirty(value: saveLocation),
    ));
  }

  void _generatePdf() {
    List<models.CertificateTemplate> templates = _templateStore.getList();

    if (state.tournaments.isEmpty || templates.isEmpty) {
      emit(state.copyWith(pdfDocument: const SelectionInput.dirty()));
      return;
    }

    models.CertificateTemplate template = templates.first;

    final pdf = pw.Document();

    for (models.TournamentPlan tPlan in state.tournaments) {
      List<(int, models.Team)> topPlacements = _getTopPlacements(tPlan);

      for ((int, models.Team) placement in topPlacements) {
        int place = placement.$1;
        models.Team team = placement.$2;

        for (models.Player player in team.players) {
          Map<String, String> values = {
            'placement': l10n.nthPlace(place),
            'playerName': _playerNameForCertificate(player, team),
            'competitionName':
                display_strings.competitionLabel(l10n, tPlan.competition),
            'playingClass': _playingClass(tPlan.competition),
            'discipline':
                display_strings.competitionCategory(l10n, tPlan.competition),
            'date': DateFormat('dd. MMM yyyy', l10n.localeName)
                .format(DateTime.now()),
          };

          pdf.addPage(
            pw.Page(
              pageFormat: certificatePageFormat,
              build: (context) => Certificate(
                template: template,
                values: values,
                isDoubles: team.players.length > 1,
                pageFormat: certificatePageFormat,
              ),
            ),
          );
        }
      }
    }

    emit(state.copyWith(
      pdfDocument: SelectionInput.dirty(value: pdf),
    ));
  }

  /// Returns the teams that placed within the top [numCertifiedPlaces] of
  /// the given [tPlan], each paired with their 1-based placement number.
  ///
  /// Tied teams share the same placement number and are all included, even
  /// if that means going slightly beyond [numCertifiedPlaces] teams in total.
  List<(int, models.Team)> _getTopPlacements(models.TournamentPlan tPlan) {
    List<List<models.Team>> ranking = tPlan.tournament.finalRanking;
    List<int> rankIndices = getRankIndices(ranking);

    List<(int, models.Team)> placements = [];

    for ((int, List<models.Team>) rankEntry in ranking.indexed) {
      int rankIndex = rankIndices[rankEntry.$1];
      if (rankIndex >= numCertifiedPlaces) {
        break;
      }
      for (models.Team team in rankEntry.$2) {
        placements.add((rankIndex + 1, team));
      }
    }

    return placements;
  }

  /// The name printed on a player's certificate.
  ///
  /// For singles, this is "First Last". For doubles/mixed (teams with two
  /// players), it's "OwnLastName / PartnerLastName" - i.e. each player's
  /// certificate lists their own last name first, followed by their
  /// partner's.
  ///
  /// Defensively falls back to just the player's own name if no distinct
  /// partner can be found (e.g. unexpected team data), instead of crashing.
  String _playerNameForCertificate(models.Player player, models.Team team) {
    if (team.players.length <= 1) {
      return '${player.firstName} ${player.lastName}';
    }

    models.Player? partner = team.players.firstWhereOrNull(
      (p) => p.id != player.id,
    );

    if (partner == null) {
      return '${player.firstName} ${player.lastName}';
    }

    return '${player.lastName} / ${partner.lastName}';
  }

  /// The "Spielklasse" (playing class) of the [competition]: its playing
  /// level and/or age group, if used - e.g. "Kreisklasse ● U19". Empty if
  /// neither is used for this tournament.
  String _playingClass(models.Competition competition) {
    List<String> parts = [];

    if (competition.playingLevel != null) {
      parts.add(competition.playingLevel!.name);
    }
    if (competition.ageGroup != null) {
      parts.add(display_strings.ageGroup(l10n, competition.ageGroup!));
    }

    return parts.join(' ● ');
  }

  void _saveAndOpenPdf() async {
    if (state.pdfDocument.value == null) {
      return;
    }

    Directory certificateDir = await getSaveLocationDir();

    final String pdfFileName = getPdfFileName(
      (fileIndex) =>
          'certificates_${fileIndex.toString().padLeft(3, '0')}.pdf',
      certificateDir,
    );

    final File file = File(p.join(certificateDir.path, pdfFileName));

    final Uint8List pdfBytes = await state.pdfDocument.value!.save();

    await file.writeAsBytes(pdfBytes);

    emit(state.copyWith(openedFile: SelectionInput.dirty(value: file)));
  }

  @override
  Future<Directory> getSaveLocationDir() async {
    final Directory documentDir = await getApplicationDocumentsDirectory();
    final String certificatePath = p.join(
      documentDir.path,
      'ez_badminton',
      'certificates',
    );
    final Directory certificateDir = Directory(certificatePath);
    if (!certificateDir.existsSync()) {
      await certificateDir.create(recursive: true);
    }

    return certificateDir;
  }
}
