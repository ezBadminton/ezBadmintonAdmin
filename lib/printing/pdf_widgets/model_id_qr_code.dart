import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/cubit/match_scan_listener_cubit.dart';
import 'package:ez_badminton_admin_app/match_management/result_entering/widgets/match_scan_listener.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A QR code that contains a string of the format
/// "[matchQrPrefix]`<model ID>`[matchQrSuffix]".
///
/// See also:
/// * [MatchScanListener] which listens to global keyboard input
/// (e.g. from a scanner device)
/// * [MatchScanListenerCubit] which detects the model ID and finds the
/// corresponding object
class ModelIdQRCode extends pw.StatelessWidget {
  ModelIdQRCode(this.model);

  final Model model;

  @override
  pw.Widget build(pw.Context context) {
    final pw.Barcode qrCodeSettings = pw.Barcode.qrCode(
      typeNumber: 2,
      errorCorrectLevel: pw.BarcodeQRCorrectionLevel.medium,
    );

    return pw.BarcodeWidget(
      barcode: qrCodeSettings,
      data: '$matchQrPrefix${model.id}$matchQrSuffix',
      drawText: false,
      width: 60,
      height: 60,
      color: PdfColors.grey800,
    );
  }
}
