import 'dart:html';
import 'package:meta/meta.dart';
import 'package:mdc_web/mdc_web.dart';
import 'attribute_observer.dart';
import 'util.dart';

/// * [Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/base/src/base-element.ts)
/// (more like 'spirit animal')
abstract class MWCComponent {
  MWCComponent(this.root,
      {this.rootAttributes: const {},
      this.subtreeAttributes: const {},
      bool directDescendantsOnly: false})
      : _directDescendantsOnly = directDescendantsOnly {
    if (!hasAttribute(root, 'mwc-upgraded')) {
      if (displayStyle.isNotEmpty) root.style.display = displayStyle;
      fullRender();
      setBoolAttribute(root, 'mwc-upgraded', true);
      afterNextRender().then((_) => afterFirstRender());
    }
  }

  final Element root;
  final Map<String, String> rootAttributes;
  final Map<String, String> subtreeAttributes;
  final bool _directDescendantsOnly;

  AttributeObserver _observer;

  /// The root element of the corresponding MDC component.
  Element get mdcRoot => root.children[0];

  MDCComponent get component => null;

  String get displayStyle => '';

  @protected
  @mustCallSuper
  void fullRender() {
    _observer?.destroy();
    root.setInnerHtml(innerHtml(), treeSanitizer: NodeTreeSanitizer.trusted);
    _observer = AttributeObserver(root,
        rootAttributes: rootAttributes,
        subtreeAttributes: subtreeAttributes,
        directDescendantsOnly: _directDescendantsOnly,
        onAttributeChanged: attributeChanged,
        onSubtreeChanged: subtreeChanged,
        onSubtreeAttributeChanged: subtreeAttributeChanged);
  }

  /// Get the initial innerHTML of this element. Typically called once at
  /// initialization, and again if the outermost tag of the template changes.
  @protected
  String innerHtml();

  /// Setup event listeners and other things that should not block first paint.
  @protected
  void afterFirstRender() {}

  @protected
  void attributeChanged(String name, String oldValue, String newValue) {}

  @protected
  void subtreeChanged(Element target, bool removed) {}

  @protected
  void subtreeAttributeChanged(
      Element target, String name, String oldValue, String newValue) {}

  /// Elements that have one or more of the [subtreeAttributes] defined.
  Iterable<Element> get subtreeElements => _observer.subtreeElements;

  /// Disconnects the subtree [MutationObserver] and optionally each of the
  /// existing attribute observers in the subtree.
  void stopSubtreeObservations([bool attributeObservations = false]) =>
      _observer.stopSubtreeObservations(attributeObservations);

  @mustCallSuper
  void destroy() {
    _observer.destroy();
    component?.destroy();
  }
}
