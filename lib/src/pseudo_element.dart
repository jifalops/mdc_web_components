import 'dart:html';
import 'package:meta/meta.dart';

abstract class PseudoElement {
  PseudoElement(this.root, {this.parent, this.directParent}) {
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
  List<String> get observedAttributes;
  // List<String> get templates;
  // TemplateElement get template;
  // TemplateElement _template;
  // final _slotObservers = <SlotElement, MutationObserver>{};

  // void _templateChanged(
  //     TemplateElement oldTemplate, TemplateElement newTemplate) {
  //   _removeSlotObservers();
  //   newTemplate.content.querySelectorAll('slot').forEach(
  //       (slot) => _slotObservers[slot] = MutationObserver((mutations, obs) {}));
  // }

  // void _removeSlotObservers() {
  //   _slotObservers.forEach((slot, obs) => obs.disconnect());
  //   _slotObservers.clear();
  // }
  // void _

  @mustCallSuper
  void destroy() {
    _attributeObserver.disconnect();
    _connectionObserver?.disconnect();
    // _removeSlotObservers();
  }

  /// Called when one or more of the [observedAttributes] changes. [oldValues]
  /// and [newValues] contains only the changes. Call `super()` *after* handling
  /// the changes.
  @protected
  @mustCallSuper
  void attributesChanged(
      Map<String, dynamic> oldValues, Map<String, dynamic> newValues) {
    render();
  }

  @protected
  void connectedCallback() {}
  @protected
  void disconnectedCallback() {}

  void render();
  //  {
    // final t = template;
    // if (t != _template) {
    //   print('Template changed.');
    //   root.childNodes.clear();
    //   root.append(document.importNode(t.content, true));
    //   _template = t;
    // }
  // }
}

// /// Determines how a mutation observer will be used to simulate the native
// /// "connectedCallback" and "disconnectedCallback".
// /// * [permanent] - no connection observer necessary.
// /// * [parent] - can be connected and disconnected, but only to its parent.
// /// * [document] - can be connected and disconnected anywhere in the document.
// enum DomConnection { permanent, parent, document }
