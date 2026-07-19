import 'dart:typed_data';

import 'package:ez_badminton_admin_app/assets/pdf_fonts.dart';
import 'package:model_repository/model_repository.dart' as models;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Renders a single certificate page: the [values] are printed at the
/// positions defined by the [template]'s fields (see
/// [models.CertificateTemplateField] for how position/width/alignment work).
/// A field either shows a computed value (looked up in [values] by variable
/// name - skipped if there's no matching entry) or fixed, literal text.
///
/// [isDoubles] determines whether fields with a `showIf` restriction
/// (singles/doubles) are shown.
///
/// If the [template] has a [models.CertificateTemplate.backgroundImage],
/// it is expected to already be resolved to raw image bytes and passed in
/// via [backgroundImageBytes] - if that's null (e.g. no background
/// configured, printing directly onto pre-printed paper), the page is left
/// blank apart from the overlaid fields.
class Certificate extends pw.StatelessWidget {
  Certificate({
    required this.template,
    required this.values,
    required this.isDoubles,
    this.backgroundImageBytes,
    this.pageFormat = PdfPageFormat.a4,
  });

  final models.CertificateTemplate template;
  final Map<String, String> values;
  final bool isDoubles;
  final Uint8List? backgroundImageBytes;
  final PdfPageFormat pageFormat;

  @override
  pw.Widget build(pw.Context context) {
    List<pw.Widget> children = [];

    if (backgroundImageBytes != null) {
      children.add(
        pw.Image(
          pw.MemoryImage(backgroundImageBytes!),
          fit: pw.BoxFit.cover,
          width: pageFormat.availableDimension.x,
          height: pageFormat.availableDimension.y,
        ),
      );
    }

    for (models.CertificateTemplateField field in template.fields) {
      bool matchesCondition = switch (field.showIf) {
        null => true,
        models.CertificateTemplateFieldCondition.singles => !isDoubles,
        models.CertificateTemplateFieldCondition.doubles => isDoubles,
      };
      if (!matchesCondition) {
        continue;
      }

      String? value =
          field.variable != null ? values[field.variable] : field.text;
      if (value == null) {
        continue;
      }

      pw.TextAlign textAlign = switch (field.align) {
        models.CertificateTemplateFieldAlign.left => pw.TextAlign.left,
        models.CertificateTemplateFieldAlign.center => pw.TextAlign.center,
        models.CertificateTemplateFieldAlign.right => pw.TextAlign.right,
      };

      double resolvedX = field.resolvedX;
      double resolvedY = field.resolvedY;

      double width =
          field.width ?? (pageFormat.availableDimension.x - resolvedX);

      pw.Font font = switch (field.font) {
        models.CertificateTemplateFieldFont.standard =>
          field.bold ? PdfFonts().interBold : PdfFonts().interNormal,
        models.CertificateTemplateFieldFont.monotypeCorsiva =>
          PdfFonts().monotypeCorsiva,
      };

      pw.TextStyle styleWithSize(double fontSize) => pw.TextStyle(
            font: font,
            fontSize: fontSize,
            fontWeight: field.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          );

      pw.Widget textWidget = pw.RichText(
        textAlign: textAlign,
        text: pw.TextSpan(
          children: [
            if (field.prefix != null && field.prefix!.isNotEmpty)
              pw.TextSpan(
                text: field.prefix,
                style: styleWithSize(field.prefixFontSize ?? field.fontSize),
              ),
            pw.TextSpan(
              text: value,
              style: styleWithSize(field.fontSize),
            ),
            if (field.suffix != null && field.suffix!.isNotEmpty)
              pw.TextSpan(
                text: field.suffix,
                style: styleWithSize(field.suffixFontSize ?? field.fontSize),
              ),
          ],
        ),
      );

      children.add(
        pw.Positioned(
          left: resolvedX,
          top: resolvedY,
          child: pw.SizedBox(
            width: width,
            child: textWidget,
          ),
        ),
      );
    }

    return pw.Stack(children: children);
  }
}
