import 'dart:async';
import 'dart:html';

Future<void> afterNextRender() async {
  await window.animationFrame;
  await Future.microtask(() {});
}

bool hasAttribute(Element element, String attribute) =>
    element.attributes.containsKey(attribute);

void removeAttribute(Element element, String attribute) =>
    element.attributes.remove(attribute);

String getAttribute(Element element, String attribute) =>
    element.attributes[attribute];

void setAttribute(Element element, String attribute, String value) =>
    element.attributes[attribute] = value;

void setBoolAttribute(Element element, String attribute, bool value) => value
    ? setAttribute(element, attribute, attribute)
    : removeAttribute(element, attribute);
