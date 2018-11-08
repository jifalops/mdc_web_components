/// Support for doing something awesome.
///
/// More dartdocs go here.
library mdc_web_components;

import 'dart:html';
import 'src/button.dart';

export 'src/pseudo_element.dart';
export 'src/base.dart';
export 'src/button.dart';
export 'src/util.dart';

void initComponents() {
  querySelectorAll(MWCButton.tag).forEach((el) => MWCButton(el));
}