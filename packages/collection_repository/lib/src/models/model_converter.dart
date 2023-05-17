import 'package:pocketbase/pocketbase.dart';
import 'package:collection/collection.dart';

/// Helper functions to convert PocketBase RecordModel into maps for
/// constructing specific model instances
class ModelConverter {
  /// Convert a [RecordModel] into a Map without expansions
  static Map<String, dynamic> modelToMap(RecordModel recordModel) {
    Map<String, dynamic> map = recordModel.data;
    for (var key in map.keys) {
      // The json from db never returns null. Instead it returns an empty string.
      if (map[key] is String && (map[key] as String).isEmpty) {
        map[key] = null;
      }
    }
    map.putIfAbsent('id', () => recordModel.id);
    map.putIfAbsent('created', () => recordModel.created);
    map.putIfAbsent('updated', () => recordModel.updated);
    return map;
  }

  /// Convert an expanded json map from the DB into a serializable format
  ///
  /// [json] is the json map with expanded fields. The list of [expandedFields]
  /// is then processed and the converted json map is returned.
  static Map<String, dynamic> convertExpansions(
      Map<String, dynamic> json, List<ExpandedField> expandedFields) {
    for (ExpandedField expandedField in expandedFields) {
      String key = expandedField.key;
      // When a field is not expanded it contains the id of the relation as a
      // string.
      if (!expandedField.isRequired && json[key] is String) {
        json[key] = null;
      }
      // If it's not null the expanded object is always a list even if the
      // expansion is single.
      else if (expandedField.isSingle && json[key] is List) {
        json[key] = json[key][0];
      }
    }
    return json;
  }

  /// Collapse an expanded json map
  ///
  /// The expanded maps are replaced with their IDs
  /// so the DB can reference them. If a field wasn't expanded it is removed
  /// from the json so the DB doesn't delete the reference.
  static Map<String, dynamic> collapseExpansions(
      Map<String, dynamic> json, List<ExpandedField> expandedFields) {
    for (ExpandedField expandedField in expandedFields) {
      String key = expandedField.key;
      if (json[key] is Map && _isValidID(json[key]['id'])) {
        json[key] = json[key]['id'];
      } else if (json[key] is List) {
        json[key] = (json[key] as List).map((e) => e['id']);
      } else {
        json.remove(key);
      }
    }
    return json;
  }

  static bool _isValidID(String id) {
    return id.length >= 15;
  }

  /// Put all values of a RecordModel into a map
  ///
  /// If the model has references to other models they are expanded up to
  /// [expansion_depth] levels deep.
  static Map<String, dynamic> modelToExpandedMap(RecordModel recordModel,
      {int expansion_depth = 7}) {
    return _modelToExpandedMap(
        recordModel, modelToMap(recordModel), expansion_depth);
  }

  /// Add the expansions of a [RecordModel] to its map from [modelToMap].
  ///
  /// Recurses up to [expansion_depth] levels deep.
  static Map<String, dynamic> _modelToExpandedMap(
      RecordModel recordModel, Map<String, dynamic> map, int expansion_depth) {
    if (expansion_depth <= 0) {
      // Return map without expansions
      return map;
    }
    for (MapEntry<String, List<RecordModel>> expansion
        in recordModel.expand.entries) {
      map.remove(expansion.key);
      List<Map<String, dynamic>> expandedMaps =
          expansion.value.map(modelToMap).toList();
      map.putIfAbsent(expansion.key, () => expandedMaps);
      for (final nestedRecord in IterableZip<dynamic>(
        [expansion.value, expandedMaps],
      )) {
        _modelToExpandedMap(
          nestedRecord[0],
          nestedRecord[1],
          expansion_depth - 1,
        );
      }
    }
    return map;
  }
}

class ExpandedField {
  /// Models an expanded field of a model
  ///
  /// They [key] is the json key under which the field is found. [isRequired]
  /// and [isSingle] specify if the field can be null and wether the expansion
  /// links to a list or a single instance.
  const ExpandedField({
    required this.model,
    required this.key,
    required this.isRequired,
    required this.isSingle,
  });
  final Type model;
  final String key;
  final bool isRequired;
  final bool isSingle;
}
