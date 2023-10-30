import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/constants.dart';
import 'package:pdf/widgets.dart' as pw;

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
    );
  }
}
