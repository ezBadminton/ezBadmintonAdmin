part of 'certificate_template_settings_cubit.dart';

class CertificateTemplateSettingsState extends CollectionQuerierState {
  CertificateTemplateSettingsState({
    this.loadingStatus = LoadingStatus.loading,
    this.formStatus = FormzSubmissionStatus.initial,
    this.collections = const [],
    this.title,
    this.fieldsJson,
  });

  @override
  final LoadingStatus loadingStatus;
  final FormzSubmissionStatus formStatus;

  @override
  final List<List<Model>> collections;

  /// The currently edited title. `null` means "not edited yet, use the
  /// loaded template's title (or empty if there is none)".
  final String? title;

  /// The currently edited fields JSON. `null` means "not edited yet, use
  /// the loaded template's fields (or empty if there is none)".
  final String? fieldsJson;

  /// The single existing template, if any (MVP: only one template is
  /// supported).
  CertificateTemplate? get template =>
      getCollection<CertificateTemplate>().firstOrNull;

  CertificateTemplateSettingsState copyWith({
    LoadingStatus? loadingStatus,
    FormzSubmissionStatus? formStatus,
    List<List<Model>>? collections,
    String? title,
    String? fieldsJson,
  }) {
    return CertificateTemplateSettingsState(
      loadingStatus: loadingStatus ?? this.loadingStatus,
      formStatus: formStatus ?? this.formStatus,
      collections: collections ?? this.collections,
      title: title ?? this.title,
      fieldsJson: fieldsJson ?? this.fieldsJson,
    );
  }
}
