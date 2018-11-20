import 'dart:html';
import 'package:meta/meta.dart';
import 'package:mdc_web/mdc_web.dart';
import 'attribute_observer.dart';
import 'util.dart';

/// * [Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/base/src/base-element.ts)
/// (more like 'spirit animal')
abstract class MWCComponent extends AttributeObserver {
  MWCComponent(Element root,
      {List<String> rootAttributes, List<String> subtreeAttributes})
      : super(root,
            rootAttributes: rootAttributes,
            subtreeAttributes: subtreeAttributes) {
    if (!hasAttribute(root, 'mwc-upgraded')) {
      fullRender();
      setBoolAttribute(root, 'mwc-upgraded', true);
      afterNextRender().then((_) => afterFirstRender());
    }
  }

  @protected
  void fullRender() {
    root.setInnerHtml(innerHtml(), treeSanitizer: NodeTreeSanitizer.trusted);
  }

  /// The root element of the corresponding MDC component.
  Element get mdcRoot => root.children[0];

  MDCComponent get component => null;

  /// Get the initial innerHTML of this element. Typically called once at
  /// initialization, and again if the outermost tag of the template changes.
  @protected
  String innerHtml();

  /// Setup event listeners and other things that should not block first paint.
  @protected
  void afterFirstRender() {}

  @override
  @protected
  void attributeChanged(String name, String oldValue, String newValue) {}

  @override
  @protected
  void subtreeChanged(Element target, bool removed) {}
}
