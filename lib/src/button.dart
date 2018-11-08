import 'dart:html';
import 'package:mdc_web/mdc_web.dart';
import 'base.dart';
import 'util.dart';

/// * [Demo](https://material-components.github.io/material-components-web-components/demos/button.html)
/// * [Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/button/src/mwc-button.ts)
class Button extends MwcBaseElement {
  static const tag = 'mwc-button';

  // Classes are set on the [mdcRoot].
  static const raisedClass = 'mdc-button--raised';
  static const unelevatedClass = 'mdc-button--unelevated';
  static const outlinedClass = 'mdc-button--outlined';
  static const denseClass = 'mdc-button--dense';

  // Attributes may be on [root] and/or [mdcRoot].
  static const raisedAttr = 'raised';
  static const unelevatedAttr = 'unelevated';
  static const outlinedAttr = 'outlined';
  static const denseAttr = 'dense';
  static const disabledAttr = 'disabled';
  static const iconAttr = 'icon';
  static const labelAttr = 'label';
  static const hrefAttr = 'href';
  static const targetAttr = 'target';
  static const rippleAttr = 'ripple';

  Button(Element root, {Node parent, Node directParent})
      : super(root,
            observedAttributes: [
              rippleAttr,
              hrefAttr,
              targetAttr,
              raisedAttr,
              unelevatedAttr,
              outlinedAttr,
              denseAttr,
              disabledAttr,
              iconAttr,
              labelAttr
            ],
            parent: parent,
            directParent: directParent);

  MDCRipple _mdcRipple;

  bool get ripple => hasAttribute(root, rippleAttr);
  set ripple(bool value) => setBoolAttribute(root, rippleAttr, value);

  /// The anchor's HTTP reference. If set, an anchor tag will be used instead of a button.
  String get href => getAttribute(root, hrefAttr);
  set href(String value) => setAttribute(root, hrefAttr, value);

  /// The anchor's target. If set, an anchor tag will be used instead of a button.
  String get target => getAttribute(root, targetAttr);
  set target(String value) => setAttribute(root, targetAttr, value);

  bool get raised => hasAttribute(root, raisedAttr);
  set raised(bool value) => setBoolAttribute(root, raisedAttr, value);

  bool get unelevated => hasAttribute(root, unelevatedAttr);
  set unelevated(bool value) => setBoolAttribute(root, unelevatedAttr, value);

  bool get outlined => hasAttribute(root, outlinedAttr);
  set outlined(bool value) => setBoolAttribute(root, outlinedAttr, value);

  bool get dense => hasAttribute(root, denseAttr);
  set dense(bool value) => setBoolAttribute(root, denseAttr, value);

  bool get disabled => hasAttribute(root, disabledAttr);
  set disabled(bool value) => setBoolAttribute(root, disabledAttr, value);

  /// An icon name from either material icons or font awesome.
  /// If you are using an SVG icon, leave this blank.
  String get icon => getAttribute(root, iconAttr);
  set icon(String value) => setAttribute(root, iconAttr, value);

  String get label => getAttribute(root, labelAttr);
  set label(String value) => setAttribute(root, labelAttr, value);

  /// Raised and unelevated buttons are both "contained".
  bool get contained => raised || unelevated;

  bool get iconIsFontAwesome => icon?.contains('fa-');

  @override
  String innerHtml() {
    final classes = ClassMap({
      raisedClass: raised,
      unelevatedClass: unelevated,
      outlinedClass: outlined,
      denseClass: dense,
    });
    final iconHtml = icon != null
        ? iconIsFontAwesome
            ? '<i aria-hidden="true" class="mdc-button__icon $icon"></i>'
            : '<i aria-hidden="true" class="mdc-button__icon material-icons">$icon</i>'
        : '';
    final svg = root.querySelector('svg');
    if (svg != null) {
      svg.classes.add('mdc-button__icon');
      svg.attributes['aria-hidden'] = 'true';
      svg.attributes['xmlns'] = 'http://www.w3.org/2000/svg';
    }
    if (href == null) {
      return '<button class="mdc-button $classes"'
          '${disabled ? disabledAttr : ''} aria-label="${label ?? icon}">'
          '$iconHtml$label<slot>${root.querySelector('slot')?.innerHtml ?? root.innerHtml}</slot></button>';
    } else {
      return '<a href="$href"${target != null ? ' target="$target"' : ''}"'
          'class="mdc-button $classes" role="button"'
          '${disabled ? disabledAttr : ''} aria-label="${label ?? icon}">'
          '$iconHtml$label<slot>${root.querySelector('slot')?.innerHtml ?? root.innerHtml}</slot></a>';
    }
  }

  @override
  void afterFirstRender() {
    print('afterfirstrender: $ripple, $mdcRoot');
    if (ripple) _addRipple();
  }

  @override
  void attributeChangedCallback(String name, String oldValue, String newValue) {
    switch (name) {
      case rippleAttr:
        ripple ? _addRipple() : _removeRipple();
        break;
      case raisedAttr:
        mdcRoot.classes.toggle(raisedClass);
        break;
      case unelevatedAttr:
        mdcRoot.classes.toggle(unelevatedClass);
        break;
      case outlinedAttr:
        mdcRoot.classes.toggle(outlinedClass);
        break;
      case denseAttr:
        mdcRoot.classes.toggle(denseClass);
        break;
      case disabledAttr:
        setBoolAttribute(mdcRoot, disabledAttr, disabled);
        break;
      case iconAttr:
        setAttribute(mdcRoot, iconAttr, newValue);
        break;
      case labelAttr:
        setAttribute(mdcRoot, labelAttr, newValue);
        break;
      case hrefAttr:
        if (oldValue == null || newValue == null)
          fullRender();
        else
          setAttribute(mdcRoot, hrefAttr, newValue);
        break;
      case targetAttr:
        setAttribute(mdcRoot, targetAttr, newValue);
        break;
    }
  }

  void _addRipple() {
    _removeRipple();
    _mdcRipple = MDCRipple.attachTo(mdcRoot);
  }

  void _removeRipple() {
    _mdcRipple?.destroy();
    _mdcRipple = null;
  }

  @override
  void destroy() {
    _removeRipple();
    super.destroy();
  }
}
