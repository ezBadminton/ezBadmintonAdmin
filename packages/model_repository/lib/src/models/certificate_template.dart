import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/certificate_template.freezed.dart';
part 'generated/certificate_template.g.dart';

@freezed
class CertificateTemplate extends Model with _$CertificateTemplate {
  const CertificateTemplate._();

  /// A printable certificate template ("Urkunde") for variable fields (e.g.
  /// player name, placement) that are printed at a fixed position, typically
  /// onto pre-printed physical certificate paper.
  ///
  /// [backgroundImage] optionally holds the file name of an uploaded
  /// background image (e.g. a scanned/designed certificate) as stored by
  /// PocketBase. It is empty when no background is used, i.e. when the
  /// fields are printed directly onto pre-printed paper.
  ///
  /// [fields] describes where and how each variable is printed. PocketBase
  /// stores this as a native JSON array (not a JSON-encoded string), so it's
  /// decoded straight into [CertificateTemplateField]s here.
  factory CertificateTemplate({
    required String id,
    required DateTime created,
    required DateTime updated,
    required String title,
    @Default('') String backgroundImage,
    @JsonKey(fromJson: _fieldsFromJson, toJson: _fieldsToJson)
    @Default([])
    List<CertificateTemplateField> fields,
  }) = _CertificateTemplate;

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) =>
      _$CertificateTemplateFromJson(json);

  factory CertificateTemplate.newTemplate(String title) => CertificateTemplate(
        id: '',
        created: DateTime.now().toUtc(),
        updated: DateTime.now().toUtc(),
        title: title,
        backgroundImage: '',
        fields: const [],
      );
}

List<CertificateTemplateField> _fieldsFromJson(dynamic json) {
  if (json is! List) {
    return const [];
  }
  return json
      .map((f) => CertificateTemplateField.fromJson(
            Map<String, dynamic>.from(f as Map),
          ))
      .toList();
}

List<Map<String, dynamic>> _fieldsToJson(List<CertificateTemplateField> fields) {
  return fields.map((f) => f.toJson()).toList();
}

/// The margin around certificate pages, in cm. Certificates use a narrower
/// margin than this app's other PDF exports (which is the `pdf` package's
/// A4 default of 2cm), to maximize usable space on pre-printed certificate
/// paper.
///
/// This is also the reference point for [CertificateTemplateField.xCm]/
/// [CertificateTemplateField.yCm]: a value of `0` there means "right at the
/// edge of the printable area", i.e. [certificateMarginCm] away from the
/// physical paper edge. So measuring with a ruler directly on a physical
/// certificate template, starting from the paper edge, gives the correct
/// [xCm]/[yCm] value directly, with no manual margin subtraction needed.
const double certificateMarginCm = 0.5;

/// Point-per-centimeter conversion factor (1 inch = 2.54cm, 1 inch = 72pt).
const double pdfPointsPerCm = 72 / 2.54;

/// The definition of a single overlaid text label on a [CertificateTemplate].
///
/// A label shows either:
/// - a computed value, if [variable] is set (e.g. `playerName`, `placement`,
///   `competitionName`, `date` - the concrete set of supported variables is
///   defined by whatever prints the certificate, see the certificate
///   printing feature), or
/// - fixed, literal [text] (e.g. "errang bei dem"), if [variable] is `null`.
///
/// Exactly one of [variable] or [text] should be set.
///
/// [showIf] optionally restricts a label to only appear for singles or
/// doubles/mixed competitions. This is meant for exactly the case where
/// wording differs between singles and doubles (e.g. "errang bei dem" vs.
/// "errangen bei dem"): define two labels with the same position, one with
/// `showIf: singles` and one with `showIf: doubles`, each with its own
/// [text]. `null` (the default) means the label always shows.
///
/// [x]/[y] are the position of the label's top left corner in PDF points
/// (1/72 inch), measured from the top left corner of the printable area
/// (i.e. already inside the page margin, see [certificateMarginCm]).
///
/// [xCm]/[yCm] are a convenience alternative to [x]/[y] in centimeters,
/// measured from the physical paper edge (see [certificateMarginCm] for why
/// that's more convenient for measuring with a ruler on a printed template).
/// If set, they take precedence over [x]/[y]. Use [resolvedX]/[resolvedY]
/// to get the final position regardless of which was set.
///
/// [width] is the label's box width; if `null`, it defaults to filling the
/// rest of the page width starting at the label's x position (e.g. `x: 0`
/// without a [width] spans the full page width). The label's text is then
/// horizontally aligned within that box according to [align].
///
/// [prefix]/[suffix] optionally add fixed text directly before/after the
/// label's main value, in the same line but with their own, usually
/// smaller, font size ([prefixFontSize]/[suffixFontSize] - defaulting to
/// [fontSize] if not set). E.g. a placement value "1" with `suffix: "."`
/// and a smaller `suffixFontSize` prints "1" big and "." small right after.
class CertificateTemplateField {
  const CertificateTemplateField({
    this.variable,
    this.text,
    this.x = 0,
    this.y = 0,
    this.xCm,
    this.yCm,
    this.width,
    this.fontSize = 16,
    this.bold = false,
    this.align = CertificateTemplateFieldAlign.center,
    this.showIf,
    this.font = CertificateTemplateFieldFont.standard,
    this.prefix,
    this.prefixFontSize,
    this.suffix,
    this.suffixFontSize,
  });

