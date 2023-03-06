import 'dart:async';
import 'package:flutter/material.dart';

class KeyboardVisibility with WidgetsBindingObserver {
  static final KeyboardVisibility _instance = KeyboardVisibility._();
  factory KeyboardVisibility() => _instance;
  KeyboardVisibility._();

  StreamController<bool> _streamController = StreamController<bool>.broadcast();
  Stream<bool> get stream => _streamController.stream;

  bool _keyboardVisible = false;

  void init(BuildContext context) {
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final bool isVisible =
        WidgetsBinding.instance?.window.viewInsets.bottom != 0;
    if (isVisible != _keyboardVisible) {
      _keyboardVisible = isVisible;
      _streamController.add(isVisible);
    }
  }

  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _streamController.close();
  }
}
