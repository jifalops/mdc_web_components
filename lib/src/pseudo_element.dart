import 'dart:html';
import 'package:meta/meta.dart';

abstract class PseudoElement {
  PseudoElement(this.root,
      {this.observedAttributes, this.parent, this.directParent}) {
    // Observe attributes.
    if (observedAttributes?.isNotEmpty ?? false) {
      _attributeObserver = MutationObserver((mutations, obs) {
        final oldValues = <String, dynamic>{};
        final newValues = <String, dynamic>{};
        mutations.forEach((mutation) {
          oldValues[mutation.attributeName] = mutation.oldValue;
          newValues[mutation.attributeName] =
              mutation.target.attributes[mutation.attributeName];
        });
        attributesChanged(oldValues, newValues);
      });
      _attributeObserver.observe(root,
          attributes: true,
          attributeOldValue: true,
          attributeFilter: observedAttributes);
    }

    // Observe connect/disconnect.
    if (parent != null || directParent != null) {
      _connectionObserver = MutationObserver((mutations, obs) {
        mutations.forEach((mutation) {
          if (mutation.addedNodes.contains(root))
            connectedCallback();
          else if (mutation.removedNodes.contains(root)) disconnectedCallback();
        });
      });
      if (parent != null)
        _connectionObserver.observe(parent, childList: true, subtree: true);
      else
        _connectionObserver.observe(directParent, childList: true);
    }
  }
  final Element root;
  final List<String> observedAttributes;
  // final DomConnection attachment;
  /// If specified, [parent] and its subtree to will be observed to determine
  /// when this element is attached or detached from the DOM, and call
  /// [connectedCallback()] or [disconnectedCallback()] respectively.
  ///
  /// This option overrides [directParent].
  final Node parent;

  /// If specified, [directParent] will be observed to determine when this
  /// element is attached or detached from the DOM, and call
  /// [connectedCallback()] or [disconnectedCallback()] respectively.
  ///
  /// [parent] overrides this option.
  final Node directParent;
  MutationObserver _attributeObserver;
  MutationObserver _connectionObserver;

  @mustCallSuper
  void destroy() {
    _attributeObserver?.disconnect();
    _connectionObserver?.disconnect();
  }

  /// Called when one or more of the [observedAttributes] changes. [oldValues]
  /// and [newValues] contains only the changes.
  @protected
  void attributesChanged(
      Map<String, dynamic> oldValues, Map<String, dynamic> newValues) {}

  @protected
  void connectedCallback() {}
  @protected
  void disconnectedCallback() {}
}