  final String? variable;
  final String? text;
  final double x;
  final double y;
  final double? xCm;
  final double? yCm;
  final double? width;
  final double fontSize;
  final bool bold;
  final CertificateTemplateFieldAlign align;
  final CertificateTemplateFieldCondition? showIf;
  final CertificateTemplateFieldFont font;
  final String? prefix;
  final double? prefixFontSize;
  final String? suffix;
  final double? suffixFontSize;

  /// The final x position in PDF points, resolved from [xCm] (preferred, if
  /// set) or [x].
  double get resolvedX =>
      xCm != null ? (xCm! - certificateMarginCm) * pdfPointsPerCm : x;

  /// The final y position in PDF points, resolved from [yCm] (preferred, if
  /// set) or [y].
  double get resolvedY =>
      yCm != null ? (yCm! - certificateMarginCm) * pdfPointsPerCm : y;

  factory CertificateTemplateField.fromJson(Map<String, dynamic> json) {
    return CertificateTemplateField(
      variable: json['variable'] as String?,
      text: json['text'] as String?,
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      xCm: (json['xCm'] as num?)?.toDouble(),
      yCm: (json['yCm'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16,
      bold: json['bold'] as bool? ?? false,
      align: CertificateTemplateFieldAlign.values.firstWhere(
        (a) => a.name == json['align'],
        orElse: () => CertificateTemplateFieldAlign.center,
      ),
      showIf: json['showIf'] == null
          ? null
          : CertificateTemplateFieldCondition.values.firstWhere(
              (c) => c.name == json['showIf'],
              orElse: () => throw ArgumentError(
                'Unknown showIf value: ${json['showIf']}',
              ),
            ),
      font: CertificateTemplateFieldFont.values.firstWhere(
        (f) => f.name == json['font'],
        orElse: () => CertificateTemplateFieldFont.standard,
      ),
      prefix: json['prefix'] as String?,
      prefixFontSize: (json['prefixFontSize'] as num?)?.toDouble(),
      suffix: json['suffix'] as String?,
      suffixFontSize: (json['suffixFontSize'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (variable != null) 'variable': variable,
        if (text != null) 'text': text,
        if (xCm != null) 'xCm': xCm else 'x': x,
        if (yCm != null) 'yCm': yCm else 'y': y,
        if (width != null) 'width': width,
        'fontSize': fontSize,
        'bold': bold,
        'align': align.name,
        if (showIf != null) 'showIf': showIf!.name,
        'font': font.name,
        if (prefix != null) 'prefix': prefix,
        if (prefixFontSize != null) 'prefixFontSize': prefixFontSize,
        if (suffix != null) 'suffix': suffix,
        if (suffixFontSize != null) 'suffixFontSize': suffixFontSize,
      };
}

enum CertificateTemplateFieldAlign { left, center, right }

/// Restricts a [CertificateTemplateField] to only be shown for [singles] or
/// [doubles] (which also covers mixed) competitions.
enum CertificateTemplateFieldCondition { singles, doubles }

/// The font a [CertificateTemplateField] is printed in.
///
/// [standard] is the app's regular PDF font (Inter). [monotypeCorsiva] is a
/// decorative script font, meant for certificates - see `PdfFonts` for how
/// the actual font files are bundled/loaded.
enum CertificateTemplateFieldFont { standard, monotypeCorsiva }
