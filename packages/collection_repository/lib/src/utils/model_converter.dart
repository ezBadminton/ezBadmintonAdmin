import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:collection/collection.dart';

/// Helper functions to convert PocketBase RecordModel into json maps for
/// constructing data model objects

extension JsonPocketbaseConversions on Map<String, dynamic> {
  /// Remove the ID-strings of non-expanded relations in a json-map.
  ///
  /// The [json] serialization of a data object may contain relations in some of
  /// its [expandedFields] that have not been expanded by the DB. In that case the
  /// json fields hold string values containing the IDs of the related models.
  ///
  /// This method replaces the ID-strings with empty values (null or []).
  ///
  /// It also unwraps the single element lists that the pocketbase DB returns for
  /// single valued relations.
  void cleanUpExpansions(
    List<ExpandedField> expandedFields,
  ) {
    for (ExpandedField expandedField in expandedFields) {
      String key = expandedField.key;
      // Replace single-valued, non-expanded relation with null
      if (this[key] is String) {
        assert(!expandedField.isRequired);
        this[key] = null;
      }
      // Replace multi-valued, non-expanded relation with []
      else if (expandedField.isMulti &&
          (this[key] as List).firstOrNull is String) {
        this[key] = [];
      }
      // Unwrap single-valued, expanded relation
      else if (expandedField.isSingle && this[key] is List) {
        this[key] = this[key][0];
      }
    }
  }

  /// Collapse an expanded json map
  ///
  /// The expanded maps are replaced with their IDs
  /// so the DB can reference them. If a field wasn't expanded it is removed
  /// from the json so the DB doesn't delete the reference.
  void collapseExpansions(
    List<ExpandedField> expandedFields,
  ) {
    for (ExpandedField expandedField in expandedFields) {
      String key = expandedField.key;
      if (this[key] is Map && isValidID(this[key]['id'])) {
        this[key] = this[key]['id'];
      } else if (this[key] is List) {
        this[key] = (this[key] as List)
            .where((e) => isValidID(e['id']))
            .map((e) => e['id'])
            .toList();
      } else if (this[key] != null) {
        remove(key);
      }
    }
  }

  /// Remove the fields that the database sets before sending a new object
  /// for create or update.
  void clearMetaJsonFields() {
    for (var key in ['id', 'created', 'updated']) {
      remove(key);
    }
  }
}

extension RecordModelConverions on RecordModel {
  /// Convert a [RecordModel] into a json-map without expansions
  Map<String, dynamic> toCollapsedJson() {
    Map<String, dynamic> map = data;
    for (var key in map.keys) {
      // The json from db never returns null. Instead it returns an empty string.
      if (map[key] is String && (map[key] as String).isEmpty) {
        map[key] = null;
      }
    }
    map.putIfAbsent('id', () => id);
    map.putIfAbsent('created', () => created);
    map.putIfAbsent('updated', () => updated);
    return map;
  }

  /// Put all values of a [RecordModel] into a map
  ///
  /// If the model has relations to other models they are expanded up to
  /// [expansionDepth] levels deep.
  Map<String, dynamic> toExpandedJson({int expansionDepth = 7}) {
    return _toExpandedJson(toCollapsedJson(), expansionDepth);
  }

  /// Add the expansions of a [RecordModel] to its [json] from
  /// [toCollapsedJson].
  ///
  /// Recurses up to [expansionDepth] levels deep.
  Map<String, dynamic> _toExpandedJson(
      Map<String, dynamic> json, int expansionDepth) {
    if (expansionDepth <= 0) {
      // Return json without expansions
      return json;
    }
    for (MapEntry<String, List<RecordModel>> expansion in expand.entries) {
      var relationIDs = json.remove(expansion.key);
      var relatedRecords = expansion.value;
      assert(relatedRecords
              .map((r) => r.id)
              .where((id) => relationIDs.contains(id))
              .length ==
          ((relationIDs is List) ? relationIDs.length : 1));
      List<Map<String, dynamic>> relatedJsonObjects =
          relatedRecords.map((e) => e.toCollapsedJson()).toList();
      json.putIfAbsent(expansion.key, () => relatedJsonObjects);
      // Recurse with nested relations
      for (final nestedRecord in IterableZip<dynamic>(
        [relatedRecords, relatedJsonObjects],
      )) {
        (nestedRecord[0] as RecordModel)._toExpandedJson(
          nestedRecord[1],
          expansionDepth - 1,
        );
      }
    }
    return json;
  }
}

bool isValidID(String id) {
  return id.length >= 15;
}
