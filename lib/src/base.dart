import 'dart:html';
import 'package:meta/meta.dart';
import 'package:mdc_web/mdc_web.dart';
import 'pseudo_element.dart';
import 'util.dart';

/// * [Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/base/src/base-element.ts)
/// (more like 'spirit animal')
abstract class MWCComponent extends PseudoElement {
  MWCComponent(Element root,
      {List<String> observedAttributes, Node parent, Node directParent})
      : super(root,
            observedAttributes: observedAttributes,
            parent: parent,
            directParent: directParent) {
    if (!hasAttribute(root, 'upgraded')) {
      fullRender();
      setBoolAttribute(root, 'upgraded', true);
      afterNextRender().then((_) => afterFirstRender());
    }
  }

  @protected
  void fullRender() {
    root.setInnerHtml(innerHtml(), treeSanitizer: NodeTreeSanitizer.trusted);
  }

  Element get mdcRoot => root.children[0];

  MDCComponent get component => null;

  /// Get the initial innerHTML of this element. Typically called once at
  /// initialization, and again if the outermost tag of the template changes.
  @protected
  String innerHtml();

  /// Setup event listeners and other things that should not block first paint.
  @protected
  void afterFirstRender() {}
}
