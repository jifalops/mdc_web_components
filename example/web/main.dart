import 'dart:html';
import 'package:mdc_web_components/mdc_web_components.dart';

void main() {
  querySelector('#output').text = 'Your Dart app is running.';
  querySelectorAll(Button.tag).forEach((el) => Button(el));
}
