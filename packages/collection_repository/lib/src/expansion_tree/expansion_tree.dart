import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';

class ExpansionTree {
  /// A tree of ExpandedFields representing the relations (and nested relations)
  /// of a data class (or 'model').
  ///
  /// During DB querying the ExpansionTree is passed to specify which relations
  /// should be added to the query result. A tree with just the [rootFields]
  /// just retrieves the top level relations.
  ///
  /// Example: A model called 'Car' having two top level relations to models of
  /// type Engine and Color has an expansion tree with two leaves. If the Engine
  /// itself also has relations they are added as children of the engine leaf.
  /// A query can now be made with the full ExpansionTree to get the car model
  /// with all its (nested) relations present. If some relations are unneeded a
  /// partial tree can be used for the query.
  ExpansionTree(Iterable<ExpandedField> rootFields)
      : _root = _ExpansionNode.root(rootFields);

  final _ExpansionNode _root;

  /// Add a level of relations to the tree
  ///
  /// The relations of type [model] inside the [expand] fields are expanded from
  /// existing leaf nodes in the tree.
  ///
  /// Example:
  /// `ExpansionTree(Car.expandedFields)..expandWith(Engine, Engine.expandedFields)`
  /// would create the Car ExpansionTree with one extra level for the Engine's
  /// relations. If `Car.expandedFields` contains no field that holds a relation
  /// of type Engine, the `expandWith` call does nothing.
  void expandWith(Type model, Iterable<ExpandedField> expand) {
    _root.expandWith(model, expand);
  }

  /// The expansion query string that is sent to the pocketbase DB.
  ///
  /// This string encodes the relation expansions that this ExpansionTree
  /// represents.
  ///
  /// Example: A model named 'Car' with relations of type Engine and Color would
  /// yield: 'engine,color' - given the fields of the Car class are named that
  /// way. If the engine's nested relations were added to the tree it would be
  /// 'engine.horsepower,engine.fueltype,color'.
  String get expandString {
    List<List<String>> expansionStrings = [];
    _root.expansionStringDown(expansionStrings);
    String expandString =
        expansionStrings.map((strings) => strings.reversed.join('.')).join(',');
    return expandString;
  }
}

class _ExpansionNode {
  _ExpansionNode(this.parent, this.expandedField);
  _ExpansionNode.root(Iterable<ExpandedField> rootFields)
      : expandedField = const ExpandedField(
          model: Model,
          key: '',
          isRequired: false,
          isSingle: false,
        ),
        parent = null {
    _expandWith(rootFields);
  }

  final _ExpansionNode? parent;
  final ExpandedField expandedField;
  List<_ExpansionNode> children = const [];

  bool isLeaf() => children.isEmpty;

  void expandWith(Type model, Iterable<ExpandedField> expand) {
    if (expandedField.model == model && isLeaf()) {
      _expandWith(expand);
    } else {
      for (var child in children) {
        child.expandWith(model, expand);
      }
    }
  }

  void _expandWith(Iterable<ExpandedField> expand) {
    children = expand.map((field) => _ExpansionNode(this, field)).toList();
  }

  void expansionStringDown(List<List<String>> expansionStrings) {
    if (isLeaf() && parent != null) {
      List<String> expansionString = [expandedField.key];
      expansionStrings.add(expansionString);
      parent!.expansionStringUp(expansionString);
    } else {
      for (var child in children) {
        child.expansionStringDown(expansionStrings);
      }
    }
  }

  void expansionStringUp(List<String> expansionString) {
    if (parent != null) {
      expansionString.add(expandedField.key);
      parent!.expansionStringUp(expansionString);
    }
  }
}
