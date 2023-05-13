import 'package:collection_repository/collection_repository.dart';
import 'package:collection_repository/src/models/model_converter.dart';

class ExpansionTree {
  ExpansionTree(List<ExpandedField> rootFields)
      : _root = _ExpansionNode.root(rootFields);

  final _ExpansionNode _root;

  void expandWith(Type model, List<ExpandedField> expand) {
    _root.expandWith(model, expand);
  }

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
  _ExpansionNode.root(List<ExpandedField> rootFields)
      : expandedField = ExpandedField(
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

  void expandWith(Type model, List<ExpandedField> expand) {
    if (this.expandedField.model == model && isLeaf()) {
      _expandWith(expand);
    } else {
      for (var child in children) {
        child.expandWith(model, expand);
      }
    }
  }

  void _expandWith(List<ExpandedField> expand) {
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
