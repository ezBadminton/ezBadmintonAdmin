import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/settings/models/queue_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'local_preferences_state.dart';

/// The [LocalPreferencesCubit] defines functions for changing the set
/// of local preferences that the user can make to customize their install
/// of ezBadminton. The prefences being local means they only apply
/// to the particular machine they were set on.
///
/// The cubit makes a best effort to persist the preferences using
/// the shared_preferences plugin but will update them in its state regardless
/// of whether the persistence succeeds. If persisting fails a setting might be
/// lost after restarting the client but that is as unlikely as it is tolerable
/// because these settings are only stored for convenience in the first place.
class LocalPreferencesCubit extends Cubit<LocalPreferencesState> {
  LocalPreferencesCubit() : super(LocalPreferencesState()) {
    _preferenceStore = SharedPreferencesAsync();
    _queueModePreference = _QueueModePreference(
      sharedPreferences: _preferenceStore,
    );
    _competitionFilterNotificationPreference =
        _CompetitionFilterNotificationPreference(
      sharedPreferences: _preferenceStore,
    );

    _qualificationOverrideNotificationPreference =
        _QualificationOverrideNotificationPreference(
      sharedPreferences: _preferenceStore,
    );

    _loadLocalPreferences();
  }

  late final SharedPreferencesAsync _preferenceStore;

  late final _QueueModePreference _queueModePreference;
  late final _CompetitionFilterNotificationPreference
      _competitionFilterNotificationPreference;
  late final _QualificationOverrideNotificationPreference
      _qualificationOverrideNotificationPreference;

  void _loadLocalPreferences() async {
    final QueueMode queueMode = await _queueModePreference.load();
    final bool showCompetitionFilterNotification =
        await _competitionFilterNotificationPreference.load();
    final bool showQualificationOverrideNotification =
        await _qualificationOverrideNotificationPreference.load();

    emit(state.copyWith(
      queueMode: queueMode,
      showGlobalCompetitionFilterNotification:
          showCompetitionFilterNotification,
      showQualificationOverrideNotification:
          showQualificationOverrideNotification,
    ));
  }

  void queueModeChanged(QueueMode mode) {
    emit(state.copyWith(
      queueMode: mode,
    ));
    _queueModePreference.save(mode);
  }

  void competitionFilterNotificationPreferenceChanged(bool showNotification) {
    emit(state.copyWith(
      showGlobalCompetitionFilterNotification: showNotification,
    ));
    _competitionFilterNotificationPreference.save(showNotification);
  }

  void qualificatinoOverrideNotificationPreferenceChanged(
    bool showNotification,
  ) {
    emit(state.copyWith(
      showQualificationOverrideNotification: showNotification,
    ));
    _qualificationOverrideNotificationPreference.save(showNotification);
  }
}

/// The [T] type is the original type of the preference, the [P] type is the
/// type that is used for storing it in the shared preferences
/// (String, bool or int).
sealed class _LocalPreference<T, P> {
  const _LocalPreference({required this.sharedPreferences});

  final SharedPreferencesAsync sharedPreferences;

  String get key;
  T get defaultValue;

  Future<T> load() async {
    P? savedValue = await switch (P) {
      const (String) => sharedPreferences.getString(key) as Future<P?>,
      const (bool) => sharedPreferences.getBool(key) as Future<P?>,
      const (int) => sharedPreferences.getInt(key) as Future<P?>,
      _ => throw Exception('unsupported shared preference type'),
    };
    if (savedValue == null) {
      return defaultValue;
    }
    final preference = unmarshal(savedValue);
    return preference ?? defaultValue;
  }

  P marshal(T preference);
  T? unmarshal(P value);

  Future<void> save(T preference) async {
    P marshalled = marshal(preference);
    switch (marshalled) {
      case String marshalled:
        return sharedPreferences.setString(key, marshalled);
      case bool marshalled:
        return sharedPreferences.setBool(key, marshalled);
      case int marshalled:
        return sharedPreferences.setInt(key, marshalled);
      default:
        throw Exception('unsupported shared preference type');
    }
  }
}

class _QueueModePreference extends _LocalPreference<QueueMode, String> {
  _QueueModePreference({required super.sharedPreferences});

  @override
  String get key => 'matchQueueMode';

  @override
  QueueMode get defaultValue => QueueMode.manual;

  @override
  String marshal(QueueMode mode) {
    return mode.name;
  }

  @override
  QueueMode? unmarshal(String name) {
    return QueueMode.values.firstWhereOrNull((mode) => mode.name == name);
  }
}

abstract class _BoolPreference extends _LocalPreference<bool, bool> {
  _BoolPreference({required super.sharedPreferences});

  @override
  bool get defaultValue => true;

  @override
  bool marshal(bool showNotification) {
    return showNotification;
  }

  @override
  bool? unmarshal(bool showNotification) {
    return showNotification;
  }
}

class _CompetitionFilterNotificationPreference extends _BoolPreference {
  _CompetitionFilterNotificationPreference({required super.sharedPreferences});

  @override
  String get key => 'showCompetitionFilterNotification';
}

class _QualificationOverrideNotificationPreference extends _BoolPreference {
  _QualificationOverrideNotificationPreference({
    required super.sharedPreferences,
  });

  @override
  String get key => 'showQualificationOverrideNotification';
}
