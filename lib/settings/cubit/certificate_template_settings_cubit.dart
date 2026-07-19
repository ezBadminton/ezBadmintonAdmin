import 'dart:convert';

import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:formz/formz.dart';

part 'certificate_template_settings_state.dart';

/// Manages the single [CertificateTemplate] used for certificate printing.
///
/// This is a deliberately simple, single-template MVP: there is no UI to
/// manage multiple templates or a visual field-position editor yet. The
/// [fields] are edited as raw JSON.
class CertificateTemplateSettingsCubit
    extends CollectionQuerierCubit<CertificateTemplateSettingsState> {
  CertificateTemplateSettingsCubit({
    required ModelStore<CertificateTemplate> templateStore,
  }) : super(
          modelStores: [templateStore],
          CertificateTemplateSettingsState(),
        );

  /// The template as last created/updated by this cubit, tracked locally in
  /// addition to [CertificateTemplateSettingsState.template] (which is
  /// derived from the realtime-synced collection).
  ///
  /// This closes a race condition: after [saved] creates or updates a
  /// template, the realtime update confirming that change can take a moment
  /// to arrive. If the user saves again before that happens,
  /// [CertificateTemplateSettingsState.template] would still look like there
  /// is no template yet, causing a second, duplicate template to be created
  /// instead of updating the first one.
  CertificateTemplate? _lastSavedTemplate;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    emit(state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    ));
  }

  void titleChanged(String title) {
    emit(state.copyWith(
      title: title,
      formStatus: FormzSubmissionStatus.initial,
    ));
  }

  void fieldsJsonChanged(String fieldsJson) {
    emit(state.copyWith(
      fieldsJson: fieldsJson,
      formStatus: FormzSubmissionStatus.initial,
    ));
  }

  void saved() async {
    if (state.formStatus == FormzSubmissionStatus.inProgress) {
      return;
    }

    String effectiveTitle =
        state.title ?? state.template?.title ?? _lastSavedTemplate?.title ?? '';
    String effectiveFieldsJson = state.fieldsJson ??
        jsonEncode(
          (state.template?.fields ?? _lastSavedTemplate?.fields ?? const <CertificateTemplateField>[])
              .map((f) => f.toJson())
              .toList(),
        );

    // Validate the JSON before saving so a broken config never reaches the
    // server (and thus never breaks certificate printing).
    List<CertificateTemplateField>? parsedFields =
        _tryParseFieldsJson(effectiveFieldsJson);
    if (parsedFields == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(formStatus: FormzSubmissionStatus.inProgress));

    CertificateTemplate? existing = state.template ?? _lastSavedTemplate;

    CertificateTemplate? saved;
    if (existing == null) {
      saved = await querier.createModel(
        CertificateTemplate.newTemplate(effectiveTitle).copyWith(
          fields: parsedFields,
        ),
      );
    } else {
      saved = await querier.updateModel(
        existing.copyWith(
          title: effectiveTitle,
          fields: parsedFields,
        ),
      );
    }

    if (saved == null) {
      emit(state.copyWith(formStatus: FormzSubmissionStatus.failure));
      return;
    }

    _lastSavedTemplate = saved;

    emit(state.copyWith(formStatus: FormzSubmissionStatus.success));
  }

  /// Returns the parsed field list, or `null` if [fieldsJson] is invalid.
  List<CertificateTemplateField>? _tryParseFieldsJson(String fieldsJson) {
    if (fieldsJson.trim().isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(fieldsJson);
      if (decoded is! List) {
        return null;
      }
      return decoded
          .map((entry) => CertificateTemplateField.fromJson(
                Map<String, dynamic>.from(entry as Map),
              ))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
