import 'dart:async';
import 'dart:html';

Future<void> afterNextRender() async {
  await window.animationFrame;
  await Future.microtask(() {});
}