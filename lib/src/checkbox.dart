import 'dart:html';
import 'package:mdc_web/mdc_web.dart';
import 'base.dart';
import 'util.dart';

/// A material-design button.
///
/// * [Design Guidelines](https://material.io/go/design-cards)
/// * [MDC Component Reference](https://material.io/components/web/catalog/cards/)
/// * [MDC Demo](https://material-components.github.io/material-components-web-catalog/#/component/card)
/// * [MDC Source Code](https://github.com/material-components/material-components-web/tree/master/packages/mdc-card)
/// * [MWC Source Code](https://github.com/material-components/material-components-web-components/blob/master/packages/card/)
class MWCCheckbox extends MWCComponent {
  static const tag = 'mwc-card';

  static const strokedClass = 'mdc-card--stroked';

  static const strokedAttr = 'stroked';

  MWCCheckbox(Element root, {Node parent, Node directParent})
      : super(root,
            observedAttributes: [strokedAttr],
            parent: parent,
            directParent: directParent);

  @override
  get component => null;

  bool get stroked => hasAttribute(root, strokedAttr);
  set stroked(bool value) => setBoolAttribute(root, strokedAttr, value);

  @override
  String innerHtml() {
    return '''
      <div class="mdc-card ${stroked ? strokedClass : ''}">
        <slot>${root.querySelector('slot')?.innerHtml ?? root.innerHtml}</slot>
      </div>''';
  }

  @override
  void attributeChangedCallback(String name, String oldValue, String newValue) {
    switch (name) {
      case strokedAttr:
        mdcRoot.classes.toggle(strokedClass);
        break;
    }
  }
}
