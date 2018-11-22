import 'dart:html';
import 'package:meta/meta.dart';

/// Sets up a [MutationObserver] to watch an element's attributes and/or observe
/// its subtree for nodes added or removed that contain any of the observed
/// [subtreeAttributes].
abstract class AttributeObserverBase {
  AttributeObserverBase(
    this.root, {
    Map<String, String> rootAttributes,
    Map<String, String> subtreeAttributes,
    Dynamism dynamism,
  })  : rootAttributes = rootAttributes ?? {},
        subtreeAttributes = subtreeAttributes ?? {},
        dynamism = dynamism ?? Dynamism.full {
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
          _checkSubtree(mutation.addedNodes, _SubtreeState.nodesAdded);
          _checkSubtree(mutation.removedNodes, _SubtreeState.nodesRemoved);
        }
      });
    });

    bool observeAttributes =
        rootAttributes.isNotEmpty && dynamism.has(Dynamism.attributes);

    _observer.observe(root,
        attributes: observeAttributes,
        attributeOldValue: observeAttributes,
        attributeFilter: rootAttributes.keys,
        childList: subtreeAttributes.isNotEmpty &&
            dynamism.has(Dynamism.directChildren),
        subtree:
            subtreeAttributes.isNotEmpty && dynamism.has(Dynamism.subtree));

    _checkSubtree(root.children, _SubtreeState.initial);
  }

  final Element root;
  final Map<String, String> rootAttributes;
  final Map<String, String> subtreeAttributes;
  final Dynamism dynamism;
  MutationObserver _observer;
  final _nestedRootElements = Set<Element>();
  final _subtreeObservers = Map<Element, MutationObserver>();

  /// The subtree elements that have one or more of the [subtreeAttributes]
  /// defined.
  Iterable<Element> get subtreeElements => _subtreeObservers.keys;

  @mustCallSuper
  void destroy() {
    _observer?.disconnect();
    _subtreeObservers.forEach((el, obs) => obs.disconnect());
    _subtreeObservers.clear();
  }

  /// Called when one of the [rootAttributes] changes on [root].
  @protected
  void attributeChanged(String name, String oldValue, String newValue);

  /// Called when a subtree element is added or removed that contains one or
  /// more [subtreeAttributes].
  @protected
  void subtreeChanged(Element target, bool removed);

  /// Called when any of the [subtreeAttributes] changes on a subtree element.
  @protected
  void subtreeAttributeChanged(
      Element target, String name, String oldValue, String newValue);

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
        if (!nested) {
          for (String attr in subtreeAttributes) {
            if (el.attributes.containsKey(attr)) {
              if (state == _SubtreeState.nodesRemoved) {
                _subtreeObservers[el]?.disconnect();
                _subtreeObservers.remove(el);
              } else {
                final obs = MutationObserver((mutations, o) {
                  mutations.forEach((mutation) {
                    subtreeAttributeChanged(
                        mutation.target,
                        mutation.attributeName,
                        mutation.oldValue,
                        mutation.target.attributes[mutation.attributeName]);
                  });
                });
                obs.observe(el,
                    attributes: true,
                    attributeOldValue: true,
                    attributeFilter: subtreeAttributes.toList());
                _subtreeObservers[el] = obs;
              }
              if (state != _SubtreeState.initial) {
                subtreeChanged(el, state == _SubtreeState.nodesRemoved);
              }
              break;
            }
          }
        }
      }
    }
  }
}

enum _SubtreeState { initial, nodesAdded, nodesRemoved }

/// Implements [attributeChanged], [subtreeChanged], and
/// [subtreeAttributeChanged] as callbacks.
class AttributeObserver extends AttributeObserverBase {
  AttributeObserver(Element root,
      {List<String> rootAttributes,
      List<String> subtreeAttributes,
      this.onAttributeChanged,
      this.onSubtreeChanged,
      this.onSubtreeAttributeChanged})
      : super(root,
            rootAttributes: rootAttributes,
            subtreeAttributes: subtreeAttributes);

  final AttributeChangedCallback onAttributeChanged;
  final SubtreeChangedCallback onSubtreeChanged;
  final SubtreeAttributeChangedCallback onSubtreeAttributeChanged;

  @override
  void attributeChanged(String name, String oldValue, String newValue) {
    if (onAttributeChanged != null)
      onAttributeChanged(name, oldValue, newValue);
  }

  @override
  void subtreeChanged(Element target, bool removed) {
    if (onSubtreeChanged != null) onSubtreeChanged(target, removed);
  }

  @override
  void subtreeAttributeChanged(
      Element target, String name, String oldValue, String newValue) {
    if (onSubtreeAttributeChanged != null)
      onSubtreeAttributeChanged(target, name, oldValue, newValue);
  }
}

typedef void AttributeChangedCallback(
    String name, String oldValue, String newValue);

typedef void SubtreeChangedCallback(Element target, bool removed);

typedef void SubtreeAttributeChangedCallback(
    Element target, String name, String oldValue, String newValue);

/// Flags for how dynamic an element may be. Having full dynamism of every
/// element in a large and deeply nested DOM tree would grow inefficiently. The
/// options here allow users to specify which changes can be ignored.
class Dynamism {
  const Dynamism._(this.value);
  static Dynamism combine([Dynamism a, Dynamism b, Dynamism c]) =>
      Dynamism._((a?.value ?? 0) | (b?.value ?? 0) | (c?.value ?? 0));
  final int value;

  /// [rootAttributes] on [root] will not change, and its subtree will not
  /// change with respect to the [subtreeAttributes].
  static const none = Dynamism._(0);

  /// The [rootAttibutes] may change dynamically. [root]'s subtree will not
  /// change with respect to the [subtreeAttributes].
  static const attributes = Dynamism._(1);

  /// Elements containing [subtreeAttributes] may be added or removed from
  /// [root]'s subtree, but only as direct children.
  static const directChildren = Dynamism._(2);

  /// Elements containing [subtreeAttributes] may be added or removed from
  /// anywhere in [root]'s subtree.
  static const subtree = Dynamism._(6); // 4|2

  /// Subtree (or direct child) elements containing [subtreeAttributes] may
  /// update those attributes dynamically.
  static const childAttributes = Dynamism._(8);

  /// All dynamic changes are allowed. [rootAttributes] on [root], elements
  /// containing [subtreeAttributes] may be added or removed anywhere in the
  /// subtree, and the [subtreeAttributes] on subtree elements may change
  /// dynamically.
  ///
  /// Note that one or more [subtreeAttributes] must be on an added or removed
  /// child element for it to be observed.
  static const full = Dynamism._(15);

  bool has(Dynamism other) => value & other.value != 0;
}
