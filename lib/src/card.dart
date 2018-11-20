import 'dart:html';
import 'package:mdc_web/mdc_web.dart';
import 'pseudo_element.dart';
import 'base.dart';
import 'util.dart';

/// A material-design card.
///
/// * [Design Guidelines](https://material.io/go/design-cards)
/// * [MDC Component Reference](https://material.io/components/web/catalog/cards/)
/// * [MDC Demo](https://material-components.github.io/material-components-web-catalog/#/component/card)
/// * [MDC Source Code](https://github.com/material-components/material-components-web/tree/master/packages/mdc-card)
/// * [MWC Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/card/)
class MWCCard extends MWCComponent {
  static const tag = 'mwc-card';

  static const outlinedClass = 'mdc-card--outlined';
  static const primaryActionSlotClass = 'mdc-card__primary-action';
  static const mediaClass = 'mdc-card__media';
  static const mediaSquareClass = 'mdc-card__media--square';
  static const media16x9Class = 'mdc-card__media--16-9';
  static const mediaContentClass = 'mdc-card__media-content';
  static const actionsClass = 'mdc-card__actions';
  static const actionsFullBleedClass = 'mdc-card__actions--full-bleed';
  static const actionButtonsClass = 'mdc-card__action-buttons';
  static const actionIconsClass = 'mdc-card__action-icons';
  static const actionClass = 'mdc-card__action';
  static const actionButtonClass = 'mdc-card__action--button';
  static const actionIconClass = 'mdc-card__action--icon';

  static const outlinedAttr = 'outlined';
  static const primaryActionSlot = 'primary-action';
  static const mediaSlot = 'media';
  static const mediaSquareAttr = 'media-square';
  static const media16x9Attr = 'media-16x9';
  static const mediaContentAttr = 'media-content';
  static const actionsSlot = 'actions';
  static const actionsFullBleedAttr = 'actions-full-bleed';
  static const actionButtonsAttr = 'action-buttons';
  static const actionIconsAttr = 'action-icons';
  static const actionAttr = 'action';
  static const actionButtonAttr = 'action-button';
  static const actionIconAttr = 'action-icon';

  static const _primaryActionSlotSelector = '[slot="${primaryActionSlot}"]';
  static const _mediaSlotSelector = '[slot="${mediaSlot}"]';
  static const _actionsSlotSelector = '[slot="${actionsSlot}"]';

  MWCCard(Element root, {Node parent, Node directParent})
      : super(root,
            observedAttributes: [outlinedAttr],
            parent: parent,
            directParent: directParent) {

  }

  BemElement primaryAction, media, actions;

  @override
  String get displayStyle => 'block';

  bool get outlined => hasAttribute(root, outlinedAttr);
  set outlined(bool value) => setBoolAttribute(root, outlinedAttr, value);

  @override
  String innerHtml() {
    return '''
      <div class="mdc-card ${outlined ? outlinedClass : ''}">
        <slot name="primary-action"></slot>
        <slot name="media"></slot>
        <slot name="actions"></slot>
      </div>''';
  }

  @override
  void attributeChangedCallback(String name, String oldValue, String newValue) {
    switch (name) {
      case outlinedAttr:
        mdcRoot.classes.toggle(outlinedClass);
        break;
    }
  }

  @override
  void connectedCallback() {
    Element el = root.querySelector(_primaryActionSlotSelector);
    if (el != null) {
      primaryAction = BemElement(el, root,
          slot: primaryActionSlot, slotClass: primaryActionSlotClass);
    } else {}

    media = root.querySelector('[slot="${mediaSlot}"]');
    actions = root.querySelector('[slot="${actionsSlot}"]');

    if (primaryAction != null) {}
  }
}
