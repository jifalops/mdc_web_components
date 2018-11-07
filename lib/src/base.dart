import 'dart:html';
import 'package:meta/meta.dart';
import 'pseudo_element.dart';
import 'util.dart' show afterNextRender;

/// * [Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/base/src/base-element.ts)
/// (more like 'spirit animal')
abstract class BaseElement extends PseudoElement {
  BaseElement(Element root,
      {List<String> observedAttributes, Node parent, Node directParent})
      : super(root,
            observedAttributes: observedAttributes,
            parent: parent,
            directParent: directParent) {
    firstRender();
    afterNextRender().then((_) => afterFirstRender());
  }

  @protected
  void firstRender();

  @protected
  void render();

  @protected
  void afterFirstRender() {}

  /// Call super *after* handling the changes.
  @override
  @protected
  @mustCallSuper
  void attributesChanged(
      Map<String, dynamic> oldValues, Map<String, dynamic> newValues) {
    render();
  }
}
