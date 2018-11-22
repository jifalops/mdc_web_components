import 'dart:html';
import 'package:meta/meta.dart';

/// Sets up a [MutationObserver] to watch an element's attributes and/or observe
/// its subtree for nodes added or removed that contain any of the observed
/// [subtreeAttributes].
abstract class AttributeObserverBase {
  AttributeObserverBase(
    this.root, {
    this.rootAttributes: const {},
    this.subtreeAttributes: const {},
    bool directDescendantsOnly: false,
  }) {
    if (rootAttributes.isNotEmpty) {
      _attributeObserver = MutationObserver((mutations, obs) {
        mutations.forEach((mutation) {
          attributeChanged(mutation.attributeName, mutation.oldValue,
              root.attributes[mutation.attributeName]);
        });
      });
      _attributeObserver.observe(root,
          attributes: true,
          attributeOldValue: true,
          attributeFilter: rootAttributes.keys.toList());

      // Add classes to first element child.
      rootAttributes.forEach((attr, klass) {
        if (klass != null && root.attributes.containsKey(attr))
          root.children[0].classes.add(klass);
      });
    }

    if (subtreeAttributes.isNotEmpty) {
      _subtreeObserver = MutationObserver((mutations, obs) {
        mutations.forEach((mutation) {
          _checkSubtree(mutation.addedNodes, _SubtreeState.nodesAdded);
          _checkSubtree(mutation.removedNodes, _SubtreeState.nodesRemoved);
        });
      });

      _subtreeObserver.observe(root,
          childList: true, subtree: !directDescendantsOnly);

      _nestedRootElements
          .addAll(root.querySelectorAll(root.tagName)..remove(root));

      _checkSubtree(root.querySelectorAll('*'), _SubtreeState.initial);
    }
  }

  final Element root;

  /// Maps each attribute observed on [root] to a corresponding CSS class on
  /// root's first element child, or `null` if no corresponding CSS class exists.
  final Map<String, String> rootAttributes;

  /// Maps each attribute observed in [root]'s subtree to a corresponding CSS
  /// class on the element containing the attribute, or `null` if no
  /// corresponding CSS class exists.
  final Map<String, String> subtreeAttributes;
  MutationObserver _attributeObserver;
  MutationObserver _subtreeObserver;
  final _nestedRootElements = Set<Element>();
  final _subtreeAttributeObservers = Map<Element, MutationObserver>();

  /// Elements that have one or more of the [subtreeAttributes] defined.
  Iterable<Element> get subtreeElements => _subtreeAttributeObservers.keys;

  /// Disconnects the subtree [MutationObserver] and optionally each of the
  /// existing attribute observers in the subtree.
  void stopSubtreeObservations([bool attributeObservations = false]) {
    _subtreeObserver?.disconnect();
    if (attributeObservations) {
      _subtreeAttributeObservers.forEach((el, obs) => obs.disconnect());
      _subtreeAttributeObservers.clear();
    }
  }

  @mustCallSuper
  void destroy() {
    _attributeObserver?.disconnect();
    _subtreeObserver?.disconnect();
    _subtreeAttributeObservers.forEach((el, obs) => obs.disconnect());
    _subtreeAttributeObservers.clear();
  }

  /// Called when one of the [rootAttributes] changes on [root].
  @protected
  @mustCallSuper
  void attributeChanged(String name, String oldValue, String newValue) {
    if (rootAttributes[name] != null)
      root.children[0].classes.toggle(rootAttributes[name]);
  }

  /// Called when a subtree element is added or removed that contains one or
  /// more [subtreeAttributes].
  @protected
  void subtreeChanged(Element target, bool removed);

  /// Called when any of the [subtreeAttributes] changes on a subtree element.
  @protected
  @mustCallSuper
  void subtreeAttributeChanged(
      Element target, String name, String oldValue, String newValue) {
    if (subtreeAttributes[name] != null)
      target.classes.toggle(subtreeAttributes[name]);
  }

  void _checkSubtree(List<Node> nodes, _SubtreeState state) {
    for (Node node in nodes) {
      if (node.nodeType != Node.ELEMENT_NODE) continue;
      Element el = node as Element;
      if (state != _SubtreeState.nodesRemoved && el.tagName == root.tagName) {
        _nestedRootElements.add(el);
      } else if (!_nestedRootElements.remove(el)) {
        bool nested = false;
        for (Element e in _nestedRootElements) {
          if (e.contains(node)) {
            nested = true;
            break;
          }
        }
        if (nested) continue;
        bool firstAttribute = true;
        subtreeAttributes.forEach((attr, klass) {
          if (el.attributes.containsKey(attr)) {
            if (firstAttribute) {
              firstAttribute = false;
              if (state == _SubtreeState.nodesRemoved) {
                _subtreeAttributeObservers[el]?.disconnect();
                _subtreeAttributeObservers.remove(el);
              } else {
                _subtreeAttributeObservers[el] =
                    MutationObserver((mutations, o) {
                  mutations.forEach((mutation) {
                    subtreeAttributeChanged(
                        mutation.target,
                        mutation.attributeName,
                        mutation.oldValue,
                        mutation.target.attributes[mutation.attributeName]);
                  });
                });
                _subtreeAttributeObservers[el].observe(el,
                    attributes: true,
                    attributeOldValue: true,
                    attributeFilter: subtreeAttributes.keys.toList());
              }
              if (state != _SubtreeState.initial) {
                subtreeChanged(el, state == _SubtreeState.nodesRemoved);
              }
            }

            if (state != _SubtreeState.nodesRemoved && klass != null)
              el.classes.add(klass);
          }
        });
      }
    }
  }
}

enum _SubtreeState { initial, nodesAdded, nodesRemoved }

/// Implements [attributeChanged], [subtreeChanged], and
/// [subtreeAttributeChanged] as callbacks.
class AttributeObserver extends AttributeObserverBase {
  AttributeObserver(Element root,
      {Map<String, String> rootAttributes,
      Map<String, String> subtreeAttributes,
      bool directDescendantsOnly: false,
      this.onAttributeChanged,
      this.onSubtreeChanged,
      this.onSubtreeAttributeChanged})
      : super(root,
            rootAttributes: rootAttributes ?? {},
            subtreeAttributes: subtreeAttributes ?? {},
            directDescendantsOnly: directDescendantsOnly ?? false);

  final AttributeChangedCallback onAttributeChanged;
  final SubtreeChangedCallback onSubtreeChanged;
  final SubtreeAttributeChangedCallback onSubtreeAttributeChanged;

  @override
  @protected
  @mustCallSuper
  void attributeChanged(String name, String oldValue, String newValue) {
    super.attributeChanged(name, oldValue, newValue);
    if (onAttributeChanged != null)
      onAttributeChanged(name, oldValue, newValue);
  }

  @override
  @protected
  @mustCallSuper
  void subtreeChanged(Element target, bool removed) {
    if (onSubtreeChanged != null) onSubtreeChanged(target, removed);
  }

  @override
  @protected
  @mustCallSuper
  void subtreeAttributeChanged(
      Element target, String name, String oldValue, String newValue) {
    super.subtreeAttributeChanged(target, name, oldValue, newValue);
    if (onSubtreeAttributeChanged != null)
      onSubtreeAttributeChanged(target, name, oldValue, newValue);
  }
}

typedef void AttributeChangedCallback(
    String name, String oldValue, String newValue);

typedef void SubtreeChangedCallback(Element target, bool removed);

typedef void SubtreeAttributeChangedCallback(
    Element target, String name, String oldValue, String newValue);
