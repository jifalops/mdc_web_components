import 'dart:html';
import 'package:meta/meta.dart';

/// Sets up a [MutationObserver] to watch an element's attributes and/or observe
/// its subtree for nodes added or removed that contain any of the observed
/// [subtreeAttributes].
///
/// Note that attribute changes on the subtree are _not_ observed; the
/// callback is invoked only when a subtree element is added or removed that
/// contains an attribute of interest. When one of those elements are added or
/// removed, [onChange] is called with the attribute's value as [newValue] if
/// it was added and [oldValue] if it was removed.
abstract class AttributeObserver {
  AttributeObserver(this.root,
      {List<String> rootAttributes, List<String> subtreeAttributes})
      : rootAttributes = rootAttributes?.toSet() ?? [],
        subtreeAttributes = subtreeAttributes?.toSet() ?? [] {
    if (subtreeAttributes.isNotEmpty) {
      _nestedRootElements
          .addAll(root.querySelectorAll(root.tagName)..remove(root));
    }

    _observer = MutationObserver((muts, obs) {
      List<MutationRecord> mutations = List.from(muts);
      mutations.forEach((mutation) {
        if (mutation.attributeName.isNotEmpty) {
          attributeChanged(mutation.attributeName, mutation.oldValue,
              root.attributes[mutation.attributeName]);
        } else {
          _checkSubtree(mutation.addedNodes, false);
          _checkSubtree(mutation.removedNodes, true);
        }
      });
    });

    _observer.observe(root,
        attributes: rootAttributes.isNotEmpty,
        attributeOldValue: rootAttributes.isNotEmpty,
        attributeFilter: rootAttributes.toList(),
        childList: subtreeAttributes.isNotEmpty,
        subtree: subtreeAttributes.isNotEmpty);
  }

  final Element root;
  final Set<String> rootAttributes;
  final Set<String> subtreeAttributes;
  MutationObserver _observer;
  final _nestedRootElements = Set<Element>();

  @protected
  @mustCallSuper
  void destroy() => _observer?.disconnect();

  @protected
  void attributeChanged(String name, String oldValue, String newValue);

  @protected
  void subtreeChanged(Element target, bool removed);

  void _checkSubtree(List<Node> nodes, bool removed) {
    nodes.forEach((node) {
      if (node.nodeType == Node.ELEMENT_NODE) {
        bool nested = false;
        _nestedRootElements.forEach((n) {
          if (n.contains(node)) nested = true;
        });
        if (!nested) {
          Element el = node as Element;
          for (String attr in subtreeAttributes) {
            if (el.attributes.containsKey(attr)) {
              subtreeChanged(el, removed);
              break;
            }
          }
        }
      }
    });
  }
}
