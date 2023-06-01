import 'package:collection_repository/src/expansion_tree/expanded_field.dart';
import 'package:collection_repository/src/utils/model_converter.dart' as sut;
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  test('valid IDs are >=15 characters long', () {
    var invalidID = List<String>.generate(14, (_) => 'A').join();
    expect(sut.isValidID(invalidID), false);
    var validID = List<String>.generate(15, (_) => 'A').join();
    expect(sut.isValidID(validID), true);
  });

  test(
    """RecordModel.toCollapsedJson() correctly copies the meta fields, 
    replaces empty string values with null,
    expand values are ignored""",
    () {
      var timestamp = DateTime(2023, 6, 1, 8).toIso8601String();
      var data = <String, dynamic>{
        'field1': 42,
        'field2': 'hello world',
        'field3': '',
        'expandedField': 'relationID',
      };
      var expand = <String, List<RecordModel>>{
        'relationID': [RecordModel(id: 'relationID', data: data)]
      };

      var model = RecordModel(
        id: 'yeet',
        created: timestamp,
        updated: timestamp,
        data: data,
        expand: expand,
      );

      var jsonMap = model.toCollapsedJson();

      expect(jsonMap['id'], 'yeet');
      expect(jsonMap['created'], timestamp);
      expect(jsonMap['updated'], timestamp);
      expect(jsonMap['field1'], data['field1']);
      expect(jsonMap['field2'], data['field2']);
      expect(jsonMap['field3'], null);
      expect(jsonMap['expandedField'], data['expandedField']);
    },
  );

  test(
    """non-expanded relation fields are cleaned up,
    expanded single-valued relation fields are unwrapped""",
    () {
      var json = <String, dynamic>{
        'field1': 'relationID1',
        'field2': 'normal value',
        'field3': ['multi-relationID1', 'multi-relationID2'],
        'expandedField': [42],
      };

      var expandedFields = [
        const ExpandedField(
          model: Object,
          key: 'field1',
          isRequired: false,
          isSingle: true,
        ),
        const ExpandedField(
          model: Object,
          key: 'field3',
          isRequired: false,
          isSingle: false,
        ),
        const ExpandedField(
          model: Object,
          key: 'expandedField',
          isRequired: false,
          isSingle: true,
        ),
      ];

      json = json..cleanUpExpansions(expandedFields);

      // Non-expanded single-relation set to null
      expect(json['field1'], isNull);
      // Non-expanded multi-relation set to []
      expect(json['field3'], []);
      // Normal value untouched
      expect(json['field2'], 'normal value');
      // Expanded single-relation value unwrapped from the list
      expect(json['expandedField'], 42);
    },
  );

  test('Expanded fields are collapsed to their IDs', () {
    var expandedJson = <String, dynamic>{
      'field1': <String, dynamic>{'id': 'relationID1-aaaaaaa'},
      'field2': <String, dynamic>{'id': 'invalidID'},
      'field3': <Map<String, dynamic>>[
        {'id': 'relationID2-aaaaaaa'},
        {'id': 'relationID3-aaaaaaa'},
        {'id': 'invalidID'},
      ],
      'field4': null,
      'field5': 'normal value',
    };

    var expandedFields = [
      const ExpandedField(
        model: Object,
        key: 'field1',
        isRequired: true,
        isSingle: true,
      ),
      const ExpandedField(
        model: Object,
        key: 'field2',
        isRequired: true,
        isSingle: true,
      ),
      const ExpandedField(
        model: Object,
        key: 'field3',
        isRequired: true,
        isSingle: false,
      ),
      const ExpandedField(
        model: Object,
        key: 'field4',
        isRequired: true,
        isSingle: true,
      ),
    ];

    var collapsedJson = Map.of(expandedJson)
      ..collapseExpansions(expandedFields);

    expect(collapsedJson['field1'], expandedJson['field1']['id']);
    expect(collapsedJson['field2'], isNull);
    expect(collapsedJson['field3'], hasLength(2));
    expect(collapsedJson['field3'][0], expandedJson['field3'][0]['id']);
    expect(collapsedJson['field4'], isNull);
    expect(collapsedJson['field5'], expandedJson['field5']);
  });

  test('meta fields are cleared', () {
    var jsonWithMetaFields = <String, dynamic>{
      'id': 'myid',
      'created': DateTime.now().toIso8601String(),
      'updated': DateTime.now().toIso8601String(),
      'field1': 42,
    };

    var clearedJson = Map.of(jsonWithMetaFields)..clearMetaJsonFields();

    expect(clearedJson['id'], isNull);
    expect(clearedJson['created'], isNull);
    expect(clearedJson['updated'], isNull);
    expect(clearedJson['field1'], jsonWithMetaFields['field1']);
  });

  test(
    """RecordModel.toExpandedJson() correctly constructs the json map
    from the expand data""",
    () {
      var data = <String, dynamic>{
        'relation': 'relationID1',
      };
      var level1ExpandData = <String, dynamic>{
        'field1': 420,
        'relation': 'relationID2',
      };
      var level2ExpandData = <String, dynamic>{
        'field1': 360,
      };
      var expand2 = <String, List<RecordModel>>{
        'relation': [
          RecordModel(
            id: 'relationID2',
            data: level2ExpandData,
          )
        ]
      };
      var expand1 = <String, List<RecordModel>>{
        'relation': [
          RecordModel(
            id: 'relationID1',
            data: level1ExpandData,
            expand: expand2,
          )
        ]
      };

      var model = RecordModel(
        data: data,
        expand: expand1,
      );

      var expandedJson = model.toExpandedJson();

      expect(expandedJson['relation'][0]['field1'], 420);
      expect(expandedJson['relation'][0]['relation'][0]['field1'], 360);
    },
  );
}
