import 'dart:html';
import 'base.dart';
import 'util.dart';

/// * [Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/button/src/mwc-button.ts)
class Button extends BaseElement {
  static const tag = 'mwc-button';
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

  static const cssClasses = {
    'raised': 'mdc-button--raised',
    'unelevated': 'mdc-button--unelevated',
    'outlined': 'mdc-button--outlined',
    'dense': 'mdc-button--dense',
    // 'icon': 'mdc-button__icon'
  };

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
  /// If you are using an SVG icon, leave this blank;
  /// the `mdc-button__icon` class, and `aria-hidden` and `xmlns` attributes
  /// will be added for you, but only if the SVG element is a child during the
  /// `attached()` lifecycle callback.
  String get icon => getAttribute(root, iconAttr);
  set icon(String value) => setAttribute(root, iconAttr, value);

  String get label => getAttribute(root, labelAttr);
  set label(String value) => setAttribute(root, labelAttr, value);

  /// Raised and unelevated buttons are both "contained".
  bool get contained => raised || unelevated;

  @override
  void attached() {
    super.attached();
    final svg = querySelector('svg');
    if (svg != null) {
      svg.classes.add('mdc-button__icon');
      svg.attributes['aria-hidden'] = 'true';
      svg.attributes['xmlns'] = 'http://www.w3.org/2000/svg';
    }
  }

  static const buttonTemplate = '<button class="mdc-button"';

  static const htmlTemplate = '<{{tag}} {{linkAttrs}}'
      ' class="mdc-button {{classList}}"'
      ' {{ripple}}>'
      '{{icon}}'
      '<span class="mdc-component-content">{{content}}</span>'
      '</{{tag}}>';

  @override
  Iterable get templateValues {
    final tag = href != null ? 'a ' : 'button';
    final classList = [];
    if (raised) classList.add(cssClasses['raised']);
    if (unelevated) classList.add(cssClasses['unelevated']);
    if (outlined) classList.add(cssClasses['outlined']);
    if (dense) classList.add(cssClasses['dense']);
    return [
      // tag
      tag,
      // linkAttrs
      href != null
          ? 'href="$href"${target != null ? ' target="$target"' : ''} role="button"'
          : '',
      // classList
      classList.join(' '),
      // ripple
      ripple ? 'data-mdc-auto-init="MDCRipple"' : '',
      // icon
      icon != null
          ? icon.contains('fa-')
              ? '<i aria-hidden="true" class="${cssClasses['icon']} $icon"></i>'
              : '<i aria-hidden="true" class="${cssClasses['icon']} material-icons">$icon</i>'
          : '',
      // content
      this.querySelector('.mdc-component-content')?.innerHtml ??
          initialInnerHtml,
      // tag
      tag
    ];
  }

  @override
  void firstRender() {}

  @override
  void render() {
    // TODO: implement render
  }
}
